import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/match3_art_widgets.dart';

void main() {
  testWidgets(
      'objectives backing grows with one, two, or three long rows at 0.9x–2x text',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const longLocalizedLabel =
        'Destroy the reinforced crates around the cloud castle';
    final definitions = <ObjectiveDefinition>[
      const ObjectiveDefinition(
        kind: ObjectiveKind.destroyBlockers,
        blocker: BlockerKind.crate,
        target: 6,
      ),
      const ObjectiveDefinition(
        kind: ObjectiveKind.destroyBlockers,
        blocker: BlockerKind.reinforcedCrate,
        target: 6,
      ),
      const ObjectiveDefinition(kind: ObjectiveKind.score, target: 3500),
    ];

    for (final scale in [0.9, 1.0, 1.5, 2.0]) {
      final heightsByCount = <int, double>{};
      for (var count = 1; count <= definitions.length; count++) {
        final objectives = definitions
            .take(count)
            .map(ObjectiveProgress.new)
            .toList(growable: false);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 380,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Match3ObjectivePanel(
                            objectives: objectives,
                            labelForObjective: (objective) =>
                                identical(objective, objectives.first)
                                    ? longLocalizedLabel
                                    : objective.label,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Match3MovesCounter(movesRemaining: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final panel = tester.getRect(
          find.byKey(const ValueKey('issue4-objectives-panel')),
        );
        heightsByCount[count] = panel.height;
        expect(
          find.byKey(const ValueKey('issue4-objectives-adaptive-backing')),
          findsOneWidget,
          reason: 'The same adaptive frame is used at text scale $scale.',
        );
        expect(tester.getRect(find.text('OBJECTIVES')).top,
            greaterThan(panel.top));
        expect(tester.getRect(find.text('OBJECTIVES')).bottom,
            lessThan(panel.bottom));
        expect(find.text(longLocalizedLabel), findsOneWidget);
        final panelTexts = find.descendant(
          of: find.byKey(const ValueKey('issue4-objectives-panel')),
          matching: find.byType(Text),
        );
        for (final text in panelTexts.evaluate()) {
          final textRect = tester.getRect(find.byWidget(text.widget));
          expect(textRect.left, greaterThanOrEqualTo(panel.left));
          expect(textRect.right, lessThanOrEqualTo(panel.right));
          expect(textRect.top, greaterThanOrEqualTo(panel.top));
          expect(textRect.bottom, lessThanOrEqualTo(panel.bottom));
        }
        final counterText = find.descendant(
          of: find.byKey(const ValueKey('issue4-moves-counter')),
          matching: find.text('30'),
        );
        expect(tester.getRect(counterText).width, lessThanOrEqualTo(68));
        expect(tester.takeException(), isNull);
      }
      expect(heightsByCount[2], greaterThan(heightsByCount[1]!));
      expect(heightsByCount[3], greaterThan(heightsByCount[2]!));
    }
  });

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
      find.byKey(
        const ValueKey('assets/art/match3/moves_counter_backing_low.png'),
      ),
      findsOneWidget,
    );

    await tester
        .tap(find.byKey(const ValueKey('issue4-action-Back to Cloud House')));
    expect(activated, isTrue);
  });

  test('legacy tile identity uses the approved Mystic Bloom objective label',
      () {
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

    expect(find.byKey(const ValueKey('issue4-vaporizer-art')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('issue4-cloud-cup-logo-overlay')),
      findsOneWidget,
    );
  });
}
