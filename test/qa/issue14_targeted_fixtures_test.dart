import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/game/board_sprite_renderer.dart';
import 'package:mr_weeds_cloud_kingdom/game/cloud_board_game.dart';
import 'package:mr_weeds_cloud_kingdom/game/match3_png_board_renderer.dart';
import 'package:mr_weeds_cloud_kingdom/main.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/match3_art_widgets.dart';

List<List<Piece?>> fixtureTiles({bool includeSpecials = false}) =>
    List.generate(8, (row) {
      return List.generate(8, (col) {
        final family =
            TileFamily.values[(row + col) % TileFamily.values.length];
        if (includeSpecials && row == 0 && col == 0) {
          return const Piece(TileFamily.sun,
              special: SpecialKind.rocket,
              direction: RocketDirection.horizontal);
        }
        if (includeSpecials && row == 0 && col == 1) {
          return const Piece(TileFamily.moon, special: SpecialKind.prism);
        }
        if (includeSpecials && row == 0 && col == 2) {
          return const Piece(TileFamily.star, special: SpecialKind.cloudBomb);
        }
        return Piece(family);
      });
    });

LevelSpec fixtureLevel({int moves = 30}) => LevelSpec(
      id: 1,
      name: 'QA Fixture',
      seed: 1401,
      moves: moves,
      objectives: const [
        ObjectiveDefinition(kind: ObjectiveKind.score, target: 30),
      ],
      blockers: const [],
      coins: 100,
    );

Future<Uint8List> renderPiece(
  CloudKingdomPngBoardRenderer renderer,
  Piece piece,
) async {
  final recorder = ui.PictureRecorder();
  renderer.drawPiece(Canvas(recorder), const Offset(64, 64), 108, piece);
  final picture = recorder.endRecording();
  final image = await picture.toImage(128, 128);
  picture.dispose();
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
  } finally {
    image.dispose();
  }
}

Future<Uint8List> renderEffects(
  CloudKingdomPngBoardRenderer renderer, {
  required double progress,
  required int waveIndex,
  required bool reducedMotion,
  Piece? activatedSpecial,
}) async {
  final cells = {Cell(3, 3), Cell(3, 4)};
  final tiles = fixtureTiles();
  if (activatedSpecial != null) tiles[3][3] = activatedSpecial;
  final snapshot = BoardVisualSnapshot(tiles: tiles, blockers: const {});
  final recorder = ui.PictureRecorder();
  renderer.drawTurnEffects(
    Canvas(recorder),
    cellSize: 24,
    event: BoardTurnEffectFrame(
      clearedCells: cells,
      createdSpecials: const {},
      activatedSpecials:
          activatedSpecial == null ? const {} : {Cell(3, 3): activatedSpecial},
      blockerChanges: const {},
      conditionChanges: const {},
      beforeWave: snapshot,
      currentWave: snapshot,
      prismTargetFamily: activatedSpecial?.special == SpecialKind.prism
          ? TileFamily.moon
          : null,
      waveIndex: waveIndex,
      phase: BoardEffectPhase.clearing,
      progress: progress,
      reducedMotion: reducedMotion,
    ),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(192, 192);
  picture.dispose();
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
  } finally {
    image.dispose();
  }
}

