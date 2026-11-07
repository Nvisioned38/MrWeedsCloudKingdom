import 'dart:math';

import 'phase2_models.dart';

enum TileFamily { cloud, leaf, sun, moon, star }

enum SpecialKind { rocket, prism, cloudBomb }

enum RocketDirection { horizontal, vertical }

enum BlockerKind { crate, reinforcedCrate }

enum PuzzlePerk { none, cloudNineScoreHeadstart }

enum ObjectiveKind { score, collect, destroyBlockers, createSpecial }

enum LevelOutcome { playing, won, lost }

class Cell {
  const Cell(this.row, this.col);
  final int row;
  final int col;
  @override
  bool operator ==(Object other) =>
      other is Cell && row == other.row && col == other.col;
  @override
  int get hashCode => Object.hash(row, col);
  @override
  String toString() => '($row,$col)';
}

class Piece {
  const Piece(this.family,
      {this.special,
      this.direction,
      this.stickySyrup = false,
      this.fogged = false});
  final TileFamily family;
  final SpecialKind? special;
  final RocketDirection? direction;
  final bool stickySyrup;
  final bool fogged;
  Piece withSpecial(SpecialKind value, {RocketDirection? direction}) =>
      Piece(family,
          special: value,
          direction: direction,
          stickySyrup: stickySyrup,
          fogged: fogged);
  Piece withConditions({bool? stickySyrup, bool? fogged}) => Piece(family,
      special: special,
      direction: direction,
      stickySyrup: stickySyrup ?? this.stickySyrup,
      fogged: fogged ?? this.fogged);
}

class BlockerState {
  BlockerState(this.kind) : hp = kind == BlockerKind.crate ? 1 : 2;
  BlockerState._(this.kind, this.hp);
  final BlockerKind kind;
  int hp;
  bool get damaged => kind == BlockerKind.reinforcedCrate && hp == 1;
  bool takeHit() {
    hp = hp > 0 ? hp - 1 : 0;
    return hp == 0;
  }

  BlockerState copy() => BlockerState._(kind, hp);
}

class ObjectiveDefinition {
  const ObjectiveDefinition(
      {required this.kind,
      required this.target,
      this.family,
      this.blocker,
      this.special});
  final ObjectiveKind kind;
  final int target;
  final TileFamily? family;
  final BlockerKind? blocker;
  final SpecialKind? special;

  factory ObjectiveDefinition.fromJson(Map<String, dynamic> json) =>
      ObjectiveDefinition(
        kind: switch (json['type']) {
          'score' => ObjectiveKind.score,
          'collect' => ObjectiveKind.collect,
          'destroy_blockers' => ObjectiveKind.destroyBlockers,
          'create_special' => ObjectiveKind.createSpecial,
          _ => throw FormatException('Unknown objective type: ${json['type']}'),
        },
        target: json['target'] as int,
        family: json['family'] == null
            ? null
            : TileFamily.values.byName(json['family'] as String),
        blocker: json['blocker'] == null
            ? null
            : _blockerFromName(json['blocker'] as String),
        special: json['special'] == null
            ? null
            : _specialFromName(json['special'] as String),
      );
}

SpecialKind _specialFromName(String name) => switch (name) {
      'rocket' => SpecialKind.rocket,
      'prism' => SpecialKind.prism,
      'cloud_bomb' => SpecialKind.cloudBomb,
      _ => throw FormatException('Unknown special: $name'),
    };

BlockerKind _blockerFromName(String name) => switch (name) {
      'crate' => BlockerKind.crate,
      'reinforced_crate' => BlockerKind.reinforcedCrate,
      _ => throw FormatException('Unknown blocker: $name'),
    };

class BlockerDefinition {
  const BlockerDefinition(this.cell, this.kind);
  final Cell cell;
  final BlockerKind kind;
}

class LevelSpec {
  const LevelSpec(
      {required this.id,
      required this.name,
      required this.seed,
      required this.moves,
      required this.objectives,
      required this.blockers,
      required this.coins,
      this.tutorial,
      this.chapter = 1,
      this.chapterName = 'Welcome to the Clouds',
      this.chapterPosition = 1,
      this.collectionXp = 0,
      this.keys = 0,
      this.sourceObjectiveIntent,
      this.isChapterFinale = false,
      this.stickySyrupCells = const [],
      this.fogCells = const []});
  final int id;
  final String name;
  final int seed;
  final int moves;
  final List<ObjectiveDefinition> objectives;
  final List<BlockerDefinition> blockers;
  final int coins;
  final String? tutorial;
  final int chapter;
  final String chapterName;
  final int chapterPosition;
  final int collectionXp;
  final int keys;
  final String? sourceObjectiveIntent;
  final bool isChapterFinale;
  final List<Cell> stickySyrupCells;
  final List<Cell> fogCells;

