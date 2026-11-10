import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/game/board_sprite_renderer.dart';
import 'package:mr_weeds_cloud_kingdom/game/match3_png_board_renderer.dart';

List<List<Piece?>> _tiles() => List.generate(
      8,
      (row) => List.generate(
        8,
        (col) => Piece(TileFamily.values[(row + col) % 5]),
      ),
    );

BoardVisualSnapshot _snapshot({
  List<List<Piece?>>? tiles,
  Map<Cell, BlockerVisualState> blockers = const {},
}) =>
    BoardVisualSnapshot(tiles: tiles ?? _tiles(), blockers: blockers);

Future<Uint8List> _render(
  CloudKingdomPngBoardRenderer renderer,
  BoardTurnEffectFrame event,
) async {
  final recorder = ui.PictureRecorder();
  renderer.drawTurnEffects(Canvas(recorder), event: event, cellSize: 24);
  final picture = recorder.endRecording();
  final image = await picture.toImage(192, 192);
  picture.dispose();
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  } finally {
    image.dispose();
  }
}

BoardTurnEffectFrame _event({
  required BoardVisualSnapshot before,
  BoardVisualSnapshot? current,
  Set<Cell> cleared = const {},
  Map<Cell, Piece> created = const {},
  Map<Cell, Piece> activated = const {},
  Map<Cell, BlockerVisualState?> blockers = const {},
  Map<Cell, Piece> conditions = const {},
  TileFamily? prismTarget,
  int wave = 0,
  BoardEffectPhase phase = BoardEffectPhase.clearing,
  double progress = .5,
  List<TileMovement> movements = const [],
  List<TileSpawn> spawns = const [],
}) =>
    BoardTurnEffectFrame(
      clearedCells: cleared,
      createdSpecials: created,
      activatedSpecials: activated,
      blockerChanges: blockers,
      conditionChanges: conditions,
      beforeWave: before,
      currentWave: current ?? before,
      prismTargetFamily: prismTarget,
      waveIndex: wave,
      phase: phase,
      progress: progress,
      reducedMotion: false,
      movements: movements,
      spawns: spawns,
    );