int alphaSum(Uint8List rgba) {
  var sum = 0;
  for (var index = 3; index < rgba.length; index += 4) {
    sum += rgba[index];
  }
  return sum;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('approved PNG fixture renders Fog, Syrup, damage, Torch, and effects',
      () async {
    final renderer = await CloudKingdomPngBoardRenderer.load();
    addTearDown(renderer.dispose);

    final fogOnCloud = await renderPiece(
      renderer,
      const Piece(TileFamily.cloud, fogged: true),
    );
    final fogOnNugget = await renderPiece(
      renderer,
      const Piece(TileFamily.star, fogged: true),
    );
    expect(fogOnCloud, equals(fogOnNugget),
        reason: 'Fog conceals tile identity until a qualifying clear.');

    final fogAndSyrup = await renderPiece(
      renderer,
      const Piece(TileFamily.cloud, fogged: true, stickySyrup: true),
    );
    expect(fogAndSyrup, isNot(equals(fogOnCloud)),
        reason: 'Sticky Syrup is composited above the Fog tile overlay.');

    final torchHorizontal = await renderPiece(
      renderer,
      const Piece(TileFamily.sun,
          special: SpecialKind.rocket, direction: RocketDirection.horizontal),
    );
    final torchVertical = await renderPiece(
      renderer,
      const Piece(TileFamily.sun,
          special: SpecialKind.rocket, direction: RocketDirection.vertical),
    );
    expect(torchHorizontal, isNot(equals(torchVertical)),
        reason: 'The Torch sprite distinguishes its row/column direction.');

    final intact = BlockerState(BlockerKind.reinforcedCrate);
    final damaged = intact.copy()..takeHit();
    final intactPixels = await renderBlocker(renderer, intact);
    final damagedPixels = await renderBlocker(renderer, damaged);
    expect(damagedPixels, isNot(equals(intactPixels)),
        reason: 'Reinforced crate damage has a visible crack cue.');

    final earlySmoke = await renderEffects(
      renderer,
      progress: .1,
      waveIndex: 0,
      reducedMotion: false,
    );
    final lateSmoke = await renderEffects(
      renderer,
      progress: .8,
      waveIndex: 0,
      reducedMotion: false,
    );
    final combo = await renderEffects(
      renderer,
      progress: .1,
      waveIndex: 1,
      reducedMotion: false,
    );
    final reduced = await renderEffects(
      renderer,
      progress: .1,
      waveIndex: 1,
      reducedMotion: true,
    );
    final reducedAtHalf = await renderEffects(
      renderer,
      progress: .5,
      waveIndex: 1,
      reducedMotion: true,
    );
    final reducedAtEnd = await renderEffects(
      renderer,
      progress: 1,
      waveIndex: 1,
      reducedMotion: true,
    );
    expect(lateSmoke, isNot(equals(earlySmoke)),
        reason: 'White-smoke sequence advances across animation progress.');
    expect(combo, isNot(equals(earlySmoke)),
        reason: 'Cascade count >1 adds the approved combo/cascade layer.');
    expect(reduced, isNot(equals(combo)),
        reason: 'Reduced Motion uses the static sparkle alternative.');
    expect(reduced.any((channel) => channel != 0), isTrue);
    expect(alphaSum(reducedAtHalf), greaterThan(0),
        reason: 'Reduced Motion feedback remains visible midway through fade.');
    expect(alphaSum(reducedAtHalf), lessThan(alphaSum(reduced)),
        reason: 'Reduced Motion sparkle fades smoothly over time.');
    expect(alphaSum(reducedAtEnd), 0,
        reason: 'Reduced Motion feedback is gone at the end of its interval.');

    final bomb = await renderEffects(
      renderer,
      progress: .2,
      waveIndex: 0,
      reducedMotion: false,
      activatedSpecial:
          const Piece(TileFamily.star, special: SpecialKind.cloudBomb),
    );
    expect(bomb, isNot(equals(earlySmoke)),
        reason: 'Bomb smoke is keyed to an actual triggered-special event.');
  });

  testWidgets(
      'special guide exposes disabled, pressed, and selected art states',
      (tester) async {
    void expectBoosterState(String key, String state) {
      expect(
        find.byKey(ValueKey('issue4-booster-$key-booster_button_$state.png')),
        findsOneWidget,
      );
    }

    Widget guide({required bool withSpecials}) {
      final level = fixtureLevel();
      return MaterialApp(
        home: Scaffold(
          body: Match3SpecialsGuide(
            session: LevelSession(
              level,
              initialTiles: fixtureTiles(includeSpecials: withSpecials),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(guide(withSpecials: false));
    await tester.tap(find.text('Specials guide'));
    await tester.pumpAndSettle();
    expectBoosterState('torch', 'disabled');
    final disabledSemantics = tester.widget<Semantics>(find.ancestor(
      of: find.byKey(const ValueKey('issue4-special-torch')),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Torch special',
      ),
    ));
    expect(disabledSemantics.properties.enabled, isFalse);
    expect(disabledSemantics.properties.onTap, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(guide(withSpecials: true));
    await tester.tap(find.text('Specials guide'));
    await tester.pumpAndSettle();
    expectBoosterState('torch', 'normal');
    expectBoosterState('prism', 'normal');
    expectBoosterState('cloud-bomb', 'normal');

    final prism = find.byKey(const ValueKey('issue4-special-prism'));
    final gesture = await tester.startGesture(tester.getCenter(prism));
    await tester.pump(const Duration(milliseconds: 120));
    expectBoosterState('prism', 'pressed');
    await gesture.up();
    await tester.pumpAndSettle();
    expectBoosterState('prism', 'selected');
    final selectedSemantics = tester.widget<Semantics>(find.ancestor(
      of: prism,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Prism special',
      ),
    ));
    expect(selectedSemantics.properties.enabled, isTrue);
    expect(selectedSemantics.properties.selected, isTrue);
    expect(selectedSemantics.properties.onTap, isNotNull);

    expect(find.byKey(const ValueKey('issue4-vaporizer-art')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('issue4-cloud-cup-logo-overlay')),
      findsOneWidget,
      reason: 'The canonical Cloud Cup logo remains a separate overlay.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing approved PNG keeps the board on safe playable fallback',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final failedLoadHandled = Completer<void>();
    final level = fixtureLevel();
    final session = LevelSession(level, initialTiles: fixtureTiles());
    await tester.pumpWidget(MaterialApp(
      home: PlayScreen(
        level: level,
        progress: ProgressState(),
        persist: () async {},
        initialSession: session,
        approvedArtLoader: () async {
          try {
            return await CloudKingdomPngBoardRenderer.load(
              assetResolver: (String path) async {
                if (path.endsWith('/cloud_puff.png')) {
                  throw StateError('QA fixture: missing Cloud Puff PNG');
                }
                return rootBundle.load(path);
              },
            );
          } catch (_) {
            failedLoadHandled.complete();
            rethrow;
          }
        },
      ),
    ));
    await tester.runAsync(() => failedLoadHandled.future);
    await tester.pump();
    final game = tester
        .widget<GameWidget>(find.byKey(const ValueKey('match3-board')))
        .game as CloudBoardGame;
    expect(game.spriteRenderer, isA<CloudKingdomFallbackBoardRenderer>());
    expect(
      find.byWidgetPredicate((widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith('board-cell-')),
      findsNWidgets(64),
    );
    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey('board-cell-0-0'))),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(game.selectedCell, const Cell(0, 0));
    expect(tester.takeException(), isNull);
  });

  test('fresh QA progress grants first-clear reward once across restoration',
      () async {
    final data = jsonDecode(
      await File('assets/data/levels_001_030.json').readAsString(),
    ) as Map<String, dynamic>;
    final levels = (data['levels'] as List)
        .cast<Map<String, dynamic>>()
        .map(LevelSpec.fromJson);
    final level = levels.firstWhere((candidate) => candidate.id == 1);

    // New ProgressState is a disposable QA fixture; no device or shared save
    // store is opened, reset, or changed by this test.
    final fresh = ProgressState();
    final firstClear = fresh.grantFirstClear(level, 1020);
    expect(firstClear.firstClear, isTrue);
    expect(firstClear.coins, 100);
    expect(firstClear.stars, 1);
    expect(firstClear.collectionXp, 6);

    final restored = ProgressState.fromJson(fresh.toJson());
    final replay = restored.grantFirstClear(level, 1500);
    expect(replay.firstClear, isFalse);
    expect(replay.coins, 0);
    expect(replay.stars, 0);
    expect(replay.collectionXp, 0);
    expect(restored.coins, 100);
    expect(restored.starLevelIds, {1});
    expect(restored.collectionXp, 6);
    expect(restored.bestScores[1], 1500);
  });
}

Future<Uint8List> renderBlocker(
  CloudKingdomPngBoardRenderer renderer,
  BlockerState blocker,
) async {
  final recorder = ui.PictureRecorder();
  renderer.drawBlocker(Canvas(recorder), const Offset(64, 64), 108, blocker);
  final picture = recorder.endRecording();
  final image = await picture.toImage(128, 128);
  picture.dispose();
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
  } finally {
    image.dispose();
  }
}
