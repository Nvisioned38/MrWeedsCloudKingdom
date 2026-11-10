import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show FramePhase, FrameTiming;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter/services.dart';

import '../domain/match3.dart';

/// Bounded, opt-in per-app Flutter frame diagnostics for the isolated QA APK.
/// This class never reads or writes game progress, preferences, or identifiers.
class QaFrameTimingCollector {
  QaFrameTimingCollector({
    required this.reducedMotion,
    this.warmup = const Duration(seconds: 2),
    this.maxSamples = 3000,
    this.log,
    @visibleForTesting this.runtimePackageNameForTesting,
  });

  static const bool _profilingBuild = bool.fromEnvironment(
    'CLOUD_KINGDOM_QA_FRAME_TIMING',
    defaultValue: false,
  );
  static const _identityChannel = MethodChannel('cloud_kingdom/qa_profile');
  static const int minimumSamples = 300;
  static bool get isProfilingBuild => _profilingBuild && !kReleaseMode;

  final bool reducedMotion;
  final Duration warmup;
  final int maxSamples;
  final void Function(String? message, {int? wrapWidth})? log;
  @visibleForTesting
  final String? runtimePackageNameForTesting;
  final List<_FrameSample> _samples = [];
  final Map<String, int> _eventCounts = {};
  Timer? _warmupTimer;
  bool _enabled = false;
  bool _started = false;
  bool _disposed = false;
  bool _callbackAttached = false;
  int _activeMicros = 0;
  int? _lastStartMicros;
  String _scenario = 'board_session';
  DateTime? _startedAt;

  int get sampleCount => _samples.length;
  bool get isCapturing => _callbackAttached;
  bool get isEnabled => _enabled && !_disposed;

  /// Aggregates actual engine trace events without retaining cell positions,
  /// level identity, or any game/save identifiers.
  void observeTurn(TurnAnimationTrace trace) {
    if (!isEnabled) return;
    _increment(trace.accepted ? 'acceptedSwaps' : 'rejectedSwaps');
    _increment('matchWaves', by: trace.waves.length);
    _increment(
      'clearedTiles',
      by: trace.waves.fold<int>(
        0,
        (total, wave) => total + wave.clearedPieces.length,
      ),
    );
    _increment(
      'gravityDrops',
      by: trace.waves.fold<int>(
        0,
        (total, wave) => total + wave.movements.length,
      ),
    );
    _increment(
      'refillSpawns',
      by: trace.waves.fold<int>(
        0,
        (total, wave) => total + wave.spawns.length,
      ),
    );
    _increment(
      'conditionChanges',
      by: trace.waves.fold<int>(
        0,
        (total, wave) => total + wave.conditionChanges.length,
      ),
    );
    _increment(
      'blockerChanges',
      by: trace.waves.fold<int>(
        0,
        (total, wave) => total + wave.blockerChanges.length,
      ),
    );
    for (final wave in trace.waves) {
      for (final piece in wave.createdSpecials.values) {
        final special = piece.special;
        if (special != null) _increment('createdSpecial.${special.name}');
      }
      for (final cell in wave.triggeredSpecials) {
        final special = wave.beforeClear.at(cell)?.special;
        if (special != null) _increment('triggeredSpecial.${special.name}');
      }
    }
    _eventCounts['maxCascadeWaves'] = math.max(
      _eventCounts['maxCascadeWaves'] ?? 0,
      trace.waves.length,
    );
  }

  void _increment(String name, {int by = 1}) {
    if (by == 0) return;
    _eventCounts.update(name, (value) => value + by, ifAbsent: () => by);
  }

  Future<void> start() async {
    final testPackage = runtimePackageNameForTesting;
    if (_started ||
        _disposed ||
        (!_profilingBuild && testPackage == null) ||
        kReleaseMode) {
      return;
    }
    _started = true;
    if (testPackage != null) {
      if (testPackage != 'com.mrweeds.cloudkingdom.qa') return;
    } else {
      if (defaultTargetPlatform != TargetPlatform.android) return;
      try {
        final metadata = await _identityChannel
            .invokeMapMethod<String, Object?>('profileMetadata');
        if (_disposed ||
            metadata?['packageName'] != 'com.mrweeds.cloudkingdom.qa') {
          return;
        }
        final requestedScenario = metadata?['scenario'];
        if (requestedScenario is String &&
            _allowedScenarios.contains(requestedScenario)) {
          _scenario = requestedScenario;
        }
      } on PlatformException {
        return;
      } on MissingPluginException {
        return;
      }
    }
    _enabled = true;
    _startedAt = DateTime.now().toUtc();
    resume();
  }

  static const _allowedScenarios = {
    'normal_match3',
    'long_cascade',
    'torch',
    'prism',
    'cloud_bomb',
    'reduced_motion',
  };

  /// Detaches while the app is backgrounded. The subsequent warmup is excluded
  /// from active time and sample collection.
  void pause() {
    _warmupTimer?.cancel();
    _warmupTimer = null;
    _detach();
    _closeActiveWindow();
  }