  factory LevelSpec.fromJson(Map<String, dynamic> json) => LevelSpec(
        id: json['id'] as int,
        name: json['name'] as String,
        seed: json['seed'] as int,
        moves: json['moves'] as int,
        objectives: (json['objectives'] as List)
            .cast<Map<String, dynamic>>()
            .map(ObjectiveDefinition.fromJson)
            .toList(growable: false),
        blockers: (json['blockers'] as List)
            .cast<Map<String, dynamic>>()
            .map((entry) => BlockerDefinition(
                  Cell(entry['row'] as int, entry['col'] as int),
                  _blockerFromName(entry['type'] as String),
                ))
            .toList(growable: false),
        coins: json['coins'] as int,
        tutorial: json['tutorial'] as String?,
        chapter: json['chapter'] as int? ?? 1,
        chapterName: json['chapterName'] as String? ??
            (json['chapter'] == 2
                ? 'Kitchen Catastrophe'
                : json['chapter'] == 3
                    ? 'The Missing Collection'
                    : 'Welcome to the Clouds'),
        chapterPosition: json['chapterPosition'] as int? ?? 1,
        collectionXp: json['collectionXp'] as int? ?? 0,
        keys: json['keys'] as int? ?? 0,
        sourceObjectiveIntent: json['sourceObjectiveIntent'] as String?,
        isChapterFinale: json['isChapterFinale'] as bool? ?? false,
        stickySyrupCells: _cellsFromJson(json['stickySyrup']),
        fogCells: _cellsFromJson(json['fog']),
      );
}

List<Cell> _cellsFromJson(dynamic value) => (value as List? ?? const [])
    .cast<Map<String, dynamic>>()
    .map((entry) => Cell(entry['row'] as int, entry['col'] as int))
    .toList(growable: false);

class ObjectiveProgress {
  ObjectiveProgress(this.definition, [this.value = 0]);
  final ObjectiveDefinition definition;
  int value;
  bool get complete => value >= definition.target;
  String get label => switch (definition.kind) {
        ObjectiveKind.score => 'Score',
        ObjectiveKind.collect => 'Collect ${_familyLabel(definition.family!)}',
        ObjectiveKind.destroyBlockers =>
          'Destroy ${definition.blocker!.name.replaceAll('reinforced', 'reinforced ')}s',
        ObjectiveKind.createSpecial =>
          'Create ${_specialLabel(definition.special!)}',
      };
}

String _familyLabel(TileFamily family) => switch (family) {
      TileFamily.cloud => 'blue Cloud tiles',
      TileFamily.leaf => 'green Leaf tiles',
      TileFamily.sun => 'gold Sun tiles',
      TileFamily.moon => 'purple Moon tiles',
      TileFamily.star => 'orange Star tiles',
    };

String _specialLabel(SpecialKind special) => switch (special) {
      SpecialKind.rocket => 'Rocket',
      SpecialKind.prism => 'Prism',
      SpecialKind.cloudBomb => 'Cloud Bomb',
    };

class TurnResult {
  const TurnResult(
      {required this.accepted,
      required this.cleared,
      required this.collectedTiles,
      required this.scoreGained,
      required this.createdSpecials,
      required this.createdPieces,
      required this.destroyedBlockers,
      required this.cascadeCount,
      required this.changedCells});
  final bool accepted;
  final Set<Cell> cleared;
  final Map<TileFamily, int> collectedTiles;
  final int scoreGained;
  final List<SpecialKind> createdSpecials;
  final List<Piece> createdPieces;
  final Map<BlockerKind, int> destroyedBlockers;
  final int cascadeCount;
  final Set<Cell> changedCells;
  static const rejected = TurnResult(
      accepted: false,
      cleared: {},
      collectedTiles: {},
      scoreGained: 0,
      createdSpecials: [],
      createdPieces: [],
      destroyedBlockers: {},
      cascadeCount: 0,
      changedCells: {});
}

class _MatchAnalysis {
  _MatchAnalysis(this.cells, this.horizontalRuns, this.verticalRuns);
  final Set<Cell> cells;
  final List<List<Cell>> horizontalRuns;
  final List<List<Cell>> verticalRuns;
  List<Cell> get intersections => horizontalRuns
      .expand((h) => verticalRuns
          .where((v) => v.any(h.contains))
          .map((v) => h.where(v.contains).first))
      .toSet()
      .toList();
}

/// Deterministic board and rules layer. It has no Flutter or Flame dependencies.
class Match3Board {
  Match3Board(
      {required this.level,
      this.rows = 8,
      this.cols = 8,
      List<List<Piece?>>? initialTiles,
      this.puzzlePerk = PuzzlePerk.none})
      : _random = Random(level.seed) {
    _blockers = {
      for (final blocker in level.blockers)
        blocker.cell: BlockerState(blocker.kind)
    };
    _tiles = initialTiles == null
        ? List.generate(rows, (_) => List<Piece?>.filled(cols, null))
        : initialTiles.map((row) => List<Piece?>.of(row)).toList();
    if (initialTiles != null) {
      for (final cell in _blockers.keys) {
        _tiles[cell.row][cell.col] = null;
      }
    }
    if (initialTiles == null) {
      _fillInitialBoard();
    }
    _applyInitialTileConditions();
    if (initialTiles == null) {
      if (!hasLegalMove) shuffleUntilPlayable();
    }
  }

