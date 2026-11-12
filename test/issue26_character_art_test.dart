import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/phase2_models.dart';
import 'package:mr_weeds_cloud_kingdom/presentation/art_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Riff and Mona locked assets are mapped without exposing review exports',
    () async {
      final characterData = jsonDecode(
        await rootBundle.loadString('assets/data/characters.json'),
      ) as Map<String, dynamic>;
      final catalog = CharacterCatalog.fromJson(characterData);

      for (final id in ['riff', 'mona_chromatic']) {
        final character = catalog.byId(id)!;
        expect(character.knownByDefault, isFalse);
        expect(character.roundUiAssetKey, isNotNull);
        expect(character.squareUiAssetKey, isNotNull);
        expect(
          character.expressionAssetKeys.keys,
          containsAll([
            'happy',
            'excited',
            'clever',
            'playful',
            'thinking',
            'surprised',
            'proud',
            'wink',
          ]),
        );
        for (final key in [
          character.portraitAssetKey,
          character.fullBodyAssetKey,
          character.roundUiAssetKey!,
          character.squareUiAssetKey!,
          ...character.expressionAssetKeys.values,
        ]) {
          expect(ArtRegistry.pathFor(key), isNotNull, reason: '$id: $key');
        }
      }

      const expectedExpressions = {
        'chef_blaze': ['happy', 'excited', 'thinking', 'determined', 'playful'],
        'dr_cloud': ['happy', 'surprised', 'thinking', 'curious', 'determined'],
        'the_collector': [
          'excited',
          'surprised',
          'thinking',
          'determined',
          'satisfied',
        ],
      };
      const expectedUiStates = {
        'chef_blaze': ['neutral', 'excited'],
        'dr_cloud': ['neutral', 'excited'],
        'the_collector': ['neutral', 'happy'],
      };
      for (final id in expectedExpressions.keys) {
        final character = catalog.byId(id)!;
        expect(character.knownByDefault, isFalse);
        expect(character.expressionAssetKeys.keys.toSet(),
            expectedExpressions[id]!.toSet());
        expect(
            character.uiAssetKeys.keys.toSet(), expectedUiStates[id]!.toSet());
        for (final key in [
          character.portraitAssetKey,
          character.fullBodyAssetKey,
          ...character.expressionAssetKeys.values,
          ...character.uiAssetKeys.values,
        ]) {
          expect(ArtRegistry.pathFor(key), isNotNull, reason: '$id: $key');
        }
      }
      expect(
        ArtRegistry.paths.keys.where(
          (key) => key.startsWith('issue26_review_'),
        ),
        isEmpty,
      );
    },
  );

  test(
    'Riff and Mona only join their in-scope authored story chapters',
    () async {
      final storyData = jsonDecode(
        await rootBundle.loadString('assets/data/story_chapters.json'),
      ) as Map<String, dynamic>;
      final chapters = StoryCatalog.fromJson(storyData).chapters;
      final kitchen = chapters.singleWhere(
        (chapter) => chapter.id == 'chapter_2',
      );
      final collection = chapters.singleWhere(
        (chapter) => chapter.id == 'chapter_3',
      );
      expect(kitchen.characterIds, contains('riff'));
      expect(collection.characterIds, contains('mona_chromatic'));
      final riffLines = kitchen.beats
          .expand((beat) => beat.lines)
          .where((line) => line.speakerId == 'riff');
      final monaLines = collection.beats
          .expand((beat) => beat.lines)
          .where((line) => line.speakerId == 'mona_chromatic');
      expect(riffLines, hasLength(1));
      expect(riffLines.single.expressionKey, 'playful');
      expect(
        characterKnownFlagsForBeats(kitchen.beats),
        containsAll(['character_chef_blaze_known', 'character_riff_known']),
      );
      expect(monaLines, hasLength(1));
      expect(monaLines.single.expressionKey, 'thinking');
      expect(
        characterKnownFlagsForBeats(collection.beats),
        containsAll([
          'character_the_collector_known',
          'character_mona_chromatic_known',
        ]),
      );
      expect(
        chapters
            .singleWhere((chapter) => chapter.id == 'chapter_1')
            .characterIds,
        isNot(contains('riff')),
      );
    },
  );
}
