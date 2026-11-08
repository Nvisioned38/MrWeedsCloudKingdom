import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../domain/match3.dart';
import 'board_sprite_renderer.dart';

/// Draws the owner-approved Issue #4 PNGs without changing Match-3 logic.
///
/// All original pixel files are verified against the art approval manifests
/// during CI. The renderer only controls presentation: legacy TileFamily and
/// SpecialKind identifiers remain unchanged for deterministic save continuity.
class CloudKingdomPngBoardRenderer implements BoardSpriteRenderer {
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
  ];

  static Future<CloudKingdomPngBoardRenderer> load() async {
    final images = <String, ui.Image>{};
    for (final key in _required) {
      final bytes = await rootBundle.load('$_assetRoot$key.png');
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
    return CloudKingdomPngBoardRenderer._(images);
  }

  void _draw(Canvas canvas, Offset center, double size, String key,
      {double rotation = 0}) {
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
      Paint()..filterQuality = FilterQuality.medium,
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
    _draw(canvas, center, size,
        reinforced ? 'reinforced_mw_crate' : 'mw_crate');
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
}