  final LevelSpec level;
  final int rows;
  final int cols;
  final Random _random;
  final PuzzlePerk puzzlePerk;
  late List<List<Piece?>> _tiles;
  late Map<Cell, BlockerState> _blockers;
  int score = 0;
  int turns = 0;

  void _applyInitialTileConditions() {
    for (final cell in level.stickySyrupCells) {
      final piece = _tiles[cell.row][cell.col];
      if (piece != null) {
        _tiles[cell.row][cell.col] = piece.withConditions(stickySyrup: true);
      }
    }
    for (final cell in level.fogCells) {
      final piece = _tiles[cell.row][cell.col];
      if (piece != null) {
        _tiles[cell.row][cell.col] = piece.withConditions(fogged: true);
      }
    }
    if (puzzlePerk == PuzzlePerk.cloudNineScoreHeadstart) score = 150;
  }

  Piece? at(int row, int col) => _tiles[row][col];
  BlockerState? blockerAt(int row, int col) => _blockers[Cell(row, col)];
  Map<Cell, BlockerState> get blockers =>
      {for (final e in _blockers.entries) e.key: e.value.copy()};
  String get fingerprint =>
      '${_tiles.map((row) => row.map((p) => p == null ? '_' : '${p.family.index}:${p.special?.index ?? ''}:${p.direction?.index ?? ''}:${p.stickySyrup ? 's' : ''}${p.fogged ? 'f' : ''}').join(',')).join('|')}#${_blockers.entries.map((e) => '${e.key.row},${e.key.col}:${e.value.kind.index}:${e.value.hp}').join(';')}';

