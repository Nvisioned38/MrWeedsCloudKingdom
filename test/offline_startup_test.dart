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
    await tester.pumpAndSettle();

    expect(find.text('New Game'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('New Game'));
    await tester.pumpAndSettle();

    expect(find.text('Cloud House'), findsWidgets);
    expect(find.text('First Puff'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
