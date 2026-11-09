import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../domain/match3.dart';
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
      {double rotation = 0, double opacity = 1}) {
    final image = _images[key];
    if (image == null) return;
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
    if (event.phase == BoardEffectPhase.gravity) {
      if (event.reducedMotion || event.waveIndex == 0) return;
      final movedCells = <Cell>{
        ...event.clearedCells,
        ...event.createdSpecials.keys,
      }.take(16).toList(growable: false);
      if (movedCells.isEmpty) return;
      final center = _centerOf(movedCells, cellSize);
      _draw(canvas, center, cellSize * 4.2, 'fx_cascade_streak',
          opacity: .45 * math.sin(math.pi * progress));
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
      final fade = math.pow(1 - progress, 1.4).toDouble();
      final feedbackCells = <Cell>{...cells, ...changedConditionCells}.take(16);
      for (final cell in feedbackCells) {
        _draw(
          canvas,
          Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize),
          cellSize * .45,
          'fx_magic_sparkles',
          opacity: .42 * fade,
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
            canvas.drawLine(
              start,
              trailEnd,
              Paint()
                ..color = const Color(0xffffbf65).withValues(alpha: .8)
                ..strokeWidth = cellSize * .27
                ..strokeCap = StrokeCap.round,
            );
            canvas.drawLine(
              start,
              trailEnd,
              Paint()
                ..color = const Color(0xfffff1c5).withValues(alpha: .78)
                ..strokeWidth = cellSize * .09
                ..strokeCap = StrokeCap.round,
            );
          }
        case SpecialKind.cloudBomb:
          _draw(canvas, center, cellSize * 3.3, smokeKey,
              opacity: .62 * (1 - progress));
        case SpecialKind.prism:
          final targetFamily = event.prismTargetFamily;
          if (targetFamily != null) {
            for (final cell in cells.where(
                (cell) => event.currentWave.at(cell)?.family == targetFamily)) {
              final target = Offset(
                  (cell.col + .5) * cellSize, (cell.row + .5) * cellSize);
              final pulse = .45 + .5 * math.sin(math.pi * progress);
              canvas.drawCircle(
                target,
                cellSize * (.42 + .16 * progress),
                Paint()
                  ..color = _familyColor(targetFamily).withValues(alpha: pulse)
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = cellSize * .09,
              );
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

    for (final cell in changedConditionCells) {
      final previous = event.beforeWave.at(cell)!;
      final updated = event.conditionChanges[cell]!;
      final center =
          Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize);
      if (previous.fogged && !updated.fogged) {
        _draw(canvas, center, cellSize * 1.1, smokeKey,
            opacity: .55 * (1 - progress));
      }
      if (previous.stickySyrup && !updated.stickySyrup) {
        canvas.drawCircle(
          center,
          cellSize * (.3 + .3 * progress),
          Paint()
            ..color =
                const Color(0xffffd77b).withValues(alpha: .72 * (1 - progress))
            ..style = PaintingStyle.stroke
            ..strokeWidth = cellSize * .07,
        );
      }
    }

    for (final entry in event.blockerChanges.entries.take(8)) {
      final center = Offset(
          (entry.key.col + .5) * cellSize, (entry.key.row + .5) * cellSize);
      canvas.drawCircle(
        center,
        cellSize * (.35 + progress * .18),
        Paint()
          ..color = (entry.value == null
                  ? const Color(0xffffe0a0)
                  : const Color(0xfff5c47d))
              .withValues(alpha: .75 * (1 - progress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = cellSize * .07,
      );
    }
  }

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