  void _fillInitialBoard() {
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if (_blockers.containsKey(Cell(row, col))) continue;
        var family =
            TileFamily.values[_random.nextInt(TileFamily.values.length)];
        var retries = 0;
        while (_wouldStartMatch(row, col, family) && retries++ < 30) {
          family = TileFamily.values[_random.nextInt(TileFamily.values.length)];
        }
        _tiles[row][col] = Piece(family);
      }
    }
  }

  bool _wouldStartMatch(int row, int col, TileFamily family) =>
      (col >= 2 &&
          _tiles[row][col - 1]?.family == family &&
          _tiles[row][col - 2]?.family == family) ||
      (row >= 2 &&
          _tiles[row - 1][col]?.family == family &&
          _tiles[row - 2][col]?.family == family);

  Set<Cell> findMatches() => _analyzeMatches().cells;

  _MatchAnalysis _analyzeMatches() {
    final horizontal = <List<Cell>>[];
    final vertical = <List<Cell>>[];
    for (var r = 0; r < rows; r++) {
      var c = 0;
      while (c < cols) {
        final family = _tiles[r][c]?.family;
        var end = c + 1;
        while (
            family != null && end < cols && _tiles[r][end]?.family == family) {
          end++;
        }
        if (family != null && end - c >= 3) {
          horizontal.add([for (var x = c; x < end; x++) Cell(r, x)]);
        }
        c = end;
      }
    }
    for (var c = 0; c < cols; c++) {
      var r = 0;
      while (r < rows) {
        final family = _tiles[r][c]?.family;
        var end = r + 1;
        while (
            family != null && end < rows && _tiles[end][c]?.family == family) {
          end++;
        }
        if (family != null && end - r >= 3) {
          vertical.add([for (var y = r; y < end; y++) Cell(y, c)]);
        }
        r = end;
      }
    }
    return _MatchAnalysis(
        {...horizontal.expand((run) => run), ...vertical.expand((run) => run)},
        horizontal,
        vertical);
  }

  bool get hasLegalMove {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        for (final next in [Cell(r, c + 1), Cell(r + 1, c)]) {
          if (!_inside(next) ||
              at(r, c) == null ||
              at(next.row, next.col) == null ||
              at(r, c)!.stickySyrup ||
              at(next.row, next.col)!.stickySyrup) {
            continue;
          }
          _swap(Cell(r, c), next);
          final legal = findMatches().isNotEmpty ||
              at(r, c)?.special != null ||
              at(next.row, next.col)?.special != null;
          _swap(Cell(r, c), next);
          if (legal) return true;
        }
      }
    }
    return false;
  }

  TurnResult resolveSwap(Cell a, Cell b) {
    if (!_inside(a) ||
        !_inside(b) ||
        (a.row - b.row).abs() + (a.col - b.col).abs() != 1 ||
        at(a.row, a.col) == null ||
        at(b.row, b.col) == null ||
        at(a.row, a.col)!.stickySyrup ||
        at(b.row, b.col)!.stickySyrup) {
      return TurnResult.rejected;
    }
    final scoreBefore = score;
    _swap(a, b);
    var analysis = _analyzeMatches();
    final swappedSpecial = _tiles[a.row][a.col]?.special != null ||
        _tiles[b.row][b.col]?.special != null;
    if (analysis.cells.isEmpty && !swappedSpecial) {
      _swap(a, b);
      return TurnResult.rejected;
    }

    turns++;
    final created = <SpecialKind>[];
    final createdPieces = <Piece>[];
    final destroyed = <BlockerKind, int>{};
    final collected = <TileFamily, int>{};
    final allCleared = <Cell>{};
    final changed = <Cell>{a, b};
    var cascade = 0;
    final aPiece = _tiles[a.row][a.col];
    final bPiece = _tiles[b.row][b.col];
    final swappedPrismTarget = aPiece?.special == SpecialKind.prism
        ? bPiece?.family
        : bPiece?.special == SpecialKind.prism
            ? aPiece?.family
            : null;
    var prismSwapPending = swappedPrismTarget != null;
    var specialSwapPending = swappedSpecial;
    Cell? specialAnchor;

    while (
        analysis.cells.isNotEmpty || prismSwapPending || specialSwapPending) {
      if (cascade++ > 500) break;
      specialAnchor =
          _createMatchSpecial(analysis, a, b, created, createdPieces);
      final normalCells = Set<Cell>.of(analysis.cells);
      if (specialAnchor != null) normalCells.remove(specialAnchor);
      final wave = <Cell>{...normalCells};
      if (specialSwapPending) {
        wave.addAll([a, b]
            .where((cell) => _tiles[cell.row][cell.col]?.special != null));
        specialSwapPending = false;
      }
      if (prismSwapPending) {
        for (var r = 0; r < rows; r++) {
          for (var c = 0; c < cols; c++) {
            if (_tiles[r][c]?.family == swappedPrismTarget) {
              wave.add(Cell(r, c));
            }
          }
        }
        prismSwapPending = false;
      }
      final specialCells = <Cell>{};
      final specialCoverage = <Cell>{};
      final pendingSpecials = <Cell>[
        ...wave.where((cell) => _tiles[cell.row][cell.col]?.special != null)
      ];
      while (pendingSpecials.isNotEmpty) {
        final cell = pendingSpecials.removeLast();
        if (!specialCells.add(cell)) continue;
        final piece = _tiles[cell.row][cell.col];
        if (piece == null) continue;
        final blast =
            _specialBlast(cell, piece, prismTarget: swappedPrismTarget);
        specialCoverage.addAll(blast);
        for (final target in blast) {
          if (wave.add(target) &&
              _tiles[target.row][target.col]?.special != null) {
            pendingSpecials.add(target);
          }
        }
      }
      wave.addAll(specialCells);
      if (wave.isEmpty) break;
      specialCoverage.addAll(specialCells);
      _resolveAdjacentTileConditions(wave, changed);
      _damageBlockers(analysis.cells, specialCoverage, destroyed, changed);
      var clearedTileCount = 0;
      for (final cell in wave) {
        final piece = _tiles[cell.row][cell.col];
        if (piece != null) {
          clearedTileCount++;
          allCleared.add(cell);
          collected[piece.family] = (collected[piece.family] ?? 0) + 1;
          changed.add(cell);
        }
        _tiles[cell.row][cell.col] = null;
      }
      score += clearedTileCount * 10 * cascade;
      _collapseAndRefill();
      analysis = _analyzeMatches();
    }
    if (!hasLegalMove) shuffleUntilPlayable();
    return TurnResult(
        accepted: true,
        cleared: allCleared,
        collectedTiles: collected,
        scoreGained: score - scoreBefore,
        createdSpecials: created,
        createdPieces: createdPieces,
        destroyedBlockers: destroyed,
        cascadeCount: cascade,
        changedCells: changed);
  }

  void _resolveAdjacentTileConditions(
      Set<Cell> clearedCells, Set<Cell> changed) {
    for (final cleared in clearedCells) {
      for (final neighbor in [
        Cell(cleared.row - 1, cleared.col),
        Cell(cleared.row + 1, cleared.col),
        Cell(cleared.row, cleared.col - 1),
        Cell(cleared.row, cleared.col + 1),
      ]) {
        if (!_inside(neighbor)) continue;
        final piece = _tiles[neighbor.row][neighbor.col];
        if (piece == null || (!piece.stickySyrup && !piece.fogged)) continue;
        _tiles[neighbor.row][neighbor.col] = piece.withConditions(
          stickySyrup: false,
          fogged: false,
        );
        changed.add(neighbor);
      }
    }
  }

  Cell? _createMatchSpecial(_MatchAnalysis analysis, Cell a, Cell b,
      List<SpecialKind> created, List<Piece> createdPieces) {
    final intersections = analysis.intersections;
    final lines = <List<Cell>>[
      ...analysis.horizontalRuns,
      ...analysis.verticalRuns
    ];
    SpecialKind? kind;
    RocketDirection? direction;
    Cell? anchor;
    if (intersections.isNotEmpty) {
      kind = SpecialKind.cloudBomb;
      anchor = _preferSwapCell(intersections, a, b) ?? intersections.first;
    } else {
      final longRuns = lines.where((run) => run.length >= 4).toList()
        ..sort((x, y) => y.length.compareTo(x.length));
      if (longRuns.isNotEmpty) {
        final line = longRuns.first;
        if (line.length >= 5) {
          kind = SpecialKind.prism;
        } else {
          kind = SpecialKind.rocket;
          direction = line.first.row == line.last.row
              ? RocketDirection.horizontal
              : RocketDirection.vertical;
        }
        anchor = _preferSwapCell(line, a, b) ?? line[line.length ~/ 2];
      }
    }
    if (kind == null || anchor == null) return null;
    final specialPiece =
        _tiles[anchor.row][anchor.col]!.withSpecial(kind, direction: direction);
    _tiles[anchor.row][anchor.col] = specialPiece;
    created.add(kind);
    createdPieces.add(specialPiece);
    return anchor;
  }

  Cell? _preferSwapCell(List<Cell> cells, Cell a, Cell b) => cells.contains(b)
      ? b
      : cells.contains(a)
          ? a
          : null;

  Set<Cell> _specialBlast(Cell origin, Piece piece,
          {TileFamily? prismTarget}) =>
      switch (piece.special!) {
        SpecialKind.rocket => piece.direction == RocketDirection.vertical
            ? {for (var r = 0; r < rows; r++) Cell(r, origin.col)}
            : {for (var c = 0; c < cols; c++) Cell(origin.row, c)},
        SpecialKind.prism => {
            for (var r = 0; r < rows; r++)
              for (var c = 0; c < cols; c++)
                if (_tiles[r][c]?.family == (prismTarget ?? piece.family))
                  Cell(r, c)
          },
        SpecialKind.cloudBomb => {
            for (var r = _maxInt(0, origin.row - 1);
                r <= _minInt(rows - 1, origin.row + 1);
                r++)
              for (var c = _maxInt(0, origin.col - 1);
                  c <= _minInt(cols - 1, origin.col + 1);
                  c++)
                Cell(r, c)
          },
      };

  void _damageBlockers(Set<Cell> normalMatches, Set<Cell> specialCoverage,
      Map<BlockerKind, int> destroyed, Set<Cell> changed) {
    final remove = <Cell>[];
    for (final entry in _blockers.entries) {
      final cell = entry.key;
      final adjacent = normalMatches.any((match) =>
          (match.row - cell.row).abs() + (match.col - cell.col).abs() == 1);
      if (!adjacent && !specialCoverage.contains(cell)) continue;
      final destroyedNow = entry.value.takeHit();
      changed.add(cell);
      if (destroyedNow) {
        remove.add(cell);
        destroyed[entry.value.kind] = (destroyed[entry.value.kind] ?? 0) + 1;
      }
    }
    for (final cell in remove) {
      _blockers.remove(cell);
    }
  }

  void _collapseAndRefill() {
    for (var c = 0; c < cols; c++) {
      var end = rows - 1;
      while (end >= 0) {
        if (_blockers.containsKey(Cell(end, c)) ||
            (_tiles[end][c]?.stickySyrup ?? false)) {
          end--;
          continue;
        }
        var start = end;
        while (start >= 0 &&
            !_blockers.containsKey(Cell(start, c)) &&
            !(_tiles[start][c]?.stickySyrup ?? false)) {
          start--;
        }
        final top = start + 1;
        final survivors = <Piece>[];
        for (var r = end; r >= top; r--) {
          final piece = _tiles[r][c];
          if (piece != null) survivors.add(piece);
        }
        for (var r = end, i = 0; r >= top; r--, i++) {
          _tiles[r][c] = i < survivors.length
              ? survivors[i]
              : Piece(
                  TileFamily.values[_random.nextInt(TileFamily.values.length)]);
        }
        end = start - 1;
      }
    }
  }

  void shuffleUntilPlayable() {
    final cells = <Cell>[];
    final pieces = <Piece>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (!_blockers.containsKey(Cell(r, c)) &&
            !(_tiles[r][c]?.stickySyrup ?? false)) {
          cells.add(Cell(r, c));
          pieces.add(_tiles[r][c]!);
        }
      }
    }
    for (var attempt = 0; attempt < 500; attempt++) {
      pieces.shuffle(_random);
      for (var i = 0; i < cells.length; i++) {
        final cell = cells[i];
        _tiles[cell.row][cell.col] = pieces[i];
      }
      if (findMatches().isEmpty && hasLegalMove) return;
    }
    for (var row = 0; row < rows - 1; row++) {
      for (var col = 0; col < cols - 2; col++) {
        final patternCells = [
          Cell(row, col),
          Cell(row, col + 1),
          Cell(row, col + 2),
          Cell(row + 1, col + 1)
        ];
        if (patternCells.any((cell) =>
            _blockers.containsKey(cell) ||
            (_tiles[cell.row][cell.col]?.stickySyrup ?? false))) {
          continue;
        }
        for (var r = 0; r < rows; r++) {
          for (var c = 0; c < cols; c++) {
            if (!_blockers.containsKey(Cell(r, c)) &&
                !(_tiles[r][c]?.stickySyrup ?? false)) {
              _tiles[r][c] =
                  Piece(TileFamily.values[(r + c) % TileFamily.values.length]);
            }
          }
        }
        for (final family in TileFamily.values) {
          for (final centerFamily
              in TileFamily.values.where((candidate) => candidate != family)) {
            _tiles[row][col] = Piece(family);
            _tiles[row][col + 1] = Piece(centerFamily);
            _tiles[row][col + 2] = Piece(family);
            _tiles[row + 1][col + 1] = Piece(family);
            if (findMatches().isEmpty && hasLegalMove) return;
          }
        }
      }
    }
  }

  bool _inside(Cell cell) =>
      cell.row >= 0 && cell.row < rows && cell.col >= 0 && cell.col < cols;
  void _swap(Cell a, Cell b) {
    final value = _tiles[a.row][a.col];
    _tiles[a.row][a.col] = _tiles[b.row][b.col];
    _tiles[b.row][b.col] = value;
  }
}

