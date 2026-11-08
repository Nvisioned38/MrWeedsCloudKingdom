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
    required Iterable<Cell> changedCells,
    required int cascadeCount,
    required double cellSize,
    required double progress,
    required bool reducedMotion,
  }) {
    final cells = changedCells.take(4).toList(growable: false);
    if (cells.isEmpty) return;

    if (reducedMotion) {
      for (final cell in cells) {
        _draw(
          canvas,
          Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize),
          cellSize * .45,
          'fx_magic_sparkles',
          opacity: .42,
        );
      }
      return;
    }

    final smokeFrame = (progress * 3).floor().clamp(0, 2) + 1;
    final smokeKey = 'fx_white_smoke_0$smokeFrame';
    for (final cell in cells) {
      final center =
          Offset((cell.col + .5) * cellSize, (cell.row + .5) * cellSize);
      _draw(canvas, center, cellSize * 1.12, smokeKey, opacity: .6);
      _draw(canvas, center, cellSize * .62, 'fx_magic_sparkles', opacity: .78);
    }

    if (cascadeCount > 1) {
      final center = Offset(
        cells
                .map((cell) => (cell.col + .5) * cellSize)
                .reduce((a, b) => a + b) /
            cells.length,
        cells
                .map((cell) => (cell.row + .5) * cellSize)
                .reduce((a, b) => a + b) /
            cells.length,
      );
      _draw(canvas, center, cellSize * 4.6, 'fx_combo_ring', opacity: .72);
      _draw(
        canvas,
        Offset(cellSize * 4, cellSize * .56),
        cellSize * 6.2,
        'fx_cascade_streak',
        opacity: .6,
      );
    }
  }
}
