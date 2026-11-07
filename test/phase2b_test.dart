import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/domain/phase2_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<LevelSpec> levels;
  late WorldCatalog world;
  late CollectionCatalog collection;

  setUpAll(() async {
    final levelJson = jsonDecode(
            await rootBundle.loadString('assets/data/levels_001_030.json'))
        as Map<String, dynamic>;
    levels = (levelJson['levels'] as List)
        .cast<Map<String, dynamic>>()
        .map(LevelSpec.fromJson)
        .toList(growable: false);
    world = WorldCatalog.fromJson(
        jsonDecode(await rootBundle.loadString('assets/data/world_nodes.json'))
            as Map<String, dynamic>);
    collection = CollectionCatalog.fromJson(
        jsonDecode(await rootBundle.loadString('assets/data/collectibles.json'))
            as Map<String, dynamic>);
  });

  test('Phase 2A schema migrates without losing existing progression', () {
    final migrated = ProgressState.fromJson({
      'schema': 2,
      'completed': [5, 10],
      'best': {'5': 1800, '10': 3400},
      'coins': 420,
      'stars': [5, 10],
      'loungeStyleId': 'retro_70s',
      'loungeRestored': true,
      'unlockedCollectibles': ['bluebeary_pancakes'],
      'favoriteCollectibles': ['bluebeary_pancakes'],
      'storyFlags': ['chapter_1_complete', 'keefler_mystery_seen'],
      'completedChapters': ['chapter_1'],
      'settings': {'sound': false, 'music': true},
    });

    expect(migrated.completedLevels, {5, 10});
    expect(migrated.bestScores, {5: 1800, 10: 3400});
    expect(migrated.coins, 420);
    expect(migrated.starLevelIds, {5, 10});
    expect(migrated.loungeStyleId, 'retro_70s');
    expect(
        migrated.unlockedCollectibleIds, {'bluebeary_pancakes', 'cloud_nine'});
    expect(migrated.favoriteCollectibleIds, {'bluebeary_pancakes'});
    expect(migrated.storyFlags, {'chapter_1_complete', 'keefler_mystery_seen'});
    expect(migrated.completedChapterIds, {'chapter_1'});
    expect(migrated.collectionXp, 0);
    expect(migrated.keys, 0);
    expect(migrated.equippedCollectibleId, isNull);
    expect(migrated.settings['sound'], isFalse);
    expect(migrated.toJson()['schema'], 3);
  });

  test('first-clear rewards grant Collection XP and milestone keys once', () {
    final progress = ProgressState()..unlockCollectible('bluebeary_pancakes');
    final level11 = levels.firstWhere((level) => level.id == 11);
    final first = progress.grantFirstClear(level11, 2400);
    final replay = progress.grantFirstClear(level11, 1800);

    expect(first.firstClear, isTrue);
    expect(first.collectionXp, 7);
    expect(progress.collectionXp, 7);
    expect(progress.collectibleXp['bluebeary_pancakes'], 7);
    expect(replay.firstClear, isFalse);
    expect(replay.collectionXp, 0);
    expect(progress.collectionXp, 7);

    final level30 = levels.firstWhere((level) => level.id == 30);
    final finale = progress.grantFirstClear(level30, 5000);
    expect(finale.keys, 1);
    expect(progress.keys, 1);
    expect(
        progress.worldNodeStates['higher_art_gallery'], WorldNodeState.preview);
  });

  test('Level 20 opens the Kitchen while Level 30 only previews the Gallery',
      () {
    final progress = ProgressState();
    final kitchen = world.nodes.firstWhere((node) => node.id == 'kitchen');
    final gallery =
        world.nodes.firstWhere((node) => node.id == 'higher_art_gallery');
    expect(progress.stateForWorldNode(kitchen), WorldNodeState.locked);
    expect(progress.stateForWorldNode(gallery), WorldNodeState.locked);

    progress.grantFirstClear(
        levels.firstWhere((level) => level.id == 20), 4000);
    expect(progress.stateForWorldNode(kitchen), WorldNodeState.available);
    expect(progress.stateForWorldNode(gallery), WorldNodeState.locked);
    expect(progress.storyFlags, contains('kitchen_opened'));

    progress.grantFirstClear(
        levels.firstWhere((level) => level.id == 30), 5000);
    expect(progress.stateForWorldNode(gallery), WorldNodeState.preview);
    expect(progress.storyFlags, contains('gallery_preview_seen'));
    expect(ProgressState.fromJson(progress.toJson()).stateForWorldNode(gallery),
        WorldNodeState.preview);
  });

  test('per-card XP advances centralized evolution thresholds and persists',
      () {
    final progress = ProgressState()..unlockCollectible('cloud_nine');
    expect(progress.equipCollectible('cloud_nine'), isTrue);
    progress.awardCollectionXp(10);
    expect(
        progress.collectibleEvolutionStages['cloud_nine'], EvolutionStage.bud);
    progress.awardCollectionXp(15);
    expect(progress.collectibleEvolutionStages['cloud_nine'],
        EvolutionStage.frosted);
    progress.awardCollectionXp(25);
    expect(progress.collectibleEvolutionStages['cloud_nine'],
        EvolutionStage.legendary);

    final restored = ProgressState.fromJson(progress.toJson());
    expect(restored.collectionXp, 50);
    expect(restored.collectibleXp['cloud_nine'], 50);
    expect(restored.collectibleEvolutionStages['cloud_nine'],
        EvolutionStage.legendary);
    expect(restored.equippedCollectibleId, 'cloud_nine');
  });

  test('New Game reset clears all Phase 2B progression fields', () {
    final progress = ProgressState()
      ..completedLevels.addAll([10, 20, 30])
      ..coins = 400
      ..keys = 1
      ..collectionXp = 42
      ..storyFlags.add('chapter_2_complete')
      ..completedChapterIds.add('chapter_2')
      ..worldNodeStates['higher_art_gallery'] = WorldNodeState.preview;
    progress
      ..unlockCollectible('cloud_nine')
      ..equipCollectible('cloud_nine')
      ..awardCollectionXp(42);

    progress.resetForNewGame();

    expect(progress.completedLevels, isEmpty);
    expect(progress.coins, 0);
    expect(progress.keys, 0);
    expect(progress.collectionXp, 0);
    expect(progress.collectibleXp, isEmpty);
    expect(progress.collectibleEvolutionStages, isEmpty);
    expect(progress.unlockedCollectibleIds, isEmpty);
    expect(progress.equippedCollectibleId, isNull);
    expect(progress.storyFlags, isEmpty);
    expect(progress.completedChapterIds, isEmpty);
    expect(progress.worldNodeStates, isEmpty);
  });

  test('Cloud Nine equipment applies one deterministic score head start', () {
    final level = levels.first;
    final withoutPerk = LevelSession(level);
    final withPerk = LevelSession(
      level,
      puzzlePerk: PuzzlePerk.cloudNineScoreHeadstart,
    );
    expect(withoutPerk.board.score, 0);
    expect(withPerk.board.score, 150);
    expect(withPerk.objectives.first.value, 150);
    expect(withPerk.board.fingerprint, withoutPerk.board.fingerprint);
  });

  test('Sticky Syrup locks its tile and clears beside a qualifying match', () {
    final fixture = _fixture();
    final level = LevelSpec(
      id: 901,
      name: 'Sticky Syrup test',
      seed: 901,
      moves: 10,
      objectives: const [
        ObjectiveDefinition(kind: ObjectiveKind.score, target: 9999)
      ],
      blockers: const [],
      coins: 0,
      stickySyrupCells: const [Cell(1, 0)],
    );
    final session = LevelSession(level, initialTiles: fixture);
    final before = session.board.fingerprint;

    expect(session.board.at(1, 0)!.stickySyrup, isTrue);
    expect(session.swap(const Cell(1, 0), const Cell(1, 1)).accepted, isFalse);
    expect(session.board.fingerprint, before);

    final clear = session.swap(const Cell(0, 1), const Cell(1, 1));
    expect(clear.accepted, isTrue);
    expect(clear.changedCells, contains(const Cell(1, 0)));
    expect(session.board.at(1, 0)?.stickySyrup ?? false, isFalse);
  });

  test('Fog reveals the same hidden tile identity after an adjacent clear', () {
    final level = LevelSpec(
      id: 902,
      name: 'Fog test',
      seed: 902,
      moves: 10,
      objectives: const [
        ObjectiveDefinition(kind: ObjectiveKind.score, target: 9999)
      ],
      blockers: const [],
      coins: 0,
      fogCells: const [Cell(1, 2)],
    );
    final session = LevelSession(level, initialTiles: _fixture());
    final hiddenFamily = session.board.at(1, 2)!.family;

    expect(session.board.at(1, 2)!.fogged, isTrue);
    expect(session.swap(const Cell(0, 1), const Cell(1, 1)).accepted, isTrue);
    expect(session.board.at(1, 2)!.family, hiddenFamily);
    expect(session.board.at(1, 2)!.fogged, isFalse);
  });

  test('story finale is gated by Level 30 completion', () {
    final progress = ProgressState();

    expect(progress.isStoryBeatAvailable(11), isFalse);
    progress.completedLevels.add(10);
    expect(progress.isStoryBeatAvailable(11), isTrue);
    expect(progress.isStoryBeatAvailable(16), isFalse);
    progress.completedLevels.add(15);
    expect(progress.isStoryBeatAvailable(16), isTrue);

    progress.completedLevels.add(20);
    expect(progress.isStoryBeatAvailable(21), isTrue);
    expect(progress.isStoryBeatAvailable(26), isFalse);

    progress.completedLevels.add(25);
    expect(progress.isStoryBeatAvailable(26), isTrue);
    expect(progress.isStoryBeatAvailable(31), isFalse);

    progress.completedLevels.add(30);
    expect(progress.unlockedThrough, 30);
    expect(progress.isStoryBeatAvailable(31), isTrue);
    expect(ProgressState.fromJson(progress.toJson())
        .isStoryBeatAvailable(31), isTrue);
    expect(progress.isStoryBeatAvailable(32), isFalse);
  });

  test('Phase 2A collectible IDs remain stable in the 30-card launch catalog',
      () {
    expect(collection.cards, hasLength(30));
    expect(
      collection.cards.take(10).map((card) => card.id),
      [
        'bluebeary_pancakes',
        'soldier_field_haze',
        'bong_berry_blitz',
        'cortezs_curse',
        'sugar_skull_sherbet',
        'exotic_kush',
        'blackberry_kush',
        'baked_alien',
        'blue_walker',
        'avatar_og',
      ],
    );
  });
}

List<List<Piece?>> _fixture() {
  final grid = List.generate(
      8, (r) => List.generate(8, (c) => Piece(TileFamily.values[(r + c) % 5])));
  grid[0][0] = const Piece(TileFamily.cloud);
  grid[0][1] = const Piece(TileFamily.leaf);
  grid[0][2] = const Piece(TileFamily.cloud);
  grid[1][1] = const Piece(TileFamily.cloud);
  return grid;
}