  /// Restarts capture after a fresh warmup window.
  void resume() {
    if (!_enabled || _disposed || _callbackAttached || _warmupTimer != null) {
      return;
    }
    _warmupTimer = Timer(warmup, () {
      _warmupTimer = null;
      if (_disposed || !_enabled || _callbackAttached) return;
      _lastStartMicros =
          SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds;
      _startedAt ??= DateTime.now().toUtc();
      SchedulerBinding.instance.addTimingsCallback(ingestTimingBatch);
      _callbackAttached = true;
    });
  }

  /// Stops once and emits bounded JSON only to the Android log. No UI or file
  /// storage is involved, so measurements cannot enter save data.
  void finish({required bool levelEnded}) {
    if (_disposed) return;
    pause();
    _disposed = true;
    if (!_enabled) return;
    final budgetMicros = _refreshBudgetMicros;
    final build =
        statisticsFromMicros(_samples.map((s) => s.buildMicros).toList());
    final raster =
        statisticsFromMicros(_samples.map((s) => s.rasterMicros).toList());
    final total =
        statisticsFromMicros(_samples.map((s) => s.totalMicros).toList());
    final summary = <String, Object?>{
      'type': 'cloud_kingdom_frame_timing_v1',
      'scenario': _scenario,
      'package': 'com.mrweeds.cloudkingdom.qa',
      'mode': reducedMotion ? 'reduced' : 'normal',
      'captureStartedUtc': _startedAt?.toIso8601String(),
      'wallWindowMs': _startedAt == null
          ? 0
          : DateTime.now().toUtc().difference(_startedAt!).inMilliseconds,
      'levelStarted': true,
      'levelEnded': levelEnded,
      'engineEvents': Map<String, int>.unmodifiable(_eventCounts),
      'sampleCount': _samples.length,
      'minimumSamples': minimumSamples,
      'classification':
          _samples.length >= minimumSamples ? 'captured' : 'insufficient',
      'activeWindowMs': _activeMicros / 1000,
      'refreshRateHz': _refreshRateHz,
      'refreshBudgetMs': budgetMicros / 1000,
      'missesOverRefreshBudget': countOverBudget(
        _samples.map((s) => s.totalMicros),
        budgetMicros,
      ),
      'missesOver16_67ms': countOverBudget(
        _samples.map((s) => s.totalMicros),
        16670,
      ),
      'buildMs': build,
      'rasterMs': raster,
      'totalSpanMs': total,
    };
    (log ?? debugPrint)('CK_FRAME_TIMING ${jsonEncode(summary)}');
    _samples.clear();
  }

  @visibleForTesting
  void ingestTimingBatch(List<FrameTiming> batch) {
    if (_disposed || !_enabled) return;
    for (final timing in batch) {
      if (_samples.length >= maxSamples) break;
      final start = timing.timestampInMicroseconds(FramePhase.buildStart);
      if (_lastStartMicros != null && start > _lastStartMicros!) {
        _activeMicros += start - _lastStartMicros!;
      }
      _lastStartMicros = start;
      _samples.add(_FrameSample(
        buildMicros: timing.buildDuration.inMicroseconds,
        rasterMicros: timing.rasterDuration.inMicroseconds,
        totalMicros: timing.totalSpan.inMicroseconds,
      ));
    }
  }

  void _detach() {
    if (!_callbackAttached) return;
    SchedulerBinding.instance.removeTimingsCallback(ingestTimingBatch);
    _callbackAttached = false;
  }

  void _closeActiveWindow() {
    _lastStartMicros = null;
  }

  int get _refreshRateHz {
    final views = SchedulerBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return 60;
    final rate = views.first.display.refreshRate;
    return rate.isFinite && rate >= 30 ? rate.round() : 60;
  }

  int get _refreshBudgetMicros => (1000000 / _refreshRateHz).round();

  @visibleForTesting
  static Map<String, num?> statisticsFromMicros(List<int> values) {
    if (values.isEmpty) {
      return {'p50': null, 'p90': null, 'p99': null, 'max': null};
    }
    values.sort();
    double percentile(double p) {
      final rank = (values.length - 1) * p;
      final lower = rank.floor();
      final upper = rank.ceil();
      final value =
          values[lower] + (values[upper] - values[lower]) * (rank - lower);
      return double.parse((value / 1000).toStringAsFixed(3));
    }

    return {
      'p50': percentile(.50),
      'p90': percentile(.90),
      'p99': percentile(.99),
      'max': double.parse((values.last / 1000).toStringAsFixed(3)),
    };
  }

  @visibleForTesting
  static int countOverBudget(Iterable<int> durationsMicros, int budgetMicros) =>
      durationsMicros.where((duration) => duration > budgetMicros).length;
}

class _FrameSample {
  const _FrameSample({
    required this.buildMicros,
    required this.rasterMicros,
    required this.totalMicros,
  });

  final int buildMicros;
  final int rasterMicros;
  final int totalMicros;
}