class LevelSession {
  LevelSession(this.level,
      {List<List<Piece?>>? initialTiles,
      PuzzlePerk puzzlePerk = PuzzlePerk.none})
      : board = Match3Board(
            level: level, initialTiles: initialTiles, puzzlePerk: puzzlePerk),
        objectives =
            level.objectives.map((o) => ObjectiveProgress(o)).toList() {
    for (final progress in objectives) {
      if (progress.definition.kind == ObjectiveKind.score) {
        progress.value = _minInt(progress.definition.target, board.score);
      }
    }
  }
  final LevelSpec level;
  final Match3Board board;
  final List<ObjectiveProgress> objectives;
  int movesUsed = 0;
  LevelOutcome outcome = LevelOutcome.playing;
  int get movesRemaining => level.moves - movesUsed;
  bool get allObjectivesComplete =>
      objectives.every((objective) => objective.complete);

  TurnResult swap(Cell a, Cell b) {
    if (outcome != LevelOutcome.playing) return TurnResult.rejected;
    final result = board.resolveSwap(a, b);
    if (!result.accepted) return result;
    movesUsed++;
    for (final progress in objectives) {
      final definition = progress.definition;
      if (definition.kind == ObjectiveKind.score) {
        progress.value = _minInt(definition.target, board.score);
        continue;
      }
      final increment = switch (definition.kind) {
        ObjectiveKind.score => 0,
        ObjectiveKind.collect => result.collectedTiles[definition.family] ?? 0,
        ObjectiveKind.destroyBlockers =>
          result.destroyedBlockers[definition.blocker] ?? 0,
        ObjectiveKind.createSpecial => result.createdSpecials
            .where((special) => special == definition.special)
            .length,
      };
      progress.value = _minInt(definition.target, progress.value + increment);
    }
    if (allObjectivesComplete) {
      outcome = LevelOutcome.won;
    } else if (movesUsed >= level.moves) {
      outcome = LevelOutcome.lost;
    }
    return result;
  }
}

