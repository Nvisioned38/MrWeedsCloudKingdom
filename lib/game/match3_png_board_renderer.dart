import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../domain/match3.dart';
import '../qa/frame_timing_collector.dart';
import 'board_sprite_renderer.dart';

typedef Match3PngAssetResolver = Future<ByteData> Function(String assetPath);

/// Draws the owner-approved Issue #4 PNGs without changing Match-3 logic.
///
/// All original pixel files are verified against the art approval manifests
/// during CI. The renderer only controls presentation: legacy TileFamily and
/// SpecialKind identifiers remain unchanged for deterministic save continuity.
class CloudKingdomPngBoardRenderer
    implements BoardSpriteRenderer, BoardTurnEffectsRenderer {
  CloudKingdomPngBoardRenderer._(this._images);

  final Map<String, ui.Image> _images;

  static const String _assetRoot = 'assets/art/match3/';
  static const List<String> _required = [
    'cloud_puff',
    'mystic_bloom',
    'ember_drop',
    'dream_crystal',
    'golden_nugget',
    'mw_crate',
    'reinforced_mw_crate',
    'sticky_syrup_overlay',
    'fog_overlay',
    'butane_torch_lighter',
    'prism',
    'cloud_bomb',
    'fx_white_smoke_01',
    'fx_white_smoke_02',
    'fx_white_smoke_03',
    'fx_magic_sparkles',
    'fx_combo_ring',
    'fx_cascade_streak',
  ];

  static Future<CloudKingdomPngBoardRenderer> load({
    Match3PngAssetResolver? assetResolver,
  }) async {
    final images = <String, ui.Image>{};
    final resolve = assetResolver ?? rootBundle.load;
    try {
      for (final key in _required) {
        final bytes = await resolve('$_assetRoot$key.png');
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
        try {
          final frame = await codec.getNextFrame();
          images[key] = frame.image;
        } finally {
          codec.dispose();
        }
      }
    } catch (_) {
      for (final image in images.values) {
        image.dispose();
      }
      rethrow;
    }
    return CloudKingdomPngBoardRenderer._(images);
  }

  void dispose() {
    for (final image in _images.values) {
      image.dispose();
    }
  }

  void _draw(Canvas canvas, Offset center, double size, String key,
      {double rotation = 0, double opacity = 1, bool cloudBombSmoke = false}) {
    final image = _images[key];
    if (image == null) return;
    QaFrameTimingCollector.recordCurrentCanvasWork(
      imageDraws: 1,
      translucentImageDraws: opacity < 1 ? 1 : 0,
      cloudBombSmokeDraws: cloudBombSmoke ? 1 : 0,
    );
    final half = size / 2;
    final rect = Rect.fromLTWH(-half, -half, size, size);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotation != 0) canvas.rotate(rotation);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rect,
      Paint()
        ..filterQuality = FilterQuality.medium
        ..color = const Color(0xffffffff).withValues(alpha: opacity),
    );
    canvas.restore();
  }

  @override
  void drawPiece(Canvas canvas, Offset center, double size, Piece piece) {
    if (piece.fogged) {
      // Conceal the actual family without leaking the original tile colors.
      _draw(canvas, center, size, 'fog_overlay');
    } else if (piece.special != null) {
      final special = switch (piece.special!) {
        SpecialKind.rocket => 'butane_torch_lighter',
        SpecialKind.prism => 'prism',
        SpecialKind.cloudBomb => 'cloud_bomb',
      };
      final rotation = piece.special == SpecialKind.rocket &&
              piece.direction == RocketDirection.vertical
          ? math.pi / 2
          : 0.0;
      _draw(canvas, center, size, special, rotation: rotation);
    } else {
      final tile = switch (piece.family) {
        TileFamily.cloud => 'cloud_puff',
        TileFamily.leaf => 'mystic_bloom',
        TileFamily.sun => 'ember_drop',
        TileFamily.moon => 'dream_crystal',
        TileFamily.star => 'golden_nugget',
      };
      _draw(canvas, center, size, tile);
    }
    if (piece.stickySyrup) {
      _draw(canvas, center, size, 'sticky_syrup_overlay');
    }
  }

  @override
  void drawBlocker(
      Canvas canvas, Offset center, double size, BlockerState blocker) {
    final reinforced = blocker.kind == BlockerKind.reinforcedCrate;
    _draw(
        canvas, center, size, reinforced ? 'reinforced_mw_crate' : 'mw_crate');
    if (blocker.damaged) {
      // A damage cue remains legible independently of color or animation.
      final crack = Path()
        ..moveTo(center.dx - size * .2, center.dy - size * .24)
        ..lineTo(center.dx + size * .03, center.dy - size * .04)
        ..lineTo(center.dx - size * .08, center.dy + size * .12)
        ..lineTo(center.dx + size * .18, center.dy + size * .27);
      canvas.drawPath(
        crack,
        Paint()
          ..color = const Color(0xff3b2930)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * .05
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  void drawTurnEffects(
    Canvas canvas, {
    required BoardTurnEffectFrame event,
    required double cellSize,
  }) {
    final progress = event.progress.clamp(0.0, 1.0).toDouble();
    final cloudBombs = event.activatedSpecials.values
        .where((piece) => piece.special == SpecialKind.cloudBomb)
        .length;
    if (event.phase == BoardEffectPhase.gravity) {
      QaFrameTimingCollector.markCurrentRenderFrame('gravity_effect');
    } else if (cloudBombs > 0) {
      final phase = progress < .25
          ? 'onset'
          : progress < .75
              ? 'midpoint'
              : 'fade';
      QaFrameTimingCollector.markCurrentRenderFrame(
        event.reducedMotion ? 'reduced_cloud_bomb' : 'cloud_bomb_$phase',
      );
    } else if (event.activatedSpecials.isNotEmpty) {
      QaFrameTimingCollector.markCurrentRenderFrame('other_special_effect');
    } else {
      QaFrameTimingCollector.markCurrentRenderFrame('clear_effect');
    }
    if (event.phase == BoardEffectPhase.gravity) {
      if (event.reducedMotion || event.waveIndex == 0) return;
      final movedCells = <Cell>{
        ...event.movements.map((movement) => movement.destination),
        ...event.spawns.map((spawn) => spawn.destination),
      }.take(20).toList(growable: false);
      if (movedCells.isEmpty) return;
      final center = _centerOf(movedCells, cellSize);
      final envelope = math.sin(math.pi * progress).clamp(0.0, 1.0);
      final bounds = _boundsOf(movedCells, cellSize).inflate(cellSize * .18);
      canvas.save();
      canvas.clipRect(bounds);
      _draw(canvas, center, cellSize * 3.5, 'fx_cascade_streak',
          opacity: .34 * envelope);
      canvas.restore();
      return;
    }

    final cells = event.clearedCells.take(16).toList(growable: false);
    final changedConditionCells = event.conditionChanges.entries
        .where((entry) {
          final before = event.beforeWave.at(entry.key);
          return before != null &&
              (before.fogged != entry.value.fogged ||
                  before.stickySyrup != entry.value.stickySyrup);
        })
        .map((entry) => entry.key)
        .toList(growable: false);
    if (event.reducedMotion) {
      final fade = math.pow(1 - progress, .8).toDouble();
      final feedbackCells = <Cell>{...cells, ...changedConditionCells}.take(16);
      for (final cell in feedbackCells) {
        _draw(
          canvas,
          Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize),
          cellSize * .45,
          'fx_magic_sparkles',
          opacity: .64 * fade,
        );
      }
      return;
    }

    if (cells.isEmpty &&
        changedConditionCells.isEmpty &&
        event.blockerChanges.isEmpty &&
        event.createdSpecials.isEmpty) {
      return;
    }
    final smokeFrame = (progress * 3).floor().clamp(0, 2) + 1;
    final smokeKey = 'fx_white_smoke_0$smokeFrame';
    for (final cell in cells) {
      final center =
          Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize);
      _draw(canvas, center, cellSize * 1.08, smokeKey,
          opacity: .55 * (1 - progress * .35));
      _draw(canvas, center, cellSize * .58, 'fx_magic_sparkles',
          opacity: .72 * (1 - progress));
    }

    for (final entry in event.createdSpecials.entries.take(4)) {
      final center = Offset(
          (entry.key.col + .5) * cellSize, (entry.key.row + .5) * cellSize);
      _draw(canvas, center, cellSize * 1.15, 'fx_magic_sparkles',
          opacity: .9 * (1 - progress));
    }

    for (final entry in event.activatedSpecials.entries.take(4)) {
      final source = entry.key;
      final piece = entry.value;
      final center =
          Offset((source.col + .5) * cellSize, (source.row + .5) * cellSize);
      switch (piece.special) {
        case SpecialKind.rocket:
          final targets = cells.where((cell) =>
              piece.direction == RocketDirection.vertical
                  ? cell.col == source.col
                  : cell.row == source.row);
          if (targets.isNotEmpty) {
            final coords = targets.map((cell) =>
                Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize));
            final points = coords.toList(growable: false);
            final start = points.reduce((a, b) =>
                piece.direction == RocketDirection.vertical
                    ? (a.dy < b.dy ? a : b)
                    : (a.dx < b.dx ? a : b));
            final end = points.reduce((a, b) =>
                piece.direction == RocketDirection.vertical
                    ? (a.dy > b.dy ? a : b)
                    : (a.dx > b.dx ? a : b));
            final travel = 1 - math.pow(1 - progress, 3).toDouble();
            final trailEnd = Offset.lerp(start, end, travel)!;
            final trailAlpha = (.34 + .56 * math.sin(math.pi * progress))
                .clamp(0.0, 1.0)
                .toDouble();
            canvas.drawLine(
              start,
              trailEnd,
              Paint()
                ..color =
                    const Color(0xffff9e50).withValues(alpha: .28 * trailAlpha)
                ..strokeWidth = cellSize * .46
                ..strokeCap = StrokeCap.round,
            );
            canvas.drawLine(
              start,
              trailEnd,
              Paint()
                ..color =
                    const Color(0xffffc86e).withValues(alpha: .84 * trailAlpha)
                ..strokeWidth = cellSize * .17
                ..strokeCap = StrokeCap.round,
            );
            canvas.drawLine(
              start,
              trailEnd,
              Paint()
                ..color =
                    const Color(0xfffff5d4).withValues(alpha: .86 * trailAlpha)
                ..strokeWidth = cellSize * .055
                ..strokeCap = StrokeCap.round,
            );
            final headRadius = cellSize *
                (.17 + .06 * math.sin(math.pi * progress).clamp(0.0, 1.0));
            canvas.drawCircle(
              trailEnd,
              headRadius,
              Paint()
                ..color =
                    const Color(0xffffe5a1).withValues(alpha: .9 * trailAlpha),
            );
          }
        case SpecialKind.cloudBomb:
          final blastCells = cells
              .where((cell) =>
                  (cell.row - source.row).abs() <= 1 &&
                  (cell.col - source.col).abs() <= 1)
              .take(9);
          for (final cell in blastCells) {
            final target =
                Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize);
            final distance = math.sqrt(math.pow(cell.row - source.row, 2) +
                math.pow(cell.col - source.col, 2));
            final delay = distance / 4.25;
            final localProgress =
                ((progress - delay) / (1 - delay)).clamp(0.0, 1.0).toDouble();
            final fade = (1 - localProgress).clamp(0.0, 1.0).toDouble();
            final plumeSize = cellSize * (.72 + .4 * localProgress);
            _draw(canvas, target, plumeSize, smokeKey,
                opacity: .52 * fade, cloudBombSmoke: true);
          }
          final pulse = math.sin(math.pi * progress).clamp(0.0, 1.0);
          QaFrameTimingCollector.recordCurrentCanvasWork(vectorDraws: 1);
          canvas.drawCircle(
            center,
            cellSize * (.46 + 1.12 * progress),
            Paint()
              ..color = const Color(0xfff6fbff).withValues(alpha: .5 * pulse)
              ..style = PaintingStyle.stroke
              ..strokeWidth = cellSize * .065,
          );
        case SpecialKind.prism:
          final targetFamily = event.prismTargetFamily;
          if (targetFamily != null) {
            for (final cell in cells.where(
                (cell) => event.currentWave.at(cell)?.family == targetFamily)) {
              final target = Offset(
                  (cell.col + .5) * cellSize, (cell.row + .5) * cellSize);
              final pulse =
                  math.sin(math.pi * progress).clamp(0.0, 1.0).toDouble();
              final radius = cellSize * (.3 + .22 * progress);
              canvas.drawCircle(
                target,
                radius,
                Paint()
                  ..color =
                      _familyColor(targetFamily).withValues(alpha: .82 * pulse)
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = cellSize * .055,
              );
              _drawPrismGlint(canvas, target, radius, cellSize, pulse);
            }
          }
          _draw(canvas, center, cellSize * 1.9, 'fx_combo_ring',
              opacity: .62 * (1 - progress));
        case null:
          break;
      }
    }

    if (event.waveIndex > 0 || event.activatedSpecials.length > 1) {
      final comboCells = cells.isEmpty ? changedConditionCells : cells;
      if (comboCells.isNotEmpty) {
        _draw(canvas, _centerOf(comboCells, cellSize), cellSize * 3.4,
            'fx_combo_ring',
            opacity: .62 * (1 - progress));
      }
    }

    for (final cell in changedConditionCells.take(12)) {
      final previous = event.beforeWave.at(cell)!;
      final updated = event.conditionChanges[cell]!;
      final center =
          Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize);
      if (previous.fogged && !updated.fogged) {
        final reveal = _easeOut(progress);
        _draw(canvas, center, cellSize * (1.0 + .24 * reveal), smokeKey,
            opacity: .48 * (1 - progress));
        canvas.drawCircle(
          center,
          cellSize * (.34 + .46 * reveal),
          Paint()
            ..color =
                const Color(0xffe6f8ff).withValues(alpha: .55 * (1 - progress))
            ..style = PaintingStyle.stroke
            ..strokeWidth = cellSize * .045,
        );
      }
      if (previous.stickySyrup && !updated.stickySyrup) {
        final release = _easeOut(progress);
        final ring = Rect.fromCenter(
          center: center.translate(0, cellSize * (.2 + .14 * release)),
          width: cellSize * (.48 + .38 * release),
          height: cellSize * (.2 + .14 * release),
        );
        canvas.drawOval(
          ring,
          Paint()
            ..color =
                const Color(0xffffd77b).withValues(alpha: .78 * (1 - progress))
            ..style = PaintingStyle.stroke
            ..strokeWidth = cellSize * .055,
        );
        final glint = center.translate(cellSize * (-.24 + .48 * release),
            cellSize * (.17 - .34 * release));
        canvas.drawCircle(
          glint,
          cellSize * .045,
          Paint()
            ..color =
                const Color(0xfffff1c6).withValues(alpha: .78 * (1 - progress)),
        );
      }
    }

    for (final entry in event.blockerChanges.entries.take(8)) {
      final before = event.beforeWave.blockers[entry.key];
      final center = Offset(
          (entry.key.col + .5) * cellSize, (entry.key.row + .5) * cellSize);
      final envelope = math.sin(math.pi * progress).clamp(0.0, 1.0);
      final isBreak = entry.value == null;
      final reinforced = before?.kind == BlockerKind.reinforcedCrate;
      canvas.drawCircle(
        center,
        cellSize * (.32 + progress * (isBreak ? .52 : .28)),
        Paint()
          ..color = (isBreak
                  ? const Color(0xffffdda0)
                  : reinforced
                      ? const Color(0xffd7d8ee)
                      : const Color(0xfff1bd78))
              .withValues(alpha: .86 * envelope)
          ..style = PaintingStyle.stroke
          ..strokeWidth = cellSize * (reinforced ? .09 : .065),
      );
      final crack = Path()
        ..moveTo(center.dx - cellSize * .15, center.dy - cellSize * .2)
        ..lineTo(center.dx + cellSize * .015, center.dy - cellSize * .035)
        ..lineTo(center.dx - cellSize * .055, center.dy + cellSize * .065)
        ..lineTo(center.dx + cellSize * .16, center.dy + cellSize * .2);
      canvas.drawPath(
        crack,
        Paint()
          ..color = const Color(0xff34232c).withValues(
              alpha: isBreak ? .46 * (1 - progress) : .92 * envelope)
          ..style = PaintingStyle.stroke
          ..strokeWidth = cellSize * (reinforced ? .055 : .04)
          ..strokeCap = StrokeCap.round,
      );
      if (isBreak) _drawCrateSplinters(canvas, center, cellSize, progress);
    }
  }

  void _drawPrismGlint(Canvas canvas, Offset center, double radius,
      double cellSize, double pulse) {
    if (pulse <= 0) return;
    final offsets = [
      Offset(-radius, 0),
      Offset(0, -radius),
      Offset(radius, 0),
      Offset(0, radius),
    ];
    for (final offset in offsets) {
      final point = center + offset;
      final arm = cellSize * .055;
      final paint = Paint()
        ..color = const Color(0xfffff7da).withValues(alpha: .9 * pulse)
        ..strokeWidth = math.max(1.0, cellSize * .018)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(point.translate(-arm, 0), point.translate(arm, 0), paint);
      canvas.drawLine(point.translate(0, -arm), point.translate(0, arm), paint);
    }
  }

  void _drawCrateSplinters(
      Canvas canvas, Offset center, double cellSize, double progress) {
    final eased = _easeOut(progress);
    final offsets = [
      const Offset(-1, -.7),
      const Offset(.82, -.55),
      const Offset(-.7, .75),
      const Offset(.9, .62),
    ];
    final paint = Paint()
      ..color = const Color(0xffffdfaa).withValues(alpha: .82 * (1 - progress))
      ..strokeWidth = cellSize * .045
      ..strokeCap = StrokeCap.round;
    for (final offset in offsets) {
      final start = center.translate(
          offset.dx * cellSize * .11, offset.dy * cellSize * .11);
      final end = center.translate(offset.dx * cellSize * (.16 + .18 * eased),
          offset.dy * cellSize * (.16 + .18 * eased));
      canvas.drawLine(start, end, paint);
    }
  }

  double _easeOut(double value) => 1 - math.pow(1 - value, 3).toDouble();

  Rect _boundsOf(Iterable<Cell> cells, double cellSize) {
    final points = cells.map((cell) => _cellCenter(cell, cellSize)).toList();
    final left =
        points.map((point) => point.dx).reduce(math.min) - cellSize / 2;
    final right =
        points.map((point) => point.dx).reduce(math.max) + cellSize / 2;
    final top = points.map((point) => point.dy).reduce(math.min) - cellSize / 2;
    final bottom =
        points.map((point) => point.dy).reduce(math.max) + cellSize / 2;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  Offset _cellCenter(Cell cell, double cellSize) =>
      Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize);

  Offset _centerOf(Iterable<Cell> cells, double cellSize) {
    final list = cells.toList(growable: false);
    return Offset(
      list.map((cell) => (cell.col + .5) * cellSize).reduce((a, b) => a + b) /
          list.length,
      list.map((cell) => (cell.row + .5) * cellSize).reduce((a, b) => a + b) /
          list.length,
    );
  }

  Color _familyColor(TileFamily family) => switch (family) {
        TileFamily.cloud => const Color(0xff93dff1),
        TileFamily.leaf => const Color(0xff88dc98),
        TileFamily.sun => const Color(0xffffc36c),
        TileFamily.moon => const Color(0xffc4a5f3),
        TileFamily.star => const Color(0xffffef9d),
      };
}
