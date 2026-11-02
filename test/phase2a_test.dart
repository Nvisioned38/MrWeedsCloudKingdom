import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/domain/phase2_models.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/phase2_screens.dart';
import 'package:mr_weeds_cloud_kingdom/main.dart';

const _saveKey = 'phase2_test_save';

Map<String, dynamic> _decodeAsset(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

List<List<Piece?>> _boardFixture() {
  final grid = List.generate(
      8, (r) => List.generate(8, (c) => Piece(TileFamily.values[(r + c) % 5])));
  grid[0][0] = const Piece(TileFamily.cloud);
  grid[0][1] = const Piece(TileFamily.leaf);
  grid[0][2] = const Piece(TileFamily.cloud);
  grid[1][1] = const Piece(TileFamily.cloud);
  return grid;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CollectionCatalog collection;
  late WorldCatalog world;
  late CharacterCatalog characters;
  late StoryCatalog story;
  late List<LevelSpec> levels;

  setUpAll(() async {
    collection = CollectionCatalog.fromJson(_decodeAsset(
        await rootBundle.loadString('assets/data/collectibles.json')));
    world = WorldCatalog.fromJson(_decodeAsset(
        await rootBundle.loadString('assets/data/world_nodes.json')));
    characters = CharacterCatalog.fromJson(_decodeAsset(
        await rootBundle.loadString('assets/data/characters.json')));
    story = StoryCatalog.fromJson(_decodeAsset(
        await rootBundle.loadString('assets/data/story_chapters.json')));
    final levelData = _decodeAsset(
        await rootBundle.loadString('assets/data/levels_001_010.json'));
    levels = (levelData['levels'] as List)
        .cast<Map<String, dynamic>>()
        .map(LevelSpec.fromJson)
        .toList();
  });

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test('Phase 1 save migrates without losing progress or Lounge style', () {
    final migrated = ProgressState.fromJson({
      'schema': 1,
      'completed': [1, 2, 5],
      'best': {'1': 900, '5': 1880},
      'coins': 320,
      'stars': [1, 2, 5],
      'loungeStyleId': 'psychedelic',
      'loungeRestored': true,
      'settings': {'sound': false, 'music': true},
    });

    expect(migrated.completedLevels, {1, 2, 5});
    expect(migrated.bestScores, {1: 900, 5: 1880});
    expect(migrated.coins, 320);
    expect(migrated.starLevelIds, {1, 2, 5});
    expect(migrated.loungeStyleId, 'psychedelic');
    expect(migrated.unlockedCollectibleIds, {'bluebeary_pancakes'});
    expect(migrated.settings['sound'], isFalse);
    expect(ProgressState.fromJson(migrated.toJson()).coins, 320);
  });

  test('Cloud House and Lounge states resolve from node data and saved state',
      () {
    final progress = ProgressState();
    WorldNodeDefinition node(String id) =>
        world.nodes.firstWhere((entry) => entry.id == id);

    expect(progress.stateForWorldNode(node('cloud_house')),
        WorldNodeState.available);
    expect(progress.stateForWorldNode(node('lounge')), WorldNodeState.locked);
    for (final id in [
      'kitchen',
      'higher_art_gallery',
      'secret_basement',
      'festival_grounds'
    ]) {
      expect(progress.stateForWorldNode(node(id)), WorldNodeState.locked);
    }
    progress.completedLevels.add(10);
    expect(
        progress.stateForWorldNode(node('lounge')), WorldNodeState.available);
    progress.loungeRestoredFlag = true;
    expect(progress.stateForWorldNode(node('lounge')), WorldNodeState.restored);
    progress.loungeStyleId = 'retro_70s';
    expect(
        progress.stateForWorldNode(node('lounge')), WorldNodeState.customized);
    progress.setWorldNodeState('kitchen', WorldNodeState.available);
    expect(ProgressState.fromJson(progress.toJson()).worldNodeStates['kitchen'],
        WorldNodeState.available);
  });

  test('Level 5 migration grants BlueBEARy Pancakes and persists the unlock',
      () {
    final progress = ProgressState.fromJson({
      'completed': [1, 2, 3, 4, 5]
    });
    expect(progress.discoveredCollectibleIds, {'bluebeary_pancakes'});
    expect(progress.unlockedCollectibleIds, {'bluebeary_pancakes'});
    expect(progress.collectibleEvolutionStages['bluebeary_pancakes'],
        EvolutionStage.seedling);
    final restored = ProgressState.fromJson(progress.toJson());
    expect(restored.unlockedCollectibleIds, {'bluebeary_pancakes'});
  });

  test('collection filters and name sort use catalog data', () {
    expect(collection.cards, hasLength(10));
    expect(
        collection.cards.map((card) => card.displayName),
        containsAll([
          'BlueBEARy Pancakes',
          'Soldier Field Haze',
          'Bong Berry Blitz',
          "Cortez's Curse",
          'Sugar Skull Sherbet',
          'Exotic Kush',
          'Blackberry Kush',
          'Baked Alien',
          'Blue Walker',
          'Avatar OG',
        ]));
    final legendaries = collection.query(rarity: CollectibleRarity.legendary);
    expect(legendaries.map((card) => card.displayName),
        ['Baked Alien', 'Sugar Skull Sherbet']);
    final mystic = collection.query(collectionId: 'mystic_garden');
    expect(mystic.map((card) => card.displayName), [
      'Avatar OG',
      'Bong Berry Blitz',
      "Cortez's Curse",
      'Sugar Skull Sherbet',
    ]);
  });

  test('character and story catalogs expose Chapter 1 and two teasers', () {
    expect(characters.characters, hasLength(6));
    final mrWeed = characters.byId('mr_weed')!;
    expect(mrWeed.displayName, 'Mr. Weed');
    expect(mrWeed.knownByDefault, isTrue);
    expect(mrWeed.portraitAssetKey, isNotEmpty);
    expect(mrWeed.fullBodyAssetKey, isNotEmpty);
    expect(story.chapters.map((chapter) => chapter.title), [
      'Welcome to the Clouds',
      'Kitchen Catastrophe',
      'The Missing Collection',
    ]);
    expect(story.chapters.first.playable, isTrue);
    expect(
        story.chapters.skip(1).every((chapter) => !chapter.playable), isTrue);
  });

  test('favorite and displayed collectible persist', () {
    final progress = ProgressState()..unlockCollectible('bluebeary_pancakes');
    progress.toggleFavorite('bluebeary_pancakes');
    progress.displayCollectible('bluebeary_pancakes');
    final restored = ProgressState.fromJson(progress.toJson());
    expect(restored.favoriteCollectibleIds, {'bluebeary_pancakes'});
    expect(restored.displayedCollectibleId, 'bluebeary_pancakes');
    restored.toggleFavorite('bluebeary_pancakes');
    restored.displayCollectible('locked_card');
    expect(restored.favoriteCollectibleIds, isEmpty);
    expect(restored.displayedCollectibleId, 'bluebeary_pancakes');
  });

  test('story flags and chapter completion round-trip', () {
    final progress = ProgressState()
      ..storyFlags.addAll(['chapter_1_complete', 'keefler_mystery_seen'])
      ..completedChapterIds.add('chapter_1');
    final restored = ProgressState.fromJson(progress.toJson());
    expect(restored.storyFlags, {'chapter_1_complete', 'keefler_mystery_seen'});
    expect(restored.completedChapterIds, {'chapter_1'});
  });

  testWidgets('Chapter 1 dialogue sets and saves its completion flag',
      (tester) async {
    final progress = ProgressState();
    Future<void> persist() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_saveKey, jsonEncode(progress.toJson()));
    }

    await tester.pumpWidget(MaterialApp(
      home: StoryScreen(
        catalog: story,
        characters: characters,
        progress: progress,
        persist: persist,
      ),
    ));
    await tester.tap(find.text('Welcome to the Clouds'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Mr. Weed'), findsWidgets);
    expect(find.textContaining('Cloud House'), findsWidgets);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pump();
    }
    await tester.tap(find.text('Complete Chapter'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(progress.completedChapterIds, {'chapter_1'});
    expect(progress.storyFlags, contains('chapter_1_complete'));
    final saved = (await SharedPreferences.getInstance()).getString(_saveKey);
    expect(
        ProgressState.fromJson(jsonDecode(saved!) as Map<String, dynamic>)
            .completedChapterIds,
        {'chapter_1'});
  });

  testWidgets('home navigation keeps the same shared world progress',
      (tester) async {
    final progress = ProgressState()..completedLevels.add(5);
    progress.unlockCollectible('bluebeary_pancakes');
    progress.displayCollectible('bluebeary_pancakes');
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(
        progress: progress,
        levels: levels,
        collectionCatalog: collection,
        worldCatalog: world,
        characterCatalog: characters,
        storyCatalog: story,
        persist: () async {},
      ),
    ));
    expect(find.text('BlueBEARy Pancakes'), findsOneWidget);
    await tester.tap(find.text('Collection'));
    await tester.pump();
    expect(find.text('1 of 10 discovered · sorted by name'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(progress.completedLevels, {5});
    expect(progress.displayedCollectibleId, 'bluebeary_pancakes');
    expect(find.text('BlueBEARy Pancakes'), findsOneWidget);
  });

  testWidgets('completing Level 5 unlocks BlueBEARy Pancakes', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final progress = ProgressState();
    const level = LevelSpec(
      id: 5,
      name: 'Crate Expectations',
      seed: 1005,
      moves: 10,
      objectives: [ObjectiveDefinition(kind: ObjectiveKind.score, target: 30)],
      blockers: [],
      coins: 140,
    );
    final session = LevelSession(level, initialTiles: _boardFixture());
    await tester.pumpWidget(MaterialApp(
      home: PlayScreen(
        level: level,
        progress: progress,
        persist: () async {},
        initialSession: session,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final board = tester.getRect(find.byKey(const ValueKey('match3-board')));
    await tester.tapAt(Offset(
        board.left + board.width * 1.5 / 8, board.top + board.height * .5 / 8));
    await tester.pump(const Duration(milliseconds: 30));
    await tester.tapAt(Offset(board.left + board.width * 1.5 / 8,
        board.top + board.height * 1.5 / 8));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Clouds cleared!'), findsOneWidget);
    expect(progress.unlockedCollectibleIds, {'bluebeary_pancakes'});
  });
}
