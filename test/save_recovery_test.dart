import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _currentKey = 'cloud_kingdom_progress_v2';
const _legacyKey = 'cloud_kingdom_save_v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('malformed save boots safely and preserves original plus backup',
      (tester) async {
    const damaged = '{"schema":3,"completed":';
    SharedPreferences.setMockInitialValues({_currentKey: damaged});

    await tester.pumpWidget(const CloudKingdomApp());
    await tester.pumpAndSettle();

    expect(find.text('New Game'), findsOneWidget);
    expect(find.byKey(const ValueKey('save-recovery-warning')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(_currentKey), damaged);
    expect(prefs.getString('${_currentKey}_unreadable_backup'), damaged);

    await tester.tap(find.text('New Game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Cloud House'), findsWidgets);
    final replaced = prefs.getString(_currentKey);
    expect(replaced, isNot(damaged));
    expect(jsonDecode(replaced!)['schema'], 3);
    expect(prefs.getString('${_currentKey}_unreadable_backup'), damaged);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrong JSON root does not leave a permanent boot spinner',
      (tester) async {
    const wrongRoot = '[1, 2, 3]';
    SharedPreferences.setMockInitialValues({_currentKey: wrongRoot});

    await tester.pumpWidget(const CloudKingdomApp());
    await tester.pumpAndSettle();

    expect(find.text('New Game'), findsOneWidget);
    expect(find.byKey(const ValueKey('save-recovery-warning')), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(_currentKey), wrongRoot);
    expect(prefs.getString('${_currentKey}_unreadable_backup'), wrongRoot);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid save field types do not discard original progress bytes',
      (tester) async {
    const invalidFields = '{"schema":3,"completed":"not-a-list"}';
    SharedPreferences.setMockInitialValues({_currentKey: invalidFields});

    await tester.pumpWidget(const CloudKingdomApp());
    await tester.pumpAndSettle();

    expect(find.text('New Game'), findsOneWidget);
    expect(find.byKey(const ValueKey('save-recovery-warning')), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(_currentKey), invalidFields);
    expect(prefs.getString('${_currentKey}_unreadable_backup'), invalidFields);
    expect(tester.takeException(), isNull);
  });

  testWidgets('malformed legacy save is preserved without forced migration',
      (tester) async {
    const invalidLegacy = '{truncated legacy';
    SharedPreferences.setMockInitialValues({_legacyKey: invalidLegacy});

    await tester.pumpWidget(const CloudKingdomApp());
    await tester.pumpAndSettle();

    expect(find.text('New Game'), findsOneWidget);
    expect(find.byKey(const ValueKey('save-recovery-warning')), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(_legacyKey), invalidLegacy);
    expect(prefs.getString('${_legacyKey}_unreadable_backup'), invalidLegacy);
    expect(prefs.getString(_currentKey), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('valid completed progress still offers Continue without warning',
      (tester) async {
    const saved =
        '{"schema":3,"completed":[1],"stars":[1],"best":{"1":1020},"coins":100}';
    SharedPreferences.setMockInitialValues({_currentKey: saved});

    await tester.pumpWidget(const CloudKingdomApp());
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
    expect(find.byKey(const ValueKey('save-recovery-warning')), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(_currentKey), saved);
    expect(prefs.getString('${_currentKey}_unreadable_backup'), isNull);
    expect(tester.takeException(), isNull);
  });
}
