import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/game/board_sprite_renderer.dart';

void main() {
  test('fallback renderer paints every tile, condition, and special state', () {
    const renderer = CloudKingdomFallbackBoardRenderer();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (final family in TileFamily.values) {
      renderer.drawPiece(canvas, const Offset(50, 50), 40, Piece(family));
    }
    renderer.drawPiece(
      canvas,
      const Offset(100, 50),
      40,
      const Piece(TileFamily.cloud, fogged: true),
    );
    renderer.drawPiece(
      canvas,
      const Offset(150, 50),
      40,
      const Piece(TileFamily.sun, stickySyrup: true),
    );
    for (final special in SpecialKind.values) {
      renderer.drawPiece(
        canvas,
        const Offset(200, 50),
        40,
        Piece(special == SpecialKind.rocket ? TileFamily.sun : TileFamily.star,
            special: special,
            direction: special == SpecialKind.rocket
                ? RocketDirection.vertical
                : null),
      );
    }

    recorder.endRecording().dispose();
  });

  test('fallback renderer paints both crate states', () {
    const renderer = CloudKingdomFallbackBoardRenderer();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final crate = BlockerState(BlockerKind.crate);
    final reinforced = BlockerState(BlockerKind.reinforcedCrate)..takeHit();

    renderer.drawBlocker(canvas, const Offset(50, 50), 40, crate);
    renderer.drawBlocker(canvas, const Offset(100, 50), 40, reinforced);

    recorder.endRecording().dispose();
  });
}
