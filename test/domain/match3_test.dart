import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';

LevelSpec level({
  int seed = 19,
  int moves = 20,
  List<ObjectiveDefinition> objectives = const [
    ObjectiveDefinition(kind: ObjectiveKind.score, target: 99999)
  ],
  List<BlockerDefinition> blockers = const [],
  int coins = 100,
}) =>
    LevelSpec(
        id: 1,
        name: 'Test',
        seed: seed,
        moves: moves,
        objectives: objectives,
        blockers: blockers,
        coins: coins);

List<List<Piece?>> boardFixture() {
  final grid = List.generate(
      8, (r) => List.generate(8, (c) => Piece(TileFamily.values[(r + c) % 5])));
  grid[0][0] = const Piece(TileFamily.cloud);
  grid[0][1] = const Piece(TileFamily.leaf);
  grid[0][2] = const Piece(TileFamily.cloud);
  grid[1][1] = const Piece(TileFamily.cloud);
  return grid;
}

void main() {
  group('seeded board and turn pipeline', () {
    test('has no starting match and at least one legal move', () {
      final board = Match3Board(level: level());
      expect(board.findMatches(), isEmpty);
      expect(board.hasLegalMove, isTrue);
    });

    test('invalid swaps roll back and do not consume moves', () {
      final session = LevelSession(level(), initialTiles: boardFixture());
      final before = session.board.fingerprint;
      final result = session.swap(const Cell(0, 0), const Cell(0, 1));
      expect(result.accepted, isFalse);
      expect(session.board.fingerprint, before);
      expect(session.movesUsed, 0);
    });

    test('valid swap resolves a match and gravity refills the board', () {
      final session = LevelSession(level(), initialTiles: boardFixture());
      final result = session.swap(const Cell(0, 1), const Cell(1, 1));
      expect(result.accepted, isTrue);
      expect(result.cleared.length, greaterThanOrEqualTo(3));
      expect(session.board.score, greaterThan(0));
      expect(session.movesUsed, 1);
      expect(session.board.findMatches(), isEmpty);
      for (var row = 0; row < 8; row++) {
        for (var col = 0; col < 8; col++) {
          if (session.board.blockerAt(row, col) == null) {
            expect(session.board.at(row, col), isNotNull);
          }
        }
      }
    });

    test('optional event trace preserves invalid and accepted engine results',
        () {
      final plainInvalid = LevelSession(level(), initialTiles: boardFixture());
      final tracedInvalid = LevelSession(level(), initialTiles: boardFixture());
      final invalidBefore = tracedInvalid.board.fingerprint;
      LevelTurnAnimationTrace? rejectedTrace;
      final rejected = tracedInvalid.swap(
        const Cell(0, 0),
        const Cell(0, 1),
        onAnimationTrace: (trace) => rejectedTrace = trace,
      );
      expect(rejected.accepted, isFalse);
      expect(plainInvalid.swap(const Cell(0, 0), const Cell(0, 1)).accepted,
          isFalse);
      expect(rejectedTrace, isNotNull);
      expect(rejectedTrace!.boardTrace.accepted, isFalse);
      expect(rejectedTrace!.boardTrace.waves, isEmpty);
      expect(tracedInvalid.board.fingerprint, invalidBefore);
      expect(tracedInvalid.board.fingerprint, plainInvalid.board.fingerprint);
      expect(tracedInvalid.movesUsed, 0);

      final plain = LevelSession(level(), initialTiles: boardFixture());
      final traced = LevelSession(level(), initialTiles: boardFixture());
      LevelTurnAnimationTrace? acceptedTrace;
      final expected = plain.swap(const Cell(0, 1), const Cell(1, 1));
      final actual = traced.swap(
        const Cell(0, 1),
        const Cell(1, 1),
        onAnimationTrace: (trace) => acceptedTrace = trace,
      );
      expect(actual.accepted, expected.accepted);
      expect(actual.cleared, expected.cleared);
      expect(actual.scoreGained, expected.scoreGained);
      expect(actual.cascadeCount, expected.cascadeCount);
      expect(traced.board.fingerprint, plain.board.fingerprint);
      expect(traced.board.score, plain.board.score);
      expect(traced.movesUsed, plain.movesUsed);
      expect(traced.outcome, plain.outcome);
      expect(
        traced.objectives.map((item) => item.value),
        plain.objectives.map((item) => item.value),
      );
      final trace = acceptedTrace!.boardTrace;
      expect(trace.accepted, isTrue);
      expect(trace.waves, isNotEmpty);
      expect(trace.waves.first.clearedPieces.keys,
          containsAll([const Cell(0, 0), const Cell(0, 1), const Cell(0, 2)]));
      expect(trace.waves.first.spawns, isNotEmpty);
      expect(
        trace.waves.first.spawns.every((spawn) =>
            spawn.origin == spawn.segmentTop - 1 &&
            spawn.destination.row >= spawn.segmentTop &&
            spawn.destination.row <= spawn.segmentBottom),
        isTrue,
      );
      expect(trace.after.at(const Cell(0, 1)), traced.board.at(0, 1));
      expect(acceptedTrace!.outcome, traced.outcome);
    });

    test('trace records cascades in actual resolution order with parity', () {
      var found = false;
      for (var seed = 1; seed <= 100 && !found; seed++) {
        final plain = Match3Board(level: level(seed: seed));
        final traced = Match3Board(level: level(seed: seed));
        for (var row = 0; row < 8 && !found; row++) {
          for (var col = 0; col < 8 && !found; col++) {
            for (final next in [Cell(row, col + 1), Cell(row + 1, col)]) {
              if (next.row >= 8 || next.col >= 8) continue;
              final expected = plain.resolveSwap(Cell(row, col), next);
              TurnAnimationTrace? trace;
              final actual = traced.resolveSwap(
                Cell(row, col),
                next,
                onAnimationTrace: (value) => trace = value,
              );
              expect(actual.accepted, expected.accepted);
              expect(actual.cleared, expected.cleared);
              expect(actual.collectedTiles, expected.collectedTiles);
              expect(actual.scoreGained, expected.scoreGained);
              expect(actual.createdSpecials, expected.createdSpecials);
              expect(
                  actual.createdPieces.length, expected.createdPieces.length);
              expect(actual.destroyedBlockers, expected.destroyedBlockers);
              expect(actual.cascadeCount, expected.cascadeCount);
              expect(actual.changedCells, expected.changedCells);
              expect(traced.fingerprint, plain.fingerprint);
              expect(traced.score, plain.score);
              if (actual.accepted && actual.cascadeCount > 1) {
                expect(trace!.waves.length, actual.cascadeCount);
                expect(trace!.waves.any((wave) => wave.movements.isNotEmpty),
                    isTrue);
                expect(
                    trace!.waves.any((wave) => wave.spawns.isNotEmpty), isTrue);
                expect(
                  trace!.waves.expand((wave) => wave.movements).every((move) =>
                      move.source.row >= move.segmentTop &&
                      move.source.row <= move.segmentBottom &&
                      move.destination.row >= move.segmentTop &&
                      move.destination.row <= move.segmentBottom),
                  isTrue,
                );
                expect(trace!.waves.last.afterGravity.tiles,
                    equals(trace!.after.tiles));
                expect(
                    trace!.waves.every((wave) => wave.movements.every(
                        (movement) =>
                            movement.piece ==
                            wave.afterGravity.at(movement.destination))),
                    isTrue);
                found = true;
              }
              if (actual.accepted) break;
            }
          }
        }
      }
      expect(found, isTrue, reason: 'A seeded cascade must be traceable.');
    });

    test('refill and cascades replay deterministically', () {
      var foundCascade = false;
      for (var seed = 1; seed <= 100 && !foundCascade; seed++) {
        final a = Match3Board(level: level(seed: seed));
        final b = Match3Board(level: level(seed: seed));
        for (var row = 0; row < 8 && !foundCascade; row++) {
          for (var col = 0; col < 8 && !foundCascade; col++) {
            for (final next in [Cell(row, col + 1), Cell(row + 1, col)]) {
              if (next.row >= 8 || next.col >= 8) continue;
              final first = a.resolveSwap(Cell(row, col), next);
              final second = b.resolveSwap(Cell(row, col), next);
              expect(first.accepted, second.accepted);
              if (first.accepted) {
                expect(first.cleared, second.cleared);
                expect(a.fingerprint, b.fingerprint);
                expect(a.score, b.score);
                if (first.cascadeCount > 1) foundCascade = true;
                break;
              }
            }
          }
        }
      }
      expect(foundCascade, isTrue,
          reason:
              'The deterministic seed sweep should exercise a refill cascade.');
    });

    test('dead-board shuffle restores a legal, match-free board', () {
      final dead = List.generate(
          8,
          (r) =>
              List.generate(8, (c) => Piece(TileFamily.values[(r + c) % 5])));
      final board = Match3Board(level: level(seed: 90), initialTiles: dead);
      expect(board.findMatches(), isEmpty);
      expect(board.hasLegalMove, isFalse);
      board.shuffleUntilPlayable();
      expect(board.findMatches(), isEmpty);
      expect(board.hasLegalMove, isTrue);
    });
  });

  group('blockers and specials', () {
    test('standard Crate is destroyed by an adjacent match', () {
      final crate = const BlockerDefinition(Cell(0, 3), BlockerKind.crate);
      final session = LevelSession(
          level(blockers: [
            crate
          ], objectives: const [
            ObjectiveDefinition(
                kind: ObjectiveKind.destroyBlockers,
                blocker: BlockerKind.crate,
                target: 1)
          ]),
          initialTiles: boardFixture());
      final result = session.swap(const Cell(0, 1), const Cell(1, 1));
      expect(result.destroyedBlockers[BlockerKind.crate], 1);
      expect(session.board.blockerAt(0, 3), isNull);
      expect(session.outcome, LevelOutcome.won);
    });

    test('Reinforced Crate shows a damaged state and needs a second hit', () {
      final reinforced =
          const BlockerDefinition(Cell(0, 3), BlockerKind.reinforcedCrate);
      final session = LevelSession(level(blockers: [reinforced]),
          initialTiles: boardFixture());
      session.swap(const Cell(0, 1), const Cell(1, 1));
      expect(session.board.blockerAt(0, 3)?.damaged, isTrue);
      final crate = BlockerState(BlockerKind.reinforcedCrate);
      expect(crate.takeHit(), isFalse);
      expect(crate.damaged, isTrue);
      expect(crate.hp, 1);
      expect(crate.takeHit(), isTrue);
      expect(crate.hp, 0);
    });

    test('a straight four creates a Rocket', () {
      final grid = boardFixture();
      grid[0][3] = const Piece(TileFamily.cloud);
      final session = LevelSession(
          level(objectives: const [
            ObjectiveDefinition(
                kind: ObjectiveKind.createSpecial,
                special: SpecialKind.rocket,
                target: 1)
          ]),
          initialTiles: grid);
      final result = session.swap(const Cell(0, 1), const Cell(1, 1));
      expect(result.createdSpecials, contains(SpecialKind.rocket));
      expect(session.outcome, LevelOutcome.won);
    });

    test('a vertical straight four creates a vertical Rocket', () {
      final grid = List.generate(
          8,
          (r) =>
              List.generate(8, (c) => Piece(TileFamily.values[(r + c) % 5])));
      grid[0][0] = const Piece(TileFamily.cloud);
      grid[1][0] = const Piece(TileFamily.leaf);
      grid[2][0] = const Piece(TileFamily.cloud);
      grid[3][0] = const Piece(TileFamily.cloud);
      grid[1][1] = const Piece(TileFamily.cloud);
      final board = Match3Board(level: level(), initialTiles: grid);
      final result = board.resolveSwap(const Cell(1, 0), const Cell(1, 1));
      expect(result.createdSpecials, contains(SpecialKind.rocket));
      expect(result.createdPieces.single.direction, RocketDirection.vertical);
    });

    test('a straight five creates a Prism', () {
      final grid = List.generate(
          8,
          (r) =>
              List.generate(8, (c) => Piece(TileFamily.values[(r + c) % 5])));
      grid[0][0] = const Piece(TileFamily.cloud);
      grid[0][1] = const Piece(TileFamily.cloud);
      grid[0][2] = const Piece(TileFamily.leaf);
      grid[0][3] = const Piece(TileFamily.cloud);
      grid[0][4] = const Piece(TileFamily.cloud);
      grid[0][5] = const Piece(TileFamily.leaf);
      grid[1][2] = const Piece(TileFamily.cloud);
      final session = LevelSession(
          level(objectives: const [
            ObjectiveDefinition(
                kind: ObjectiveKind.createSpecial,
                special: SpecialKind.prism,
                target: 1)
          ]),
          initialTiles: grid);
      expect(session.board.findMatches(), isEmpty);
      final result = session.swap(const Cell(0, 2), const Cell(1, 2));
      expect(result.createdSpecials, contains(SpecialKind.prism));
      expect(session.outcome, LevelOutcome.won);
    });

    test('a T/L intersection creates a Cloud Bomb', () {
      final grid = List.generate(
          8,
          (r) =>
              List.generate(8, (c) => Piece(TileFamily.values[(r + c) % 5])));
      grid[1][0] = const Piece(TileFamily.cloud);
      grid[1][1] = const Piece(TileFamily.leaf);
      grid[1][2] = const Piece(TileFamily.cloud);
      grid[1][3] = const Piece(TileFamily.cloud);
      grid[1][4] = const Piece(TileFamily.leaf);
      grid[2][1] = const Piece(TileFamily.cloud);
      grid[3][1] = const Piece(TileFamily.cloud);
      grid[4][1] = const Piece(TileFamily.leaf);
      final session = LevelSession(
          level(objectives: const [
            ObjectiveDefinition(
                kind: ObjectiveKind.createSpecial,
                special: SpecialKind.cloudBomb,
                target: 1)
          ]),
          initialTiles: grid);
      expect(session.board.findMatches(), isEmpty);
      final result = session.swap(const Cell(1, 0), const Cell(1, 1));
      expect(result.createdSpecials, contains(SpecialKind.cloudBomb));
      expect(session.outcome, LevelOutcome.won);
    });

    test('Rocket activation clears its row', () {
      final grid = boardFixture();
      grid[0][0] = const Piece(TileFamily.cloud,
          special: SpecialKind.rocket, direction: RocketDirection.horizontal);
      final board = Match3Board(level: level(), initialTiles: grid);
      final result = board.resolveSwap(const Cell(0, 0), const Cell(0, 1));
      expect(result.accepted, isTrue);
      expect(result.cleared.where((cell) => cell.row == 0).length, 8);
    });

    test('Prism activation clears all of the swapped family', () {
      final grid = boardFixture();
      grid[3][3] = const Piece(TileFamily.star, special: SpecialKind.prism);
      grid[3][4] = const Piece(TileFamily.moon);
      final board = Match3Board(level: level(), initialTiles: grid);
      final result = board.resolveSwap(const Cell(3, 3), const Cell(3, 4));
      expect(result.accepted, isTrue);
      for (var r = 0; r < 8; r++) {
        for (var c = 0; c < 8; c++) {
          if (grid[r][c]?.family == TileFamily.moon) {
            expect(result.cleared, contains(Cell(r, c)));
          }
        }
      }
    });

    test('Cloud Bomb activation clears a clipped 3x3 area', () {
      final grid = boardFixture();
      grid[0][0] = const Piece(TileFamily.star, special: SpecialKind.cloudBomb);
      grid[0][1] = const Piece(TileFamily.leaf);
      final board = Match3Board(level: level(), initialTiles: grid);
      final result = board.resolveSwap(const Cell(0, 0), const Cell(0, 1));
      expect(result.accepted, isTrue);
      expect(
          result.cleared,
          containsAll([
            const Cell(0, 0),
            const Cell(0, 1),
            const Cell(1, 0),
            const Cell(1, 1)
          ]));
    });
  });

  group('objectives, outcomes, and rewards', () {
    test('collect and score objectives can complete together', () {
      final session = LevelSession(
          level(objectives: const [
            ObjectiveDefinition(
                kind: ObjectiveKind.collect,
                family: TileFamily.cloud,
                target: 3),
            ObjectiveDefinition(kind: ObjectiveKind.score, target: 30),
          ]),
          initialTiles: boardFixture());
      session.swap(const Cell(0, 1), const Cell(1, 1));
      expect(
          session.objectives.every((objective) => objective.complete), isTrue);
      expect(session.outcome, LevelOutcome.won);
    });

    test('a multi-objective level does not win until every counter is complete',
        () {
      final session = LevelSession(
          level(objectives: const [
            ObjectiveDefinition(
                kind: ObjectiveKind.collect,
                family: TileFamily.cloud,
                target: 99),
            ObjectiveDefinition(kind: ObjectiveKind.score, target: 30),
          ]),
          initialTiles: boardFixture());
      session.swap(const Cell(0, 1), const Cell(1, 1));
      expect(session.objectives[1].complete, isTrue);
      expect(session.objectives[0].complete, isFalse);
      expect(session.outcome, LevelOutcome.playing);
    });

    test('a move limit with unfinished objectives is a loss', () {
      final session =
          LevelSession(level(moves: 1), initialTiles: boardFixture());
      session.swap(const Cell(0, 1), const Cell(1, 1));
      expect(session.movesRemaining, 0);
      expect(session.outcome, LevelOutcome.lost);
    });

    test('same level, seed, and moves replay to identical state and score', () {
      final a = LevelSession(level(seed: 321));
      final b = LevelSession(level(seed: 321));
      for (var turn = 0; turn < 8; turn++) {
        var moved = false;
        for (var row = 0; row < 8 && !moved; row++) {
          for (var col = 0; col < 8 && !moved; col++) {
            for (final next in [Cell(row, col + 1), Cell(row + 1, col)]) {
              if (next.row >= 8 || next.col >= 8) continue;
              final ra = a.swap(Cell(row, col), next);
              final rb = b.swap(Cell(row, col), next);
              expect(ra.accepted, rb.accepted);
              if (ra.accepted) {
                moved = true;
                break;
              }
            }
          }
        }
        expect(moved, isTrue);
        expect(a.board.fingerprint, b.board.fingerprint);
        expect(a.board.score, b.board.score);
      }
    });

    test('reward grant is idempotent and best score only increases', () {
      final progress = ProgressState();
      final authored = level(coins: 165);
      final first = progress.grantFirstClear(authored, 850);
      final replay = progress.grantFirstClear(authored, 400);
      final improved = progress.grantFirstClear(authored, 950);
      expect(first.firstClear, isTrue);
      expect(first.coins, 165);
      expect(first.stars, 1);
      expect(replay.firstClear, isFalse);
      expect(replay.coins, 0);
      expect(replay.stars, 0);
      expect(improved.bestScore, 950);
      expect(progress.coins, 165);
      expect(progress.starLevelIds, {1});
      final restored = ProgressState.fromJson(progress.toJson());
      expect(restored.coins, 165);
      expect(restored.completedLevels, {1});
      expect(restored.unlockedThrough, 2);
      restored.loungeStyleId = 'retro_70s';
      restored.loungeRestoredFlag = true;
      final withLounge = ProgressState.fromJson(restored.toJson());
      expect(withLounge.loungeRestored, isTrue);
      expect(withLounge.loungeStyleId, 'retro_70s');
    });
  });
}
