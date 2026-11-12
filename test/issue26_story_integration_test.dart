import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';
import 'package:mr_weeds_cloud_kingdom/domain/phase2_models.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/art_widgets.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/phase2_screens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StoryCatalog story;
  late CharacterCatalog characters;

  setUpAll(() async {
    story = StoryCatalog.fromJson(
      jsonDecode(
        await rootBundle.loadString('assets/data/story_chapters.json'),
      ) as Map<String, dynamic>,
    );
    characters = CharacterCatalog.fromJson(
      jsonDecode(
        await rootBundle.loadString('assets/data/characters.json'),
      ) as Map<String, dynamic>,
    );
  });

  testWidgets(
    'Chapter 2 gates Riff at Level 16 and persists his dialogue flags',
    (tester) async {
      final progress = _completedThrough(14);
      var persistCalls = 0;
      String? savedSnapshot;

      await _showStory(tester, story, characters, progress, () async {
        persistCalls++;
        savedSnapshot = jsonEncode(progress.toJson());
      });

      expect(
          find.textContaining('1 of 3 story beats available'), findsOneWidget);
      await tester.tap(find.text('Kitchen Catastrophe'));
      await tester.pumpAndSettle();
      expect(
          find.textContaining('Welcome to my cloud kitchen!'), findsOneWidget);
      expect(find.text('Riff'), findsNothing);

      // Leave through normal navigation before opening the chapter again.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(progress.storyFlags, isEmpty);
      expect(persistCalls, 0);

      progress.completedLevels.add(15); // Level 16 is now unlocked.
      await _showStory(tester, story, characters, progress, () async {
        persistCalls++;
        savedSnapshot = jsonEncode(progress.toJson());
      });
      expect(
          find.textContaining('2 of 3 story beats available'), findsOneWidget);
      await tester.tap(find.text('Kitchen Catastrophe'));
      await tester.pumpAndSettle();
      expect(
          find.textContaining(
              'A good rhythm makes any bit of work feel lighter.'),
          findsNothing);
      expect(find.text('Chef Blaze'), findsOneWidget);
      _expectDialoguePortrait(tester, characters, 'chef_blaze');
      final expectedSpeakers = [
        ('mr_weed', null),
        ('chef_blaze', null),
        ('mr_weed', null),
        ('riff', 'playful'),
      ];
      for (final (speakerId, expression) in expectedSpeakers) {
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        final speaker = characters.byId(speakerId)!;
        expect(find.text(speaker.displayName), findsOneWidget);
        _expectDialoguePortrait(
          tester,
          characters,
          speakerId,
          expression: expression,
        );
      }

      expect(find.text('Riff'), findsOneWidget);
      final riff = characters.byId('riff')!;
      expect(
        tester
            .widget<DialogueCharacterPortrait>(
              find.byType(DialogueCharacterPortrait),
            )
            .assetKey,
        riff.expressionAssetKeys['playful'],
      );
      expect(find.text('Close Story'), findsOneWidget);

      await tester.tap(find.text('Close Story'));
      await tester.pumpAndSettle();
      expect(find.text('Kitchen Catastrophe'), findsOneWidget);
      expect(
          progress.storyFlags,
          containsAll([
            'story_kitchen_welcome_seen',
            'story_kitchen_progress_seen',
            'character_chef_blaze_known',
            'character_riff_known',
          ]));
      expect(progress.storyFlags, isNot(contains('chapter_2_complete')));
      expect(progress.completedChapterIds, isNot(contains('chapter_2')));
      expect(persistCalls, 1);
      expect(
        ProgressState.fromJson(
          jsonDecode(savedSnapshot!) as Map<String, dynamic>,
        ).storyFlags,
        contains('character_riff_known'),
      );
    },
  );

  testWidgets('QA story launcher seeds disposable Level 16 and Level 26 states',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Issue26CharacterPreviewScreen(
        characters: characters,
        story: story,
      ),
    ));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('never update the game save'),
      findsOneWidget,
    );

    await tester.tap(find.text('Chapter 2 before Riff — Level 15 preview'));
    await tester.pumpAndSettle();
    expect(find.text('Story Fixture · Level 15'), findsOneWidget);
    expect(find.textContaining('TEMPORARY QA FIXTURE'), findsOneWidget);
    expect(find.textContaining('1 of 3 story beats available'), findsOneWidget);
    expect(find.text('Riff'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Riff story fixture — Level 16 unlocked'));
    await tester.pumpAndSettle();
    expect(find.text('Story Fixture · Level 16'), findsOneWidget);
    expect(find.textContaining('2 of 3 story beats available'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chapter 3 before Mona — Level 25 preview'));
    await tester.pumpAndSettle();
    expect(find.text('Story Fixture · Level 25'), findsOneWidget);
    expect(find.textContaining('1 of 3 story beats available'), findsOneWidget);
    expect(find.text('Mona Chromatic'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mona story fixture — Level 26 unlocked'));
    await tester.pumpAndSettle();
    expect(find.text('Story Fixture · Level 26'), findsOneWidget);
    expect(find.textContaining('2 of 3 story beats available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Chapter 3 gates Mona at Level 26 and switches to her thinking portrait',
    (tester) async {
      final progress = _completedThrough(24);
      var persistCalls = 0;
      await _showStory(tester, story, characters, progress, () async {
        persistCalls++;
      });

      expect(
          find.textContaining('1 of 3 story beats available'), findsOneWidget);
      await tester.tap(find.text('The Missing Collection'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Several cards and display labels'),
          findsOneWidget);
      expect(find.text('Mona Chromatic'), findsNothing);
      expect(find.text('The Collector'), findsOneWidget);
      _expectDialoguePortrait(tester, characters, 'the_collector');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(progress.storyFlags, isEmpty);
      expect(persistCalls, 0);

      progress.completedLevels.add(25); // Level 26 and its story beat unlock.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _showStory(tester, story, characters, progress, () async {
        persistCalls++;
      });
      expect(
          find.textContaining('2 of 3 story beats available'), findsOneWidget);
      await tester.tap(find.text('The Missing Collection'));
      await tester.pumpAndSettle();
      final expectedSpeakers = [
        ('mr_weed', null),
        ('the_collector', null),
        ('mr_weed', null),
        ('mona_chromatic', 'thinking'),
      ];
      for (final (speakerId, expression) in expectedSpeakers) {
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        final speaker = characters.byId(speakerId)!;
        expect(find.text(speaker.displayName), findsOneWidget);
        _expectDialoguePortrait(
          tester,
          characters,
          speakerId,
          expression: expression,
        );
      }

      expect(find.text('Mona Chromatic'), findsOneWidget);
      final mona = characters.byId('mona_chromatic')!;
      expect(
        tester
            .widget<DialogueCharacterPortrait>(
              find.byType(DialogueCharacterPortrait),
            )
            .assetKey,
        mona.expressionAssetKeys['thinking'],
      );
      expect(find.text('Close Story'), findsOneWidget);
      await tester.tap(find.text('Close Story'));
      await tester.pumpAndSettle();

      expect(
          progress.storyFlags,
          containsAll([
            'story_collection_search_seen',
            'story_collection_clue_seen',
            'character_the_collector_known',
            'character_mona_chromatic_known',
          ]));
      expect(progress.storyFlags, isNot(contains('chapter_3_complete')));
      expect(progress.completedChapterIds, isNot(contains('chapter_3')));
      expect(persistCalls, 1);
    },
  );

  testWidgets('Chapter 2 completion flag waits for Level 20 and full dialogue',
      (tester) async {
    final progress = _completedThrough(20);
    var persistCalls = 0;
    await _showStory(tester, story, characters, progress, () async {
      persistCalls++;
    });
    await tester.tap(find.text('Kitchen Catastrophe'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Complete Chapter'), findsOneWidget);
    expect(progress.storyFlags, isNot(contains('chapter_2_complete')));
    await tester.tap(find.text('Complete Chapter'));
    await tester.pumpAndSettle();
    expect(progress.completedChapterIds, contains('chapter_2'));
    expect(progress.storyFlags, contains('chapter_2_complete'));
    expect(progress.storyFlags, contains('character_riff_known'));
    expect(persistCalls, 1);
  });

  testWidgets('Chapter 3 completion flag waits for Level 30 and full dialogue',
      (tester) async {
    final progress = _completedThrough(30);
    var persistCalls = 0;
    await _showStory(tester, story, characters, progress, () async {
      persistCalls++;
    });
    await tester.tap(find.text('The Missing Collection'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Complete Chapter'), findsOneWidget);
    expect(progress.storyFlags, isNot(contains('chapter_3_complete')));
    await tester.tap(find.text('Complete Chapter'));
    await tester.pumpAndSettle();
    expect(progress.completedChapterIds, contains('chapter_3'));
    expect(progress.storyFlags, contains('chapter_3_complete'));
    expect(progress.storyFlags, contains('character_mona_chromatic_known'));
    expect(persistCalls, 1);
  });

  testWidgets(
    'Riff and Mona portraits fit safe areas at normal and 2x text in both orientations',
    (tester) async {
      final dialogueCases = [
        (
          chapterId: 'chapter_2',
          beatId: 'kitchen_progress',
          characterId: 'riff',
          expression: 'playful',
        ),
        (
          chapterId: 'chapter_3',
          beatId: 'collection_clue',
          characterId: 'mona_chromatic',
          expression: 'thinking',
        ),
      ];
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final size in [const Size(390, 844), const Size(844, 390)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        for (final scale in [1.0, 2.0]) {
          for (final dialogueCase in dialogueCases) {
            final chapter = story.chapters.singleWhere(
              (item) => item.id == dialogueCase.chapterId,
            );
            final beat = chapter.beats.singleWhere(
              (item) => item.id == dialogueCase.beatId,
            );
            final availableBeats = chapter.beats
                .takeWhile((item) => item.unlockAtLevel <= beat.unlockAtLevel)
                .toList(growable: false);
            await tester.pumpWidget(MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  padding: const EdgeInsets.only(top: 28, bottom: 24),
                  viewPadding: const EdgeInsets.only(top: 28, bottom: 24),
                ),
                child: child!,
              ),
              home: ChapterDialogPage(
                key: ValueKey('${chapter.id}-${scale}x-${size.width}'),
                chapter: chapter,
                beats: availableBeats,
                characters: characters,
                canComplete: false,
                onComplete: () async {},
              ),
            ));
            await tester.pumpAndSettle();

            for (var i = 0; i < 4; i++) {
              final continueButton = find.text('Continue');
              expect(
                continueButton,
                findsOneWidget,
                reason:
                    'continue step $i at $size, ${scale}x, ${dialogueCase.characterId}',
              );
              await tester.ensureVisible(continueButton);
              await tester.tap(continueButton);
              await tester.pumpAndSettle();
            }
            final character = characters.byId(dialogueCase.characterId)!;
            final portrait = tester.widget<DialogueCharacterPortrait>(
              find.byType(DialogueCharacterPortrait),
            );
            expect(portrait.character.id, dialogueCase.characterId);
            expect(
              portrait.assetKey,
              character.expressionAssetKeys[dialogueCase.expression],
            );
            expect(
              tester.takeException(),
              isNull,
              reason:
                  'viewport $size at ${scale}x for ${dialogueCase.characterId}',
            );
          }
        }
      }
    },
  );
}

ProgressState _completedThrough(int level) => ProgressState()
  ..completedLevels.addAll(List<int>.generate(level, (index) => index + 1));

Future<void> _showStory(
  WidgetTester tester,
  StoryCatalog story,
  CharacterCatalog characters,
  ProgressState progress,
  Future<void> Function() persist,
) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: StoryScreen(
        catalog: story,
        characters: characters,
        progress: progress,
        persist: persist,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void _expectDialoguePortrait(
  WidgetTester tester,
  CharacterCatalog characters,
  String characterId, {
  String? expression,
}) {
  final character = characters.byId(characterId)!;
  final portrait = tester.widget<DialogueCharacterPortrait>(
    find.byType(DialogueCharacterPortrait),
  );
  expect(portrait.character.id, characterId);
  expect(
    portrait.assetKey,
    expression == null
        ? character.portraitAssetKey
        : character.expressionAssetKeys[expression],
  );
}
