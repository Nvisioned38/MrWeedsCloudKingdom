import 'dart:async';
import 'dart:collection';
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
  static QaFrameTimingCollector? _renderCollector;
  static const int minimumSamples = 300;
  static bool get isProfilingBuild => _profilingBuild && !kReleaseMode;

  final bool reducedMotion;
  final Duration warmup;
  final int maxSamples;
  final void Function(String? message, {int? wrapWidth})? log;
  @visibleForTesting
  final String? runtimePackageNameForTesting;
  final List<_FrameSample> _samples = [];
  final SplayTreeMap<int, _RenderFrameMark> _renderFrameMarks =
      SplayTreeMap<int, _RenderFrameMark>();
  final Map<String, List<_FrameSample>> _renderSamples = {};
  final Map<String, Map<String, int>> _renderComposition = {};
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
  int _renderFramesMatched = 0;
  int _renderFramesNearMatched = 0;
  int _renderFramesUnmatched = 0;
  final List<int> _renderClockOffsetsMicros = [];
  int? _firstRenderTimestamp;
  int? _firstFrameTimingBuildStart;

  int get sampleCount => _samples.length;
  bool get isCapturing => _callbackAttached;
  bool get isEnabled => _enabled && !_disposed;

  /// Labels the current Flutter frame with its board scene. Marks are joined
  /// to delivered FrameTiming records by their nearest build-start timestamp.
  static void markCurrentRenderFrame(String scene) =>
      _renderCollector?._markCurrentRenderFrame(scene);

  /// Records code-path draw/compositing work on the current QA board frame.
  static void recordCurrentCanvasWork({
    int imageDraws = 0,
    int translucentImageDraws = 0,
    int cloudBombSmokeDraws = 0,
    int vectorDraws = 0,
    int saveLayers = 0,
  }) =>
      _renderCollector?._recordCurrentCanvasWork(
        imageDraws: imageDraws,
        translucentImageDraws: translucentImageDraws,
        cloudBombSmokeDraws: cloudBombSmokeDraws,
        vectorDraws: vectorDraws,
        saveLayers: saveLayers,
      );

  void _markCurrentRenderFrame(String scene) {
    if (!isCapturing || _samples.length >= maxSamples) return;
    final timestamp =
        SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds;
    _markRenderFrameAt(timestamp, scene);
  }

  @visibleForTesting
  void markRenderFrameAtForTesting(int timestamp, String scene) =>
      _markRenderFrameAt(timestamp, scene);

  void _markRenderFrameAt(int timestamp, String scene) {
    if (!isCapturing || _samples.length >= maxSamples) return;
    if (timestamp <= 0) return;
    _firstRenderTimestamp ??= timestamp;
    final mark = _renderFrameMarks.putIfAbsent(
      timestamp,
      () => _RenderFrameMark(scene),
    );
    mark.scene = scene;
    _trimRenderFrameMarks();
  }

  void _recordCurrentCanvasWork({
    int imageDraws = 0,
    int translucentImageDraws = 0,
    int cloudBombSmokeDraws = 0,
    int vectorDraws = 0,
    int saveLayers = 0,
  }) {
    if (!isCapturing || _samples.length >= maxSamples) return;
    final timestamp =
        SchedulerBinding.instance.currentSystemFrameTimeStamp.inMicroseconds;
    _recordCanvasWorkAt(
      timestamp,
      imageDraws: imageDraws,
      translucentImageDraws: translucentImageDraws,
      cloudBombSmokeDraws: cloudBombSmokeDraws,
      vectorDraws: vectorDraws,
      saveLayers: saveLayers,
    );
  }

  @visibleForTesting
  void recordCanvasWorkAtForTesting(
    int timestamp, {
    int imageDraws = 0,
    int translucentImageDraws = 0,
    int cloudBombSmokeDraws = 0,
    int vectorDraws = 0,
    int saveLayers = 0,
  }) =>
      _recordCanvasWorkAt(
        timestamp,
        imageDraws: imageDraws,
        translucentImageDraws: translucentImageDraws,
        cloudBombSmokeDraws: cloudBombSmokeDraws,
        vectorDraws: vectorDraws,
        saveLayers: saveLayers,
      );

  void _recordCanvasWorkAt(
    int timestamp, {
    int imageDraws = 0,
    int translucentImageDraws = 0,
    int cloudBombSmokeDraws = 0,
    int vectorDraws = 0,
    int saveLayers = 0,
  }) {
    if (!isCapturing || _samples.length >= maxSamples) return;
    if (timestamp <= 0) return;
    final mark = _renderFrameMarks.putIfAbsent(
      timestamp,
      () => _RenderFrameMark('board_unclassified'),
    );
    mark
      ..imageDraws += imageDraws
      ..translucentImageDraws += translucentImageDraws
      ..cloudBombSmokeDraws += cloudBombSmokeDraws
      ..vectorDraws += vectorDraws
      ..saveLayers += saveLayers;
    _trimRenderFrameMarks();
  }

  void _trimRenderFrameMarks() {
    final limit = math.max(maxSamples, 1);
    if (_renderFrameMarks.length <= limit) return;
    final oldest = _renderFrameMarks.keys.reduce(math.min);
    _renderFrameMarks.remove(oldest);
  }

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
    _renderCollector = this;
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
  void pause({bool clearRenderMarks = true}) {
    _warmupTimer?.cancel();
    _warmupTimer = null;
    _detach(clearRenderMarks: clearRenderMarks);
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
    pause(clearRenderMarks: false);
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
      'renderFrameAttribution': {
        'matchedFrames': _renderFramesMatched,
        'nearTimestampFrames': _renderFramesNearMatched,
        'unmatchedFrames': _renderFramesUnmatched,
        'signedClockOffsetMs': statisticsFromMicros(_renderClockOffsetsMicros),
      },
      'clockJoinDiagnostics': {
        'firstRenderTimestamp': _firstRenderTimestamp,
        'firstFrameTimingBuildStart': _firstFrameTimingBuildStart,
        'firstOffsetMicros':
            _firstRenderTimestamp == null || _firstFrameTimingBuildStart == null
                ? null
                : _firstRenderTimestamp! - _firstFrameTimingBuildStart!,
        'remainingRenderMarks': _renderFrameMarks.length,
      },
    };
    final write = log ?? debugPrint;
    write('CK_FRAME_TIMING ${jsonEncode(summary)}');
    for (final entry in _renderSamples.entries) {
      write(
        'CK_FRAME_TIMING_SCENE ${jsonEncode(_renderSegmentSummary(entry.key, entry.value, budgetMicros))}',
      );
    }
    _samples.clear();
    _renderFrameMarks.clear();
    _renderSamples.clear();
    _renderComposition.clear();
    if (identical(_renderCollector, this)) _renderCollector = null;
  }

  Map<String, Object?> _renderSegmentSummary(
    String scene,
    List<_FrameSample> samples,
    int budgetMicros,
  ) {
    final composition = _renderComposition[scene] ?? const <String, int>{};
    final count = samples.length;
    return {
      'scene': scene,
      'sampleCount': count,
      'buildMs':
          statisticsFromMicros(samples.map((s) => s.buildMicros).toList()),
      'rasterMs':
          statisticsFromMicros(samples.map((s) => s.rasterMicros).toList()),
      'totalSpanMs':
          statisticsFromMicros(samples.map((s) => s.totalMicros).toList()),
      'missesOverRefreshBudget':
          countOverBudget(samples.map((s) => s.totalMicros), budgetMicros),
      'missesOver16_67ms':
          countOverBudget(samples.map((s) => s.totalMicros), 16670),
      'averageCanvasWork': {
        for (final entry in composition.entries)
          entry.key: count == 0
              ? 0
              : double.parse((entry.value / count).toStringAsFixed(2)),
      },
    };
  }

  @visibleForTesting
  void ingestTimingBatch(List<FrameTiming> batch) {
    if (_disposed || !_enabled) return;
    for (final timing in batch) {
      if (_samples.length >= maxSamples) break;
      final start = timing.timestampInMicroseconds(FramePhase.buildStart);
      _firstFrameTimingBuildStart ??= start;
      if (_lastStartMicros != null && start > _lastStartMicros!) {
        _activeMicros += start - _lastStartMicros!;
      }
      _lastStartMicros = start;
      final match = _takeNearestRenderFrameMark(start);
      final mark = match?.mark;
      if (mark == null) {
        _renderFramesUnmatched++;
      } else {
        if (match!.offsetMicros == 0) {
          _renderFramesMatched++;
        } else {
          _renderFramesNearMatched++;
          _renderClockOffsetsMicros.add(match.offsetMicros);
        }
        _renderSamples.putIfAbsent(mark.scene, () => []).add(_FrameSample(
              buildMicros: timing.buildDuration.inMicroseconds,
              rasterMicros: timing.rasterDuration.inMicroseconds,
              totalMicros: timing.totalSpan.inMicroseconds,
            ));
        final counts = _renderComposition.putIfAbsent(mark.scene, () => {});
        counts.update('imageDraws', (n) => n + mark.imageDraws,
            ifAbsent: () => mark.imageDraws);
        counts.update(
            'translucentImageDraws', (n) => n + mark.translucentImageDraws,
            ifAbsent: () => mark.translucentImageDraws);
        counts.update(
            'cloudBombSmokeDraws', (n) => n + mark.cloudBombSmokeDraws,
            ifAbsent: () => mark.cloudBombSmokeDraws);
        counts.update('vectorDraws', (n) => n + mark.vectorDraws,
            ifAbsent: () => mark.vectorDraws);
        counts.update('saveLayers', (n) => n + mark.saveLayers,
            ifAbsent: () => mark.saveLayers);
      }
      _samples.add(_FrameSample(
        buildMicros: timing.buildDuration.inMicroseconds,
        rasterMicros: timing.rasterDuration.inMicroseconds,
        totalMicros: timing.totalSpan.inMicroseconds,
      ));
    }
  }

  _RenderFrameMatch? _takeNearestRenderFrameMark(int timestamp) {
    if (_renderFrameMarks.isEmpty) return null;
    if (_renderFrameMarks.containsKey(timestamp)) {
      return _RenderFrameMatch(_renderFrameMarks.remove(timestamp)!, 0);
    }
    final before = _renderFrameMarks.lastKeyBefore(timestamp);
    final after = _renderFrameMarks.firstKeyAfter(timestamp);
    final candidate = before == null
        ? after
        : after == null
            ? before
            : timestamp - before <= after - timestamp
                ? before
                : after;
    if (candidate == null || (candidate - timestamp).abs() > 100000) {
      return null;
    }
    return _RenderFrameMatch(
      _renderFrameMarks.remove(candidate)!,
      candidate - timestamp,
    );
  }

  void _detach({bool clearRenderMarks = true}) {
    if (!_callbackAttached) return;
    SchedulerBinding.instance.removeTimingsCallback(ingestTimingBatch);
    _callbackAttached = false;
    if (clearRenderMarks) _renderFrameMarks.clear();
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

class _RenderFrameMark {
  _RenderFrameMark(this.scene);

  String scene;
  int imageDraws = 0;
  int translucentImageDraws = 0;
  int cloudBombSmokeDraws = 0;
  int vectorDraws = 0;
  int saveLayers = 0;
}

class _RenderFrameMatch {
  const _RenderFrameMatch(this.mark, this.offsetMicros);

  final _RenderFrameMark mark;
  final int offsetMicros;
}