class RewardResult {
  const RewardResult(
      {required this.firstClear,
      required this.coins,
      required this.stars,
      required this.bestScore,
      this.collectionXp = 0,
      this.keys = 0});
  final bool firstClear;
  final int coins;
  final int stars;
  final int bestScore;
  final int collectionXp;
  final int keys;
}

class ProgressState {
  ProgressState();

  static const evolutionThresholds = <int>[10, 25, 50];
  static const maxPlayableLevel = 30;
  static const milestoneCardUnlocks = <int, String>{
    5: 'bluebeary_pancakes',
    10: 'cloud_nine',
    15: 'soldier_field_haze',
    20: 'cortezs_curse',
    25: 'baked_alien',
    30: 'basement_legend',
  };

  final Set<int> completedLevels = {};
  final Map<int, int> bestScores = {};
  final Set<int> starLevelIds = {};
  int coins = 0;
  int keys = 0;
  int collectionXp = 0;
  String? loungeStyleId;
  bool loungeRestoredFlag = false;
  final Set<String> discoveredCollectibleIds = {};
  final Set<String> unlockedCollectibleIds = {};
  final Set<String> favoriteCollectibleIds = {};
  final Map<String, EvolutionStage> collectibleEvolutionStages = {};
  final Map<String, int> collectibleXp = {};
  String? equippedCollectibleId;
  String? displayedCollectibleId;
  final Set<String> storyFlags = {};
  final Set<String> completedChapterIds = {};
  final Map<String, WorldNodeState> worldNodeStates = {};
  final Map<String, bool> settings = {
    'reducedMotion': false,
    'haptics': true,
    'sound': true,
    'music': true,
  };
  bool get loungeRestored => loungeRestoredFlag || loungeStyleId != null;
  bool get loungeRestorationUnlocked => completedLevels.contains(10);
  int get unlockedThrough {
    final latest = completedLevels.isEmpty
        ? 0
        : completedLevels.reduce((a, b) => a > b ? a : b);
    final next = latest + 1;
    return next > maxPlayableLevel ? maxPlayableLevel : next;
  }

