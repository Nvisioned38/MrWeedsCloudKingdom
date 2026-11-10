import 'dart:async';
import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../domain/match3.dart';
import 'board_sprite_renderer.dart';
import 'match3_png_board_renderer.dart';

class CloudBoardGame extends FlameGame with TapCallbacks {
  static const _reducedMatchFeedbackDuration = .30;
  static const _reducedInvalidFeedbackDuration = .22;

  CloudBoardGame({
    required this.session,
    required this.onTurn,
    this.onSelectionChanged,
    BoardSpriteRenderer? spriteRenderer,
    BoardEffectsHook? effectsHook,
    this.approvedArtLoader,
    this.reducedMotion = false,
  })  : spriteRenderer =
            spriteRenderer ?? const CloudKingdomFallbackBoardRenderer(),
        effectsHook = effectsHook ?? const NoBoardEffectsHook();

  BoardSpriteRenderer spriteRenderer;
  final Future<BoardSpriteRenderer> Function()? approvedArtLoader;
  final BoardEffectsHook effectsHook;
  final bool reducedMotion;
  final LevelSession session;
  final void Function(TurnResult result) onTurn;
  final VoidCallback? onSelectionChanged;
  Cell? get selectedCell => _selected;
  bool get isResolving => _resolving;

  Cell? _selected;
  bool _resolving = false;
  double _elapsed = 0;
  double _duration = 0;
  double _selectedPulse = 0;
  TurnAnimationTrace? _trace;
  BoardVisualSnapshot? _settledSnapshot;
  TurnResult? _pendingResult;
  int _cascadeLabel = 0;
  double _cascadeLeft = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (spriteRenderer is CloudKingdomFallbackBoardRenderer) {
      final loadArtwork =
          approvedArtLoader ?? () => CloudKingdomPngBoardRenderer.load();
      unawaited(loadArtwork().then((loaded) {
        spriteRenderer = loaded;
      }).catchError((Object error, StackTrace stack) {}));
    }
  }

  @override
  Color backgroundColor() => const Color(0xff173d55);

  @override
  void update(double dt) {
    super.update(dt);
    _selectedPulse = (_selectedPulse + dt * 5) % (math.pi * 2);
    if (_resolving) {
      _elapsed = math.min(_duration, _elapsed + dt);
      if (_elapsed >= _duration) _completePresentation();
    }
    if (_cascadeLeft > 0) _cascadeLeft = math.max(0, _cascadeLeft - dt);
  }

  /// Stops visual work and reconciles to the authoritative already-resolved
  /// engine state. The caller can defer the result callback until resume.
  void cancelAnimation({bool notify = true}) {
    if (!_resolving) return;
    _settledSnapshot = _trace?.after ?? _settledSnapshot;
    _elapsed = _duration;
    _resolving = false;
    _trace = null;
    onSelectionChanged?.call();
    if (notify) completePendingTurn();
  }

  void completePendingTurn() {
    final result = _pendingResult;
    _pendingResult = null;
    if (result != null) onTurn(result);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final cellSize = size.x / session.board.cols;
    final tileSize = cellSize * .88;
    if (_resolving && _trace != null) {
      _renderTrace(canvas, _trace!, cellSize, tileSize);
    } else {
      _settledSnapshot ??= _snapshotCurrent();
      _renderSnapshot(canvas, _settledSnapshot!, cellSize, tileSize);
    }
    if (!reducedMotion && _cascadeLeft > 0 && _cascadeLabel > 1) {
      _drawLabel(canvas, 'CASCADE ×$_cascadeLabel', Offset(size.x / 2, 18), 16,
          const Color(0xffffd36e),
          bold: true);
    }
  }

  void _renderTrace(Canvas canvas, TurnAnimationTrace trace, double cellSize,
      double tileSize) {
    final t = (_elapsed / _duration).clamp(0.0, 1.0).toDouble();
    if (reducedMotion) {
      _renderSnapshot(
        canvas,
        trace.accepted ? trace.after : trace.before,
        cellSize,
        tileSize,
      );
      final feedbackCells =
          trace.accepted ? trace.result.changedCells : {trace.from, trace.to};
      final fade = 1 - _easeInOut(t);
      for (final cell in feedbackCells) {
        final rect = Rect.fromCenter(
          center: _center(cell, cellSize),
          width: cellSize * .82,
          height: cellSize * .82,
        );
        final feedbackColor =
            trace.accepted ? const Color(0xffffd36e) : const Color(0xffc9d6e8);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(9)),
          Paint()
            ..color = feedbackColor.withValues(alpha: .4 * fade)
            ..style = PaintingStyle.stroke
            ..strokeWidth = cellSize * .1
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, cellSize * .08),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(9)),
          Paint()
            ..color = feedbackColor.withValues(alpha: .96 * fade)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      }
      if (trace.waves.isNotEmpty) {
        _drawWaveEffects(
          canvas,
          trace.waves.first,
          trace.before,
          0,
          BoardEffectPhase.clearing,
          t,
          cellSize,
        );
      }
      return;
    }
    const swapDuration = .14;
    final shuffleDuration = trace.shuffled ? .22 : 0.0;
    final waveDuration = trace.waves.isEmpty
        ? 0.0
        : (_duration - swapDuration - shuffleDuration) / trace.waves.length;
    final from = _center(trace.from, cellSize);
    final to = _center(trace.to, cellSize);
    if (!trace.accepted) {
      _renderSnapshot(canvas, trace.before, cellSize, tileSize,
          hidden: {trace.from, trace.to});
      final progress = _easeOut(t);
      final excursion = progress < .48 ? progress / .48 : (1 - progress) / .52;
      if (trace.originalFrom != null) {
        spriteRenderer.drawPiece(canvas, Offset.lerp(from, to, excursion)!,
            tileSize, trace.originalFrom!);
      }
      if (trace.originalTo != null) {
        spriteRenderer.drawPiece(canvas, Offset.lerp(to, from, excursion)!,
            tileSize, trace.originalTo!);
      }
      return;
    }

    if (_elapsed < swapDuration) {
      _renderSnapshot(canvas, trace.before, cellSize, tileSize,
          hidden: {trace.from, trace.to});
      final progress = _easeInOut((_elapsed / swapDuration).clamp(0.0, 1.0));
      if (trace.originalFrom != null) {
        spriteRenderer.drawPiece(canvas, Offset.lerp(from, to, progress)!,
            tileSize, trace.originalFrom!);
      }
      if (trace.originalTo != null) {
        spriteRenderer.drawPiece(canvas, Offset.lerp(to, from, progress)!,
            tileSize, trace.originalTo!);
      }
      return;
    }

    var local = _elapsed - swapDuration;
    var previousSnapshot = trace.before;
    for (var waveIndex = 0; waveIndex < trace.waves.length; waveIndex++) {
      final wave = trace.waves[waveIndex];
      if (local < waveDuration) {
        final clearDuration = waveDuration * .42;
        final clearT = (local / clearDuration).clamp(0.0, 1.0).toDouble();
        if (local < clearDuration) {
          _renderSnapshot(canvas, wave.beforeClear, cellSize, tileSize,
              hidden: wave.clearedPieces.keys.toSet());
          for (final entry in wave.clearedPieces.entries) {
            _drawPieceTransform(
              canvas,
              _center(entry.key, cellSize),
              tileSize,
              entry.value,
              scale: 1 - _easeInOut(clearT) * .72,
              opacity: 1 - _easeInOut(clearT),
            );
            _drawClearSparkle(
              canvas,
              _center(entry.key, cellSize),
              tileSize,
              clearT,
              entry.key.row * session.board.cols + entry.key.col,
            );
          }
          _drawWaveEffects(
            canvas,
            wave,
            previousSnapshot,
            waveIndex,
            BoardEffectPhase.clearing,
            clearT,
            cellSize,
          );
        } else {
          final gravityT = _easeInOut(
              ((local - clearDuration) / (waveDuration - clearDuration))
                  .clamp(0.0, 1.0)
                  .toDouble());
          final hidden = <Cell>{};
          for (final movement in wave.movements) {
            hidden
              ..add(movement.source)
              ..add(movement.destination);
          }
          for (final spawn in wave.spawns) {
            hidden.add(spawn.destination);
          }
          _renderSnapshot(canvas, wave.afterClear, cellSize, tileSize,
              hidden: hidden);
          for (final movement in wave.movements) {
            spriteRenderer.drawPiece(
              canvas,
              Offset.lerp(_center(movement.source, cellSize),
                  _center(movement.destination, cellSize), gravityT)!,
              tileSize,
              movement.piece,
            );
          }
          for (final spawn in wave.spawns) {
            spriteRenderer.drawPiece(
              canvas,
              Offset.lerp(
                  Offset((spawn.destination.col + .5) * cellSize,
                      (spawn.origin + .5) * cellSize),
                  _center(spawn.destination, cellSize),
                  gravityT)!,
              tileSize,
              spawn.piece,
            );
          }
          _drawWaveEffects(
            canvas,
            wave,
            previousSnapshot,
            waveIndex,
            BoardEffectPhase.gravity,
            gravityT,
            cellSize,
          );
        }
        return;
      }
      local -= waveDuration;
      previousSnapshot = wave.afterGravity;
    }

    if (trace.shuffled && trace.shuffleBefore != null) {
      final shuffleT = (local / shuffleDuration).clamp(0.0, 1.0).toDouble();
      _renderSnapshot(canvas, trace.shuffleBefore!, cellSize, tileSize,
          opacity: 1 - _easeInOut(shuffleT));
      _renderSnapshot(canvas, trace.after, cellSize, tileSize,
          opacity: _easeInOut(shuffleT));
      _drawLabel(canvas, 'RESHUFFLING', Offset(size.x / 2, 18), 13,
          const Color(0xfffff2ad),
          bold: true);
    } else {
      _renderSnapshot(canvas, trace.after, cellSize, tileSize);
    }
  }

  void _drawWaveEffects(
    Canvas canvas,
    MatchWaveTrace wave,
    BoardVisualSnapshot previousSnapshot,
    int waveIndex,
    BoardEffectPhase phase,
    double progress,
    double cellSize,
  ) {
    final renderer = spriteRenderer;
    if (renderer is! BoardTurnEffectsRenderer) return;
    (renderer as BoardTurnEffectsRenderer).drawTurnEffects(
      canvas,
      cellSize: cellSize,
      event: BoardTurnEffectFrame(
        clearedCells: wave.clearedPieces.keys.toSet(),
        createdSpecials: wave.createdSpecials,
        activatedSpecials: {
          for (final cell in wave.triggeredSpecials)
            if (wave.beforeClear.at(cell)?.special != null)
              cell: wave.beforeClear.at(cell)!,
        },
        blockerChanges: wave.blockerChanges,
        conditionChanges: wave.conditionChanges,
        beforeWave: previousSnapshot,
        currentWave: wave.beforeClear,
        prismTargetFamily: wave.prismTargetFamily,
        waveIndex: waveIndex,
        phase: phase,
        progress: progress,
        reducedMotion: reducedMotion,
        movements: wave.movements,
        spawns: wave.spawns,
      ),
    );
  }

  void _renderSnapshot(Canvas canvas, BoardVisualSnapshot snapshot,
      double cellSize, double tileSize,
      {Set<Cell> hidden = const {}, double opacity = 1}) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var row = 0; row < session.board.rows; row++) {
      for (var col = 0; col < session.board.cols; col++) {
        final cell = Cell(row, col);
        final center = _center(cell, cellSize);
        paint.color = const Color(0xff244f67);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: tileSize, height: tileSize),
            const Radius.circular(9),
          ),
          paint,
        );
        final blocker = snapshot.blockers[cell];
        if (blocker != null) {
          canvas.saveLayer(
            Rect.fromCenter(center: center, width: tileSize, height: tileSize),
            Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
          );
          spriteRenderer.drawBlocker(canvas, center, tileSize,
              BlockerState.visual(blocker.kind, blocker.hp));
          canvas.restore();
        } else if (!hidden.contains(cell)) {
          final piece = snapshot.at(cell);
          if (piece != null) {
            _drawPieceTransform(
              canvas,
              center,
              tileSize,
              piece,
              opacity: opacity,
              scale: cell == _selected && !_resolving
                  ? 1 + (reducedMotion ? 0 : .035 * math.sin(_selectedPulse))
                  : 1,
            );
          }
        }
        if (_selected == cell && !_resolving) {
          final alpha = reducedMotion
              ? 1.0
              : (.76 + .24 * math.sin(_selectedPulse)).clamp(0.0, 1.0);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: center,
                width: cellSize * .97,
                height: cellSize * .97,
              ),
              const Radius.circular(10),
            ),
            Paint()
              ..color = Color.fromRGBO(255, 255, 255, alpha.toDouble())
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        }
      }
    }
  }

  void _drawPieceTransform(
      Canvas canvas, Offset center, double tileSize, Piece piece,
      {double scale = 1, double opacity = 1}) {
    if (opacity <= 0 || scale <= 0) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
    canvas.saveLayer(
      Rect.fromCenter(
          center: center, width: tileSize * 1.3, height: tileSize * 1.3),
      Paint()
        ..color = Color.fromRGBO(255, 255, 255, opacity.clamp(0, 1).toDouble()),
    );
    spriteRenderer.drawPiece(canvas, center, tileSize, piece);
    canvas.restore();
  }

  void _drawClearSparkle(Canvas canvas, Offset center, double tileSize,
      double progress, int seed) {
    if (reducedMotion || progress > .78) return;
    final fade = (1 - progress / .78).clamp(0.0, 1.0).toDouble();
    final offset = Offset(
      (seed.isEven ? -1 : 1) * tileSize * .18,
      (seed % 3 - 1) * tileSize * .12,
    );
    final sparkleCenter = center + offset;
    final radius = tileSize * (.055 + .035 * progress);
    final paint = Paint()
      ..color = const Color(0xfffff4c5).withValues(alpha: fade)
      ..strokeWidth = math.max(1.1, tileSize * .025)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      sparkleCenter.translate(-radius, 0),
      sparkleCenter.translate(radius, 0),
      paint,
    );
    canvas.drawLine(
      sparkleCenter.translate(0, -radius),
      sparkleCenter.translate(0, radius),
      paint,
    );
  }

  BoardVisualSnapshot _snapshotCurrent() => BoardVisualSnapshot(
        tiles: [
          for (var r = 0; r < session.board.rows; r++)
            [
              for (var c = 0; c < session.board.cols; c++)
                session.board.at(r, c)
            ],
        ],
        blockers: {
          for (final entry in session.board.blockers.entries)
            entry.key: BlockerVisualState(entry.value.kind, entry.value.hp),
        },
      );

  Offset _center(Cell cell, double size) =>
      Offset((cell.col + .5) * size, (cell.row + .5) * size);

  double _easeInOut(double value) => value * value * (3 - 2 * value);
  double _easeOut(double value) => 1 - math.pow(1 - value, 3).toDouble();

  void _drawLabel(
      Canvas canvas, String text, Offset center, double fontSize, Color color,
      {bool bold = false}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center.translate(-painter.width / 2, -painter.height / 2),
    );
  }

  void _completePresentation() {
    if (!_resolving) return;
    _settledSnapshot = _trace?.after ?? _settledSnapshot;
    _resolving = false;
    _trace = null;
    final result = _pendingResult;
    _pendingResult = null;
    onSelectionChanged?.call();
    if (result != null) onTurn(result);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_resolving || session.outcome != LevelOutcome.playing) return;
    final cellSize = size.x / session.board.cols;
    final col = (event.localPosition.x / cellSize).floor();
    final row = (event.localPosition.y / cellSize).floor();
    if (row < 0 ||
        row >= session.board.rows ||
        col < 0 ||
        col >= session.board.cols ||
        session.board.blockerAt(row, col) != null) {
      return;
    }
    tapCell(Cell(row, col));
  }

  /// Same move path for physical touch and semantic actions.
  void tapCell(Cell tapped) {
    if (_resolving ||
        session.outcome != LevelOutcome.playing ||
        tapped.row < 0 ||
        tapped.row >= session.board.rows ||
        tapped.col < 0 ||
        tapped.col >= session.board.cols ||
        session.board.blockerAt(tapped.row, tapped.col) != null) {
      return;
    }
    if (_selected == null) {
      _selected = tapped;
      onSelectionChanged?.call();
      return;
    }
    if (_selected == tapped) {
      _selected = null;
      onSelectionChanged?.call();
      return;
    }
    final from = _selected!;
    if ((from.row - tapped.row).abs() + (from.col - tapped.col).abs() != 1) {
      _selected = tapped;
      onSelectionChanged?.call();
      return;
    }
    TurnAnimationTrace? trace;
    final result = session.swap(
      from,
      tapped,
      onAnimationTrace: (turnTrace) => trace = turnTrace.boardTrace,
    );
    _selected = null;
    if (!result.accepted) {
      _trace = trace;
      if (trace != null) {
        _resolving = true;
        _elapsed = 0;
        _duration = reducedMotion ? _reducedInvalidFeedbackDuration : .14;
        _pendingResult = null;
      } else {
        _selected = tapped;
      }
      onSelectionChanged?.call();
      return;
    }
    _resolving = true;
    _trace = trace;
    _settledSnapshot = trace?.after;
    _elapsed = 0;
    _duration = reducedMotion
        ? _reducedMatchFeedbackDuration
        : math.min(
            2.3,
            .14 +
                (trace?.waves.length ?? 1) * .25 +
                (trace?.shuffled ?? false ? .22 : 0),
          );
    _cascadeLabel = result.cascadeCount;
    _cascadeLeft = reducedMotion ? 0 : .8;
    _pendingResult = result;
    effectsHook.onAcceptedTurn(result);
    onSelectionChanged?.call();
  }
}
