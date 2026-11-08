import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/match3.dart';

const _match3Art = 'assets/art/match3/';
const _brandArt = 'assets/art/brand/';

class Match3ObjectivePanel extends StatelessWidget {
  const Match3ObjectivePanel({
    super.key,
    required this.objectives,
    this.labelForObjective,
  });

  final List<ObjectiveProgress> objectives;
  final String Function(ObjectiveProgress objective)? labelForObjective;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('issue4-objectives-panel'),
      container: true,
      child: DecoratedBox(
        key: const ValueKey('issue4-objectives-adaptive-backing'),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff542087), Color(0xff321052)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffffcf59), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x770c0619),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'OBJECTIVES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              for (final objective in objectives)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Image.asset(
                          objective.complete
                              ? '${_match3Art}objective_state_complete.png'
                              : '${_match3Art}objective_state_in_progress.png',
                          width: 26,
                          height: 26,
                          cacheWidth: 64,
                          excludeFromSemantics: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          labelForObjective?.call(objective) ?? objective.label,
                          softWrap: true,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${objective.value}/${objective.definition.target}',
                          softWrap: true,
                          textAlign: TextAlign.end,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Match3MovesCounter extends StatelessWidget {
  const Match3MovesCounter({super.key, required this.movesRemaining});

  final int movesRemaining;

  String get _asset => movesRemaining <= 0
      ? '${_match3Art}moves_counter_backing_zero.png'
      : movesRemaining <= 3
          ? '${_match3Art}moves_counter_backing_low.png'
          : '${_match3Art}moves_counter_backing_normal.png';

  @override
  Widget build(BuildContext context) => Semantics(
        key: const ValueKey('issue4-moves-counter'),
        label: '$movesRemaining moves remaining',
        child: ExcludeSemantics(
          child: SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _asset,
                  key: ValueKey(_asset),
                  fit: BoxFit.contain,
                  cacheWidth: 128,
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$movesRemaining',
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        shadows: const [
                          Shadow(color: Colors.black87, blurRadius: 3)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class Match3ScoreProgress extends StatelessWidget {
  const Match3ScoreProgress({
    super.key,
    required this.score,
    required this.scoreTarget,
    required this.clearAvailable,
  });

  final int score;
  final int scoreTarget;
  final bool clearAvailable;

  double get _progress =>
      scoreTarget <= 0 ? 0 : (score / scoreTarget).clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          '${_match3Art}score_bar_backing.png',
                          fit: BoxFit.fill,
                          cacheWidth: 640,
                          excludeFromSemantics: true,
                        ),
                        Center(
                          child: Text(
                            'Score $score',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 3)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      clearAvailable
                          ? '${_match3Art}star_filled.png'
                          : '${_match3Art}star_empty.png',
                      width: 28,
                      height: 28,
                      cacheWidth: 64,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            if (scoreTarget > 0) ...[
              const SizedBox(height: 3),
              Semantics(
                label: 'Score progress $score of $scoreTarget',
                child: ExcludeSemantics(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SizedBox(
                      height: 20,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            '${_match3Art}star_progress_track_empty.png',
                            fit: BoxFit.fill,
                            cacheWidth: 640,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: constraints.maxWidth * _progress,
                              height: 20,
                              child: ClipRect(
                                child: Image.asset(
                                  '${_match3Art}star_progress_fill_full.png',
                                  fit: BoxFit.fill,
                                  cacheWidth: 640,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

class Match3SpecialsGuide extends StatefulWidget {
  const Match3SpecialsGuide({super.key, required this.session});

  final LevelSession session;

  @override
  State<Match3SpecialsGuide> createState() => _Match3SpecialsGuideState();
}

class _Match3SpecialsGuideState extends State<Match3SpecialsGuide> {
  String? _selectedKey;
  String? _pressedKey;

  bool _isOnBoard(SpecialKind special) {
    for (var row = 0; row < widget.session.board.rows; row++) {
      for (var col = 0; col < widget.session.board.cols; col++) {
        if (widget.session.board.at(row, col)?.special == special) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    const entries = <(String, SpecialKind, String, String)>[
      (
        'torch',
        SpecialKind.rocket,
        'butane_torch_lighter.png',
        'Created by a straight match of four. Swap it to clear its row or column.'
      ),
      (
        'prism',
        SpecialKind.prism,
        'prism.png',
        'Created by a straight match of five. Swap it to clear tiles of one family.'
      ),
      (
        'cloud-bomb',
        SpecialKind.cloudBomb,
        'cloud_bomb.png',
        'Created by a T or L match. Swap it to clear a 3×3 area.'
      ),
    ];

    return ExpansionTile(
      key: const ValueKey('issue4-specials-guide'),
      tilePadding: const EdgeInsets.symmetric(horizontal: 14),
      title: const Text('Specials guide'),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      children: [
        const Text(
          'Specials are created and activated by matching; these guide buttons do not change the board.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final entry in entries)
              Expanded(
                child: _specialButton(
                  context,
                  keyName: entry.$1,
                  special: entry.$2,
                  image: entry.$3,
                  label: switch (entry.$2) {
                    SpecialKind.rocket => 'Torch',
                    SpecialKind.prism => 'Prism',
                    SpecialKind.cloudBomb => 'Cloud Bomb',
                  },
                  description: entry.$4,
                ),
              ),
          ],
        ),
        if (_selectedKey != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              entries.singleWhere((entry) => entry.$1 == _selectedKey).$4,
              key: const ValueKey('issue4-special-description'),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Semantics(
              image: true,
              label:
                  'Logo-free Cloud Cup vaporizer artwork with the official Cloud Cup logo overlaid separately',
              child: ExcludeSemantics(
                child: SizedBox(
                  width: 74,
                  height: 64,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        '${_match3Art}cloud_cup_vaporizer.png',
                        key: const ValueKey('issue4-vaporizer-art'),
                        fit: BoxFit.contain,
                        cacheWidth: 160,
                      ),
                      Positioned(
                        left: 11,
                        right: 11,
                        bottom: 12,
                        height: 13,
                        child: Image.asset(
                          '${_brandArt}cloud_cup_logo.png',
                          key: const ValueKey('issue4-cloud-cup-logo-overlay'),
                          fit: BoxFit.contain,
                          cacheWidth: 384,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Cloud Cup vaporizer with the canonical logo as a separate overlay.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _specialButton(
    BuildContext context, {
    required String keyName,
    required SpecialKind special,
    required String image,
    required String label,
    required String description,
  }) {
    final enabled = _isOnBoard(special);
    final selected = enabled && _selectedKey == keyName;
    final art = _pressedKey == keyName
        ? 'booster_button_pressed.png'
        : !enabled
            ? 'booster_button_disabled.png'
            : selected
                ? 'booster_button_selected.png'
                : 'booster_button_normal.png';

    return Tooltip(
      message: description,
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: selected,
        label: '$label special',
        hint: enabled
            ? 'Show how this special works.'
            : 'This special is not currently on the board.',
        onTap: enabled ? () => _select(keyName) : null,
        child: GestureDetector(
          key: ValueKey('issue4-special-$keyName'),
          behavior: HitTestBehavior.opaque,
          onTapDown:
              enabled ? (_) => setState(() => _pressedKey = keyName) : null,
          onTapCancel:
              enabled ? () => setState(() => _pressedKey = null) : null,
          onTapUp: enabled ? (_) => setState(() => _pressedKey = null) : null,
          onTap: enabled ? () => _select(keyName) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                SizedBox(
                  width: 62,
                  height: 62,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('$_match3Art$art', cacheWidth: 128),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          '$_match3Art$image',
                          fit: BoxFit.contain,
                          cacheWidth: 96,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(label, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _select(String keyName) {
    setState(() {
      _pressedKey = null;
      _selectedKey = _selectedKey == keyName ? null : keyName;
    });
  }
}

class Match3PrimaryArtButton extends StatelessWidget {
  const Match3PrimaryArtButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 320,
  });

  final String label;
  final VoidCallback onPressed;
  final double width;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: SizedBox(
          width: math.min(width, MediaQuery.sizeOf(context).width - 32),
          height: 64,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                '${_match3Art}button_frame_primary_blank.png',
                fit: BoxFit.fill,
                cacheWidth: 640,
                excludeFromSemantics: true,
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  key: ValueKey('issue4-action-$label'),
                  borderRadius: BorderRadius.circular(18),
                  onTap: onPressed,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 3)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

double match3PanelWidth(double availableWidth) =>
    math.min(480, math.max(0, availableWidth));