  /// Story beats can occur after the final playable level without exposing
  /// their dialogue before that level has actually been completed.
  bool isStoryBeatAvailable(int unlockAtLevel) {
    if (unlockedThrough >= unlockAtLevel) return true;
    return unlockAtLevel == maxPlayableLevel + 1 &&
        completedLevels.contains(maxPlayableLevel);
  }

  void resetForNewGame() {
    completedLevels.clear();
    bestScores.clear();
    starLevelIds.clear();
    coins = 0;
    keys = 0;
    collectionXp = 0;
    loungeStyleId = null;
    loungeRestoredFlag = false;
    discoveredCollectibleIds.clear();
    unlockedCollectibleIds.clear();
    favoriteCollectibleIds.clear();
    collectibleEvolutionStages.clear();
    collectibleXp.clear();
    equippedCollectibleId = null;
    displayedCollectibleId = null;
    storyFlags.clear();
    completedChapterIds.clear();
    worldNodeStates.clear();
    settings
      ..clear()
      ..addAll({
        'reducedMotion': false,
        'haptics': true,
        'sound': true,
        'music': true,
      });
  }

  void unlockCollectible(String id) {
    discoveredCollectibleIds.add(id);
    unlockedCollectibleIds.add(id);
    collectibleEvolutionStages.putIfAbsent(id, () => EvolutionStage.seedling);
    collectibleXp.putIfAbsent(id, () => 0);
  }

  static EvolutionStage evolutionStageForXp(int xp) {
    if (xp >= evolutionThresholds[2]) return EvolutionStage.legendary;
    if (xp >= evolutionThresholds[1]) return EvolutionStage.frosted;
    if (xp >= evolutionThresholds[0]) return EvolutionStage.bud;
    return EvolutionStage.seedling;
  }

  static int? nextEvolutionThreshold(EvolutionStage stage) => switch (stage) {
        EvolutionStage.seedling => evolutionThresholds[0],
        EvolutionStage.bud => evolutionThresholds[1],
        EvolutionStage.frosted => evolutionThresholds[2],
        EvolutionStage.legendary => null,
      };

  void awardCollectionXp(int amount) {
    if (amount <= 0) return;
    collectionXp += amount;
    final recipient = equippedCollectibleId ??
        (unlockedCollectibleIds.toList()..sort()).firstOrNull;
    if (recipient == null) return;
    final cardXp = (collectibleXp[recipient] ?? 0) + amount;
    collectibleXp[recipient] = cardXp;
    collectibleEvolutionStages[recipient] = evolutionStageForXp(cardXp);
  }

  bool equipCollectible(String? id) {
    if (id != null && !unlockedCollectibleIds.contains(id)) return false;
    equippedCollectibleId = id;
    return true;
  }

  void toggleFavorite(String id) {
    if (!unlockedCollectibleIds.contains(id)) return;
    if (!favoriteCollectibleIds.add(id)) favoriteCollectibleIds.remove(id);
  }

  void displayCollectible(String? id) {
    if (id == null || unlockedCollectibleIds.contains(id)) {
      displayedCollectibleId = id;
    }
  }

  WorldNodeState stateForWorldNode(WorldNodeDefinition node) {
    if (node.customizedWhen == 'lounge_style_selected' &&
        loungeStyleId != null) {
      return WorldNodeState.customized;
    }
    if (node.restoredWhen == 'lounge_restored' && loungeRestored) {
      return WorldNodeState.restored;
    }
    if (node.previewAtLevel != null &&
        completedLevels.contains(node.previewAtLevel)) {
      return WorldNodeState.preview;
    }
    final saved = worldNodeStates[node.id];
    if (saved != null && saved != WorldNodeState.locked) return saved;
    if (node.unlockAtLevel != null &&
        completedLevels.contains(node.unlockAtLevel)) {
      return WorldNodeState.available;
    }
    return saved ?? node.defaultState;
  }

  void setWorldNodeState(String id, WorldNodeState state) {
    worldNodeStates[id] = state;
  }

  RewardResult grantFirstClear(LevelSpec level, int score) {
    final best = recordBestScore(level, score);
    final first = completedLevels.add(level.id);
    if (first) {
      coins += level.coins;
      starLevelIds.add(level.id);
      keys += level.keys;
      final unlockId = milestoneCardUnlocks[level.id];
      if (unlockId != null) unlockCollectible(unlockId);
      awardCollectionXp(level.collectionXp);
      if (level.id == 20) {
        setWorldNodeState('kitchen', WorldNodeState.available);
        storyFlags.add('kitchen_opened');
      } else if (level.id == 30) {
        setWorldNodeState('higher_art_gallery', WorldNodeState.preview);
        storyFlags
          ..add('gallery_preview_seen')
          ..add('collection_case_clue');
      }
    }
    return RewardResult(
        firstClear: first,
        coins: first ? level.coins : 0,
        stars: first ? 1 : 0,
        bestScore: best,
        collectionXp: first ? level.collectionXp : 0,
        keys: first ? level.keys : 0);
  }

