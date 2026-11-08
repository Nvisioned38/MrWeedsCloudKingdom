import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';

void main() {
  test('partial save defaults missing fields and preserves completed progress',
      () {
    final restored = ProgressState.fromJson({
      'schema': 3,
      'completed': [1, 2],
      'best': {'1': 1020},
      'coins': 100,
      'stars': [1],
      'settings': {'haptics': false},
    });

    expect(restored.completedLevels, {1, 2});
    expect(restored.bestScores, {1: 1020});
    expect(restored.coins, 100);
    expect(restored.starLevelIds, {1});
    expect(restored.keys, 0);
    expect(restored.collectionXp, 0);
    expect(restored.settings['haptics'], isFalse);
    expect(restored.settings['reducedMotion'], isFalse);

    final roundTripped = ProgressState.fromJson(restored.toJson());
    expect(roundTripped.completedLevels, {1, 2});
    expect(roundTripped.bestScores, {1: 1020});
    expect(roundTripped.coins, 100);
    expect(roundTripped.starLevelIds, {1});
  });

  test('replayed first-clear after reload does not grant duplicate rewards',
      () async {
    final levelData = jsonDecode(
      await File('assets/data/levels_001_030.json').readAsString(),
    ) as Map<String, dynamic>;
    final levels = (levelData['levels'] as List)
        .cast<Map<String, dynamic>>()
        .map(LevelSpec.fromJson);
    final level = levels.firstWhere((candidate) => candidate.id == 1);
    final progress = ProgressState();

    final firstClear = progress.grantFirstClear(level, 1020);
    final restored = ProgressState.fromJson(progress.toJson());
    final replay = restored.grantFirstClear(level, 1500);

    expect(firstClear.firstClear, isTrue);
    expect(firstClear.coins, 100);
    expect(firstClear.collectionXp, 6);
    expect(replay.firstClear, isFalse);
    expect(replay.coins, 0);
    expect(replay.collectionXp, 0);
    expect(restored.coins, 100);
    expect(restored.collectionXp, 6);
    expect(restored.bestScores[1], 1500);
  });

  test('Android package configuration keeps QA and production identities apart',
      () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(gradle, contains('com.mrweeds.cloudkingdom.qa'));
    expect(gradle, contains('com.mrweeds.cloudkingdom'));
    expect(gradle, contains('providers.gradleProperty("cloudKingdomQa")'));
    expect(manifest, contains('android:label="\${appLabel}"'));
  });
}
