import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/main.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/progress_restore.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _launchToTitle(WidgetTester tester) async {
  await tester.pumpWidget(const CloudKingdomApp());
  for (var attempt = 0;
      attempt < 75 &&
          find.text('New Game').evaluate().isEmpty &&
          find.text('Continue').evaluate().isEmpty;
      attempt++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    await tester.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('malformed save shows recovery warning and retains backup',
      (tester) async {
    const damaged = '{"schema":3,"completed":';
    SharedPreferences.setMockInitialValues({progressSaveKey: damaged});

    await _launchToTitle(tester);

    expect(find.text('New Game'), findsOneWidget);
    expect(find.byKey(const ValueKey('save-recovery-warning')), findsOneWidget);
    expect(tester.takeException(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(progressSaveKey), damaged);
    expect(prefs.getString('${progressSaveKey}_unreadable_backup'), damaged);

    await tester.tap(find.text('New Game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Cloud House'), findsWidgets);
    final replaced = prefs.getString(progressSaveKey);
    expect(replaced, isNot(damaged));
    expect(jsonDecode(replaced!)['schema'], 3);
    expect(prefs.getString('${progressSaveKey}_unreadable_backup'), damaged);
    expect(tester.takeException(), isNull);
  });

  test('wrong JSON root is backed up without changing active save', () async {
    const wrongRoot = '[1, 2, 3]';
    SharedPreferences.setMockInitialValues({progressSaveKey: wrongRoot});
    final prefs = await SharedPreferences.getInstance();

    final result = await restoreSavedProgress(prefs);

    expect(result.needsRecovery, isTrue);
    expect(result.backupAvailable, isTrue);
    expect(result.shouldPersistMigration, isFalse);
    expect(result.progress.completedLevels, isEmpty);
    expect(prefs.getString(progressSaveKey), wrongRoot);
    expect(prefs.getString('${progressSaveKey}_unreadable_backup'), wrongRoot);
  });

  test('invalid save field types are retained for recovery', () async {
    const invalidFields = '{"schema":3,"completed":"not-a-list"}';
    SharedPreferences.setMockInitialValues({progressSaveKey: invalidFields});
    final prefs = await SharedPreferences.getInstance();

    final result = await restoreSavedProgress(prefs);

    expect(result.needsRecovery, isTrue);
    expect(result.backupAvailable, isTrue);
    expect(result.shouldPersistMigration, isFalse);
    expect(prefs.getString(progressSaveKey), invalidFields);
    expect(
        prefs.getString('${progressSaveKey}_unreadable_backup'), invalidFields);
  });

  test('malformed legacy progress is retained without forced migration',
      () async {
    const invalidLegacy = '{truncated legacy';
    SharedPreferences.setMockInitialValues(
        {legacyProgressSaveKey: invalidLegacy});
    final prefs = await SharedPreferences.getInstance();

    final result = await restoreSavedProgress(prefs);

    expect(result.needsRecovery, isTrue);
    expect(result.backupAvailable, isTrue);
    expect(result.shouldPersistMigration, isFalse);
    expect(prefs.getString(legacyProgressSaveKey), invalidLegacy);
    expect(prefs.getString('${legacyProgressSaveKey}_unreadable_backup'),
        invalidLegacy);
    expect(prefs.getString(progressSaveKey), isNull);
  });

  test('valid completed progress retains Continue state without backup',
      () async {
    const saved =
        '{"schema":3,"completed":[1],"stars":[1],"best":{"1":1020},"coins":100}';
    SharedPreferences.setMockInitialValues({progressSaveKey: saved});
    final prefs = await SharedPreferences.getInstance();

    final result = await restoreSavedProgress(prefs);

    expect(result.needsRecovery, isFalse);
    expect(result.shouldPersistMigration, isFalse);
    expect(result.progress.completedLevels, contains(1));
    expect(result.progress.coins, 100);
    expect(prefs.getString(progressSaveKey), saved);
    expect(prefs.getString('${progressSaveKey}_unreadable_backup'), isNull);
  });

  test('valid legacy data is migrated without resetting historical progress',
      () async {
    const legacy =
        '{"completed":[1],"best":{"1":512},"coins":80,"loungeStyle":"Classic Cloud"}';
    SharedPreferences.setMockInitialValues({legacyProgressSaveKey: legacy});
    final prefs = await SharedPreferences.getInstance();

    final result = await restoreSavedProgress(prefs);

    expect(result.needsRecovery, isFalse);
    expect(result.shouldPersistMigration, isTrue);
    expect(result.progress.completedLevels, {1});
    expect(result.progress.coins, 80);
    expect(result.progress.loungeStyleId, 'classic_cloud');
    expect(prefs.getString(legacyProgressSaveKey), legacy);
  });

  test('empty local data initializes a fresh save without corruption warning',
      () async {
    final prefs = await SharedPreferences.getInstance();

    final result = await restoreSavedProgress(prefs);

    expect(result.needsRecovery, isFalse);
    expect(result.shouldPersistMigration, isTrue);
    expect(result.progress.completedLevels, isEmpty);
    expect(result.progress.coins, 0);
    expect(prefs.getString(progressSaveKey), isNull);
  });
}
