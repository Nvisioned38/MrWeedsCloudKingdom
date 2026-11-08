import 'dart:convert';
import 'dart:ui' show SemanticsAction;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/game/cloud_board_game.dart';
import 'package:mr_weeds_cloud_kingdom/main.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/phase2_screens.dart';

const saveKey = 'cloud_kingdom_progress_v2';

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
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('New Game opens Cloud House and Level 1', (tester) async {
    await tester.pumpWidget(const CloudKingdomApp());
    // BootScreen loads JSON and the expanded art manifest from real assets.
    // A perpetual loading spinner cannot be pumpAndSettle'd while those
    // asynchronous rootBundle operations are still in flight.
    for (var attempt = 0;
        attempt < 75 && find.text('New Game').evaluate().isEmpty;
        attempt++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pump();
    }
    expect(find.text('New Game'), findsOneWidget);
    await tester.tap(find.text('New Game'));
    await tester.pumpAndSettle();
    expect(find.text('Cloud House'), findsWidgets);
    expect(find.text('First Puff'), findsOneWidget);
    await tester.ensureVisible(find.text('First Puff'));
    await tester.tap(find.ancestor(
        of: find.text('First Puff'), matching: find.byType(ListTile)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Level 1'), findsWidgets);
    expect(find.text('Moves 18'), findsOneWidget);
    expect(find.text('Score'), findsOneWidget);
  });

  testWidgets(
      'controlled level win persists first-clear rewards and unlocks Level 2',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final progress = ProgressState();
    progress.settings['reducedMotion'] = true;
    progress.settings['haptics'] = false;
    final platformCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        platformCalls.add(call);
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    final authored = LevelSpec(
        id: 1,
        name: 'First Puff',
        seed: 1001,
        moves: 18,
        objectives: const [
          ObjectiveDefinition(kind: ObjectiveKind.score, target: 30)
        ],
        blockers: const [],
        coins: 100);
    final session = LevelSession(authored, initialTiles: boardFixture());
    Future<void> persist() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(saveKey, jsonEncode(progress.toJson()));
    }

    await tester.pumpWidget(MaterialApp(
        home: PlayScreen(
            level: authored,
            progress: progress,
            persist: persist,
            initialSession: session)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final game = tester
        .widget<GameWidget>(find.byKey(const ValueKey('match3-board')))
        .game;
    expect((game as CloudBoardGame).reducedMotion, isTrue);
    final boardRect =
        tester.getRect(find.byKey(const ValueKey('match3-board')));
    await tester.tapAt(Offset(boardRect.left + boardRect.width * 1.5 / 8,
        boardRect.top + boardRect.height * .5 / 8));
    await tester.pump(const Duration(milliseconds: 30));
    await tester.tapAt(Offset(boardRect.left + boardRect.width * 1.5 / 8,
        boardRect.top + boardRect.height * 1.5 / 8));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Clouds cleared!'), findsOneWidget);
    expect(progress.coins, 100);
    expect(progress.starLevelIds, {1});
    expect(progress.unlockedThrough, 2);
    expect(
        platformCalls.where((call) => call.method == 'HapticFeedback.vibrate'),
        isEmpty,
        reason: 'Haptics are disabled in the isolated QA profile.');

    final saved = (await SharedPreferences.getInstance()).getString(saveKey);
    expect(saved, isNotNull);
    final restored =
        ProgressState.fromJson(jsonDecode(saved!) as Map<String, dynamic>);
    expect(restored.completedLevels, {1});
    expect(restored.coins, 100);
    expect(restored.unlockedThrough, 2);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
      'screen-reader board actions complete and persist an isolated win',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final progress = ProgressState();
    const authored = LevelSpec(
      id: 1,
      name: 'First Puff',
      seed: 1001,
      moves: 18,
      objectives: [ObjectiveDefinition(kind: ObjectiveKind.score, target: 30)],
      blockers: [],
      coins: 100,
    );
    Future<void> persist() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(saveKey, jsonEncode(progress.toJson()));
    }

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PlayScreen(
                  level: authored,
                  progress: progress,
                  persist: persist,
                  initialSession:
                      LevelSession(authored, initialTiles: boardFixture()),
                ),
              )),
              child: const Text('Cloud House · Start Level 1'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Cloud House · Start Level 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final first =
        tester.getSemantics(find.byKey(const ValueKey('board-cell-0-1')));
    expect(first.label, 'Mystic Bloom, row 1, column 2');
    expect(first.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    first.owner!.performAction(first.id, SemanticsAction.tap);
    await tester.pump();
    final second =
        tester.getSemantics(find.byKey(const ValueKey('board-cell-1-1')));
    second.owner!.performAction(second.id, SemanticsAction.tap);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Clouds cleared!'), findsOneWidget);
    expect(progress.completedLevels, {1});
    final saved = (await SharedPreferences.getInstance()).getString(saveKey);
    expect(saved, isNotNull);
    final restored =
        ProgressState.fromJson(jsonDecode(saved!) as Map<String, dynamic>);
    expect(restored.coins, 100);
    expect(restored.starLevelIds, {1});
    expect(restored.unlockedThrough, 2);
    await tester.tap(find.text('Back to Cloud House'));
    await tester.pumpAndSettle();
    expect(find.text('Cloud House · Start Level 1'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('settings remain labeled at large text scale with usable targets',
      (tester) async {
    final progress = ProgressState();
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Scaffold(
          body: SettingsScreen(
            progress: progress,
            persist: () async {},
          ),
        ),
      ),
    ));
    expect(find.text('Reduced motion'), findsOneWidget);
    expect(find.text('Haptics'), findsOneWidget);
    expect(tester.getSize(find.byType(SwitchListTile).first).height,
        greaterThanOrEqualTo(48));
    await tester.tap(find.text('Reduced motion'));
    await tester.pump();
    expect(progress.settings['reducedMotion'], isTrue);
  });

  testWidgets('Lounge style is saved and visible after app reload',
      (tester) async {
    final progress = ProgressState()..completedLevels.add(10);
    Future<void> persist() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(saveKey, jsonEncode(progress.toJson()));
    }

    await tester.pumpWidget(
        MaterialApp(home: LoungeScreen(progress: progress, persist: persist)));
    await tester.tap(find.text('Classic Cloud'));
    await tester.pumpAndSettle();
    expect(progress.loungeStyleId, 'classic_cloud');

    final saved = (await SharedPreferences.getInstance()).getString(saveKey);
    expect(saved, isNotNull);
    final restored =
        ProgressState.fromJson(jsonDecode(saved!) as Map<String, dynamic>);
    expect(restored.loungeStyleId, 'classic_cloud');
    expect(restored.loungeRestored, isTrue);
  });

  testWidgets('Level 10 results offer and save the three Lounge choices',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final progress = ProgressState()
      ..completedLevels.addAll([1, 2, 3, 4, 5, 6, 7, 8, 9]);
    const level10 = LevelSpec(
        id: 10,
        name: 'Lounge Rescue',
        seed: 1010,
        moves: 30,
        objectives: [
          ObjectiveDefinition(kind: ObjectiveKind.score, target: 30)
        ],
        blockers: [],
        coins: 250);
    Future<void> persist() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(saveKey, jsonEncode(progress.toJson()));
    }

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PlayScreen(
                                  level: level10,
                                  progress: progress,
                                  persist: persist,
                                  initialSession: LevelSession(level10,
                                      initialTiles: boardFixture())))),
                      child: const Text('Start Level 10'),
                    )))));
    await tester.tap(find.text('Start Level 10'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final boardRect =
        tester.getRect(find.byKey(const ValueKey('match3-board')));
    await tester.tapAt(Offset(boardRect.left + boardRect.width * 1.5 / 8,
        boardRect.top + boardRect.height * .5 / 8));
    await tester.pump(const Duration(milliseconds: 30));
    await tester.tapAt(Offset(boardRect.left + boardRect.width * 1.5 / 8,
        boardRect.top + boardRect.height * 1.5 / 8));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Clouds cleared!'), findsOneWidget);
    expect(progress.completedLevels, contains(10));
    await tester.tap(find.text('Restore the Lounge'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Classic Cloud'), findsOneWidget);
    expect(find.text('Psychedelic'), findsOneWidget);
    expect(find.text('Retro 70s'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(LoungeScreen), matching: find.byType(FilledButton)),
        findsNWidgets(3));
    await tester.tap(find.text('Retro 70s'));
    await tester.pumpAndSettle();
    expect(progress.loungeStyleId, 'retro_70s');
    expect(progress.loungeRestored, isTrue);
    final saved = (await SharedPreferences.getInstance()).getString(saveKey);
    expect(saved, isNotNull);
    final restored =
        ProgressState.fromJson(jsonDecode(saved!) as Map<String, dynamic>);
    expect(restored.loungeStyleId, 'retro_70s');
    await tester.binding.setSurfaceSize(null);
  });
}