  int recordBestScore(LevelSpec level, int score) {
    final previousBest = bestScores[level.id] ?? 0;
    final best = previousBest > score ? previousBest : score;
    bestScores[level.id] = best;
    return best;
  }

  Map<String, dynamic> toJson() => {
        'schema': 3,
        'completed': completedLevels.toList()..sort(),
        'best': {for (final e in bestScores.entries) '${e.key}': e.value},
        'coins': coins,
        'keys': keys,
        'collectionXp': collectionXp,
        'collectibleXp': Map<String, int>.of(collectibleXp),
        'equippedCollectibleId': equippedCollectibleId,
        'stars': starLevelIds.toList()..sort(),
        'loungeStyleId': loungeStyleId,
        'loungeRestored': loungeRestored,
        'discoveredCollectibles': discoveredCollectibleIds.toList()..sort(),
        'unlockedCollectibles': unlockedCollectibleIds.toList()..sort(),
        'favoriteCollectibles': favoriteCollectibleIds.toList()..sort(),
        'collectibleEvolution': {
          for (final entry in collectibleEvolutionStages.entries)
            entry.key: entry.value.name,
        },
        'displayedCollectibleId': displayedCollectibleId,
        'storyFlags': storyFlags.toList()..sort(),
        'completedChapters': completedChapterIds.toList()..sort(),
        'worldNodeStates': {
          for (final entry in worldNodeStates.entries)
            entry.key: entry.value.name,
        },
        'settings': Map<String, bool>.of(settings),
      };

  factory ProgressState.fromJson(Map<String, dynamic> json) {
    final state = ProgressState();
    state.completedLevels
        .addAll((json['completed'] as List? ?? []).cast<int>());
    state.starLevelIds.addAll((json['stars'] as List? ?? []).cast<int>());
    state.bestScores.addAll((json['best'] as Map? ?? {}).map(
        (key, value) => MapEntry(int.parse(key.toString()), value as int)));
    state.coins = json['coins'] as int? ?? 0;
    state.keys = json['keys'] as int? ?? 0;
    state.collectionXp = json['collectionXp'] as int? ?? 0;
    state.loungeStyleId = json['loungeStyleId'] as String?;
    state.loungeRestoredFlag =
        (json['loungeRestored'] as bool?) ?? (state.loungeStyleId != null);
    for (final entry in milestoneCardUnlocks.entries) {
      if (state.completedLevels.contains(entry.key)) {
        state.unlockCollectible(entry.value);
      }
    }
    state.discoveredCollectibleIds.addAll(
        (json['discoveredCollectibles'] as List? ?? const []).cast<String>());
    state.unlockedCollectibleIds.addAll(
        (json['unlockedCollectibles'] as List? ?? const []).cast<String>());
    state.favoriteCollectibleIds.addAll(
        (json['favoriteCollectibles'] as List? ?? const []).cast<String>());
    state.collectibleEvolutionStages.addAll(
        (json['collectibleEvolution'] as Map? ?? const {}).map((key, value) =>
            MapEntry(key.toString(),
                EvolutionStage.values.byName(value.toString()))));
    state.collectibleXp.addAll((json['collectibleXp'] as Map? ?? const {})
        .map((key, value) => MapEntry(key.toString(), value as int)));
    for (final entry in state.collectibleXp.entries) {
      if (state.unlockedCollectibleIds.contains(entry.key)) {
        state.collectibleEvolutionStages[entry.key] =
            evolutionStageForXp(entry.value);
      }
    }
    final equippedId = json['equippedCollectibleId'] as String?;
    if (equippedId != null &&
        state.unlockedCollectibleIds.contains(equippedId)) {
      state.equippedCollectibleId = equippedId;
    }
    state.displayedCollectibleId = json['displayedCollectibleId'] as String?;
    state.storyFlags
        .addAll((json['storyFlags'] as List? ?? const []).cast<String>());
    state.completedChapterIds.addAll(
        (json['completedChapters'] as List? ?? const []).cast<String>());
    state.worldNodeStates.addAll((json['worldNodeStates'] as Map? ?? const {})
        .map((key, value) => MapEntry(
            key.toString(), WorldNodeState.values.byName(value.toString()))));
    final storedSettings = json['settings'] as Map?;
    if (storedSettings != null) {
      for (final key in state.settings.keys) {
        final value = storedSettings[key];
        if (value is bool) state.settings[key] = value;
      }
    }
    return state;
  }
}

int _minInt(int a, int b) => a < b ? a : b;
int _maxInt(int a, int b) => a > b ? a : b;