int _alphaSum(Uint8List pixels) {
  var sum = 0;
  for (var index = 3; index < pixels.length; index += 4) {
    sum += pixels[index];
  }
  return sum;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Stage B effects remain localized to resolver-reported coverage',
      () async {
    final renderer = await CloudKingdomPngBoardRenderer.load();
    addTearDown(renderer.dispose);
    final before = _snapshot();
    final cleared = {for (var col = 1; col <= 5; col++) Cell(3, col)};

    final horizontalTorch = await _render(
      renderer,
      _event(
        before: before,
        cleared: cleared,
        activated: {
          Cell(3, 0): Piece(TileFamily.sun,
              special: SpecialKind.rocket,
              direction: RocketDirection.horizontal),
        },
      ),
    );
    final verticalTorch = await _render(
      renderer,
      _event(
        before: before,
        cleared: cleared,
        activated: {
          Cell(3, 0): Piece(TileFamily.sun,
              special: SpecialKind.rocket, direction: RocketDirection.vertical),
        },
      ),
    );
    expect(horizontalTorch, isNot(equals(verticalTorch)),
        reason: 'Torch line direction comes from the activated engine piece.');

    final bomb = await _render(
      renderer,
      _event(
        before: before,
        cleared: {Cell(3, 3), Cell(3, 4), Cell(4, 3), Cell(4, 4)},
        activated: {
          Cell(3, 3): Piece(TileFamily.star, special: SpecialKind.cloudBomb),
        },
      ),
    );
    expect(_alphaSum(bomb), greaterThan(0));
    expect(bomb, isNot(equals(horizontalTorch)));

    final prismTiles = _tiles();
    prismTiles[3][3] = const Piece(TileFamily.moon);
    prismTiles[3][4] = const Piece(TileFamily.moon);
    prismTiles[4][3] = const Piece(TileFamily.star);
    final prismBefore = _snapshot(tiles: prismTiles);
    final moonPrism = await _render(
      renderer,
      _event(
        before: prismBefore,
        current: prismBefore,
        cleared: {Cell(3, 3), Cell(3, 4), Cell(4, 3)},
        activated: {
          Cell(2, 3): Piece(TileFamily.cloud, special: SpecialKind.prism),
        },
        prismTarget: TileFamily.moon,
      ),
    );
    final starPrism = await _render(
      renderer,
      _event(
        before: prismBefore,
        current: prismBefore,
        cleared: {Cell(3, 3), Cell(3, 4), Cell(4, 3)},
        activated: {
          Cell(2, 3): Piece(TileFamily.cloud, special: SpecialKind.prism),
        },
        prismTarget: TileFamily.star,
      ),
    );
    expect(moonPrism, isNot(equals(starPrism)),
        reason: 'Prism highlighting uses the exact traced target family.');
  });

  test('crate stages and Fog/Syrup cues require actual state-change events',
      () async {
    final renderer = await CloudKingdomPngBoardRenderer.load();
    addTearDown(renderer.dispose);
    const crateCell = Cell(3, 3);
    final crateBefore = _snapshot(blockers: {
      crateCell: BlockerVisualState(BlockerKind.reinforcedCrate, 2),
    });
    final damaged = await _render(
      renderer,
      _event(
        before: crateBefore,
        blockers: {
          crateCell: BlockerVisualState(BlockerKind.reinforcedCrate, 1),
        },
      ),
    );
    final broken = await _render(
      renderer,
      _event(before: crateBefore, blockers: {crateCell: null}),
    );
    expect(damaged, isNot(equals(broken)),
        reason: 'Damage and break states receive distinct presentation cues.');

    const conditionCell = Cell(2, 2);
    final foggedTiles = _tiles();
    foggedTiles[2][2] = const Piece(
      TileFamily.cloud,
      fogged: true,
      stickySyrup: true,
    );
    final changedTiles = _tiles();
    changedTiles[2][2] = const Piece(TileFamily.cloud);
    final fogSyrupBefore = _snapshot(tiles: foggedTiles);
    final after = _snapshot(tiles: changedTiles);
    final revealAndRelease = await _render(
      renderer,
      _event(
        before: fogSyrupBefore,
        current: after,
        conditions: {conditionCell: const Piece(TileFamily.cloud)},
      ),
    );
    final noConditionEvent = await _render(
      renderer,
      _event(before: fogSyrupBefore, current: after),
    );
    expect(_alphaSum(revealAndRelease), greaterThan(0));
    expect(_alphaSum(noConditionEvent), 0,
        reason:
            'Fog and Syrup do not reveal before a traced condition change.');
  });

  test(
      'cascade celebration tracks actual landing cells and reduced motion omits it',
      () async {
    final renderer = await CloudKingdomPngBoardRenderer.load();
    addTearDown(renderer.dispose);
    final before = _snapshot();
    final early = await _render(
      renderer,
      _event(
        before: before,
        wave: 1,
        phase: BoardEffectPhase.gravity,
        progress: .25,
        movements: const [
          TileMovement(
            source: Cell(1, 1),
            destination: Cell(4, 1),
            piece: Piece(TileFamily.cloud),
            segmentTop: 0,
            segmentBottom: 7,
          ),
        ],
      ),
    );
    final late = await _render(
      renderer,
      _event(
        before: before,
        wave: 1,
        phase: BoardEffectPhase.gravity,
        progress: .5,
        movements: const [
          TileMovement(
            source: Cell(1, 1),
            destination: Cell(4, 1),
            piece: Piece(TileFamily.cloud),
            segmentTop: 0,
            segmentBottom: 7,
          ),
        ],
      ),
    );
    expect(_alphaSum(early), greaterThan(0));
    expect(early, isNot(equals(late)));

    final reduced = await _render(
      renderer,
      _event(
        before: before,
        wave: 1,
        phase: BoardEffectPhase.gravity,
        movements: const [
          TileMovement(
            source: Cell(1, 1),
            destination: Cell(4, 1),
            piece: Piece(TileFamily.cloud),
            segmentTop: 0,
            segmentBottom: 7,
          ),
        ],
      ).copyWithReducedMotion(true),
    );
    expect(_alphaSum(reduced), 0);
  });
}

extension on BoardTurnEffectFrame {
  BoardTurnEffectFrame copyWithReducedMotion(bool value) =>
      BoardTurnEffectFrame(
        clearedCells: clearedCells,
        createdSpecials: createdSpecials,
        activatedSpecials: activatedSpecials,
        blockerChanges: blockerChanges,
        conditionChanges: conditionChanges,
        beforeWave: beforeWave,
        currentWave: currentWave,
        prismTargetFamily: prismTargetFamily,
        waveIndex: waveIndex,
        phase: phase,
        progress: progress,
        reducedMotion: value,
        movements: movements,
        spawns: spawns,
      );
}
