import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'cold start with empty local data reaches the offline title and hub',
      (tester) async {
    await tester.pumpWidget(const CloudKingdomApp());
    for (var attempt = 0;
        attempt < 75 && find.text('New Game').evaluate().isEmpty;
        attempt++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pump();
    }

    expect(find.text('New Game'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('New Game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Cloud House'), findsWidgets);
    expect(find.text('First Puff'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
