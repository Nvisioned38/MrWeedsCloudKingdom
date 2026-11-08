import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/match3_art_widgets.dart';

void main() {
  testWidgets('approved modular HUD keeps counters and labels dynamic',
      (tester) async {
    var activated = false;
    final objective = ObjectiveProgress(
      const ObjectiveDefinition(
        kind: ObjectiveKind.collect,
        target: 5,
        family: TileFamily.cloud,
      ),
      2,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              Match3ObjectivePanel(objectives: [objective]),
              const Match3MovesCounter(movesRemaining: 2),
              const Match3ScoreProgress(
                score: 60,
                scoreTarget: 100,
                clearAvailable: false,
              ),
              Match3PrimaryArtButton(
                label: 'Back to Cloud House',
                onPressed: () => activated = true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Collect blue Cloud tiles'), findsOneWidget);
    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Score 60'), findsOneWidget);
    expect(find.text('Back to Cloud House'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/art/match3/moves_counter_backing_low.png',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('issue4-action-Back to Cloud House')));
    expect(activated, isTrue);
  });

  test('legacy tile identity uses the approved Mystic Bloom objective label', () {
    final objective = ObjectiveProgress(
      const ObjectiveDefinition(
        kind: ObjectiveKind.collect,
        target: 3,
        family: TileFamily.leaf,
      ),
    );

    expect(objective.label, 'Collect Mystic Bloom tiles');
  });

  testWidgets('Cloud Cup brand remains a separate canonical logo overlay',
      (tester) async {
    final session = LevelSession(
      const LevelSpec(
        id: 1,
        name: 'Test Cloud',
        seed: 42,
        moves: 10,
        objectives: [
          ObjectiveDefinition(kind: ObjectiveKind.score, target: 999),
        ],
        blockers: [],
        coins: 0,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Match3SpecialsGuide(session: session)),
      ),
    );
    await tester.tap(find.text('Specials guide'));
    await tester.pumpAndSettle();

    final imagePaths = tester.widgetList<Image>(find.byType(Image)).map(
          (image) => (image.image as AssetImage).assetName,
        );
    expect(imagePaths, contains('assets/art/match3/cloud_cup_vaporizer.png'));
    expect(imagePaths, contains('assets/art/brand/cloud_cup_logo.png'));
  });
}
