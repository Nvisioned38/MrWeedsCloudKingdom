import 'dart:convert';

import 'dart:ui' show FrameTiming;
import 'package:flutter_test/flutter_test.dart';

import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/qa/frame_timing_collector.dart';

void main() {
  group('QA FrameTiming statistics', () {
    test('computes odd and even percentiles in milliseconds', () {
      final odd = QaFrameTimingCollector.statisticsFromMicros(
        [3000, 1000, 8000],
      );
      expect(odd['p50'], 3.0);
      expect(odd['p90'], 7.0);
      expect(odd['p99'], 7.9);
      expect(odd['max'], 8.0);

      final even = QaFrameTimingCollector.statisticsFromMicros(
        [7000, 1000, 5000, 3000],
      );
      expect(even['p50'], 4.0);
      expect(even['p90'], 6.4);
      expect(even['p99'], 6.94);
    });

    test('counts only frames strictly over the supplied refresh budget', () {
      expect(
        QaFrameTimingCollector.countOverBudget(
          [8333, 8334, 16670, 16671],
          8333,
        ),
        3,
      );
      expect(
        QaFrameTimingCollector.countOverBudget([16670, 16671], 16670),
        1,
      );
    });
  });

  testWidgets('bounded batch capture stops and labels insufficient samples',
      (tester) async {
    String? output;
    final collector = QaFrameTimingCollector(
      reducedMotion: false,
      warmup: Duration.zero,
      maxSamples: 2,
      runtimePackageNameForTesting: 'com.mrweeds.cloudkingdom.qa',
      log: (message, {wrapWidth}) => output = message,
    );

    await collector.start();
    await tester.pump(const Duration(milliseconds: 1));
    expect(collector.isCapturing, isTrue);
    collector.ingestTimingBatch([
      _frame(0),
      _frame(16667),
      _frame(33334),
    ]);
    expect(collector.sampleCount, 2);

    collector.finish(levelEnded: false);
    expect(collector.isCapturing, isFalse);
    expect(collector.sampleCount, 0);
    expect(output, startsWith('CK_FRAME_TIMING '));
    final report = jsonDecode(output!.substring('CK_FRAME_TIMING '.length))
        as Map<String, dynamic>;
    expect(report['sampleCount'], 2);
    expect(report['classification'], 'insufficient');
    expect(report['minimumSamples'], 300);
    expect(report['package'], 'com.mrweeds.cloudkingdom.qa');
    expect(report['levelStarted'], isTrue);
    expect(report['levelEnded'], isFalse);
    expect((report['buildMs'] as Map)['p50'], 1.0);
    expect((report['rasterMs'] as Map)['p50'], 1.9);
  });

  testWidgets('collector remains disabled without the QA profiling opt-in',
      (tester) async {
    String? output;
    final collector = QaFrameTimingCollector(
      reducedMotion: true,
      warmup: Duration.zero,
      log: (message, {wrapWidth}) => output = message,
    );
    await collector.start();
    await tester.pump(const Duration(milliseconds: 1));
    expect(collector.isCapturing, isFalse);
    collector.ingestTimingBatch([_frame(0)]);
    collector.finish(levelEnded: false);
    expect(output, isNull);
    expect(collector.sampleCount, 0);
  });

  testWidgets('aggregates engine event labels without retaining cell data',
      (tester) async {
    String? output;
    final collector = QaFrameTimingCollector(
      reducedMotion: false,
      warmup: Duration.zero,
      runtimePackageNameForTesting: 'com.mrweeds.cloudkingdom.qa',
      log: (message, {wrapWidth}) => output = message,
    );
    await collector.start();
    await tester.pump(const Duration(milliseconds: 1));

    const cell = Cell(0, 0);
    const piece = Piece(TileFamily.cloud, special: SpecialKind.rocket);
    final snapshot = BoardVisualSnapshot(
      tiles: const [
        [piece],
      ],
      blockers: const {},
    );
    collector.observeTurn(
      TurnAnimationTrace(
        from: cell,
        to: const Cell(0, 1),
        originalFrom: piece,
        originalTo: null,
        accepted: true,
        waves: [
          MatchWaveTrace(
            beforeClear: snapshot,
            clearedPieces: {cell: piece},
            createdSpecials: {cell: piece},
            triggeredSpecials: {cell},
            conditionChanges: {cell: piece},
            blockerChanges: {cell: null},
            afterClear: snapshot,
            movements: [
              TileMovement(
                source: cell,
                destination: cell,
                piece: piece,
                segmentTop: 0,
                segmentBottom: 7,
              ),
            ],
            spawns: [
              TileSpawn(
                destination: cell,
                origin: -1,
                piece: piece,
                segmentTop: 0,
                segmentBottom: 7,
              ),
            ],
            afterGravity: snapshot,
          ),
          MatchWaveTrace(
            beforeClear: snapshot,
            clearedPieces: const {},
            createdSpecials: const {},
            triggeredSpecials: const {},
            conditionChanges: const {},
            blockerChanges: const {},
            afterClear: snapshot,
            movements: const [],
            spawns: const [],
            afterGravity: snapshot,
          ),
        ],
        before: snapshot,
        after: snapshot,
        result: const TurnResult(
          accepted: true,
          cleared: {},
          collectedTiles: {},
          scoreGained: 0,
          createdSpecials: [SpecialKind.rocket],
          createdPieces: [piece],
          destroyedBlockers: {},
          cascadeCount: 2,
          changedCells: {},
        ),
      ),
    );

    collector.finish(levelEnded: false);
    final report = jsonDecode(output!.substring('CK_FRAME_TIMING '.length))
        as Map<String, dynamic>;
    expect(report['engineEvents'], {
      'acceptedSwaps': 1,
      'matchWaves': 2,
      'clearedTiles': 1,
      'gravityDrops': 1,
      'refillSpawns': 1,
      'conditionChanges': 1,
      'blockerChanges': 1,
      'createdSpecial.rocket': 1,
      'triggeredSpecial.rocket': 1,
      'maxCascadeWaves': 2,
    });
    expect(output, isNot(contains('0,0')));
  });

  testWidgets('production package identity rejects the profiling collector',
      (tester) async {
    String? output;
    final collector = QaFrameTimingCollector(
      reducedMotion: false,
      warmup: Duration.zero,
      runtimePackageNameForTesting: 'com.mrweeds.cloudkingdom',
      log: (message, {wrapWidth}) => output = message,
    );
    await collector.start();
    await tester.pump(const Duration(milliseconds: 1));
    expect(collector.isCapturing, isFalse);
    collector.ingestTimingBatch([_frame(0)]);
    collector.finish(levelEnded: false);
    expect(output, isNull);
    expect(collector.sampleCount, 0);
  });
}

FrameTiming _frame(int offset) => FrameTiming(
      vsyncStart: offset,
      buildStart: offset + 100,
      buildFinish: offset + 1100,
      rasterStart: offset + 1200,
      rasterFinish: offset + 3100,
      rasterFinishWallTime: offset + 3200,
    );
