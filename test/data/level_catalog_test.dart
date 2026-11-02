import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_weeds_cloud_kingdom/domain/match3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'runtime catalog preserves Levels 1-10 and adds playable authored Levels 11-30',
      () async {
    final raw = await rootBundle.loadString('assets/data/levels_001_030.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final levels = (json['levels'] as List)
        .cast<Map<String, dynamic>>()
        .map(LevelSpec.fromJson)
        .toList();
    expect(levels, hasLength(30));
    expect(levels.map((level) => level.id), List.generate(30, (i) => i + 1));
    expect(levels.take(10).map((level) => level.seed),
        [1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010]);
    expect(levels.take(10).map((level) => level.moves),
        [18, 20, 20, 22, 22, 24, 25, 26, 27, 30]);
    expect(levels.take(10).map((level) => level.coins),
        [100, 110, 120, 130, 140, 150, 165, 180, 200, 250]);
    expect(levels[4].blockers.map((blocker) => blocker.cell).toSet(), {
      const Cell(2, 2),
      const Cell(2, 5),
      const Cell(3, 3),
      const Cell(3, 4),
      const Cell(5, 2),
      const Cell(5, 5),
    });
    expect(
        levels[6]
            .blockers
            .every((blocker) => blocker.kind == BlockerKind.reinforcedCrate),
        isTrue);
    expect(levels[9].objectives, hasLength(3));
    expect(levels[19].chapterName, 'Kitchen Catastrophe');
    expect(levels[29].chapterName, 'The Missing Collection');
    expect(levels[19].isChapterFinale, isTrue);
    expect(levels[29].isChapterFinale, isTrue);
    expect(levels[29].keys, 1);
    for (final level in levels) {
      expect(level.objectives, isNotEmpty,
          reason: 'Level ${level.id} has goals.');
      expect(
          level.objectives.every(
              (objective) => ObjectiveKind.values.contains(objective.kind)),
          isTrue);
      final board = Match3Board(level: level);
      expect(board.findMatches(), isEmpty,
          reason: 'Level ${level.id} starts match-free.');
      expect(board.hasLegalMove, isTrue,
          reason: 'Level ${level.id} starts playable.');
      expect(board.blockers.length, level.blockers.length);
    }
  });
}
