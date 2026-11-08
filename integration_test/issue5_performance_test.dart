import 'dart:convert';

import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<List<Piece?>> _boardFixture() {
  final grid = List.generate(
    8,
    (row) => List.generate(
      8,
      (col) => Piece(TileFamily.values[(row + col) % 5]),
    ),
  );
  grid[0][0] = const Piece(TileFamily.cloud);
  grid[0][1] = const Piece(TileFamily.leaf);
  grid[0][2] = const Piece(TileFamily.cloud);
  grid[1][1] = const Piece(TileFamily.cloud);
  return grid;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Level 1 board frame timing sample in isolated test data',
      (tester) async {
    final progress = ProgressState()
      ..settings['reducedMotion'] = true
      ..settings['haptics'] = false;
    const level = LevelSpec(
      id: 1,
      name: 'First Puff',
      seed: 1001,
      moves: 18,
      objectives: [ObjectiveDefinition(kind: ObjectiveKind.score, target: 30)],
      blockers: [],
      coins: 100,
    );

    await tester.pumpWidget(MaterialApp(
      home: PlayScreen(
        level: level,
        progress: progress,
        persist: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'cloud_kingdom_progress_v2',
            jsonEncode(progress.toJson()),
          );
        },
        initialSession: LevelSession(level, initialTiles: _boardFixture()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    await Future<void>.delayed(const Duration(seconds: 2));

    await binding.watchPerformance(() async {
      for (var frame = 0; frame < 60; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      final board = tester.getRect(find.byKey(const ValueKey('match3-board')));
      final cellWidth = board.width / 8;
      final cellHeight = board.height / 8;
      await tester.tapAt(Offset(
        board.left + cellWidth * 1.5,
        board.top + cellHeight * .5,
      ));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tapAt(Offset(
        board.left + cellWidth * 1.5,
        board.top + cellHeight * 1.5,
      ));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Clouds cleared!'), findsOneWidget);
      for (var frame = 0; frame < 60; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }, reportKey: 'issue5_level1_board');

    final summary = binding.reportData!['issue5_level1_board'] as Map;
    expect(summary['frame_count'], greaterThan(0));
    debugPrint('ISSUE5_FRAME_TIMINGS ${jsonEncode({
          'frame_count': summary['frame_count'],
          'average_frame_build_time_millis':
              summary['average_frame_build_time_millis'],
          '90th_percentile_frame_build_time_millis':
              summary['90th_percentile_frame_build_time_millis'],
          'average_frame_rasterizer_time_millis':
              summary['average_frame_rasterizer_time_millis'],
          '90th_percentile_frame_rasterizer_time_millis':
              summary['90th_percentile_frame_rasterizer_time_millis'],
          '99th_percentile_frame_build_time_millis':
              summary['99th_percentile_frame_build_time_millis'],
          'missed_frame_build_budget_count':
              summary['missed_frame_build_budget_count'],
          '99th_percentile_frame_rasterizer_time_millis':
              summary['99th_percentile_frame_rasterizer_time_millis'],
          'missed_frame_rasterizer_budget_count':
              summary['missed_frame_rasterizer_budget_count'],
        })}');
  });
}
