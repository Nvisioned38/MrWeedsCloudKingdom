import 'package:flutter/material.dart';

import '../domain/match3.dart';
import '../domain/phase2_models.dart';
import 'art_registry.dart';
import 'art_widgets.dart';

/// Read-only visual inspection surface present only in the isolated QA build.
class Issue26CharacterPreviewScreen extends StatelessWidget {
  const Issue26CharacterPreviewScreen({
    super.key,
    required this.characters,
    required this.story,
  });

  final CharacterCatalog characters;
  final StoryCatalog story;

  @override
  Widget build(BuildContext context) {
    final featured = characters.characters.where(
      (character) => character.id == 'riff' || character.id == 'mona_chromatic',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Character Art QA Preview')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Read-only preview. These story fixtures use temporary in-memory progress and never update the game save.',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openStoryFixture(context, completedThrough: 14),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Chapter 2 before Riff — Level 15 preview'),
            ),
            OutlinedButton.icon(
              onPressed: () => _openStoryFixture(context, completedThrough: 15),
              icon: const Icon(Icons.science_outlined),
              label: const Text('Riff story fixture — Level 16 unlocked'),
            ),
            OutlinedButton.icon(
              onPressed: () => _openStoryFixture(context, completedThrough: 24),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Chapter 3 before Mona — Level 25 preview'),
            ),
            OutlinedButton.icon(
              onPressed: () => _openStoryFixture(context, completedThrough: 25),
              icon: const Icon(Icons.science_outlined),
              label: const Text('Mona story fixture — Level 26 unlocked'),
            ),
            for (final character in featured) ...[
              const SizedBox(height: 20),
              Text(character.displayName,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      ArtRegistry.pathFor(character.fullBodyAssetKey)!,
                      height: 280,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person_off),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          ArtRegistry.pathFor(character.roundUiAssetKey!)!,
                          height: 96,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Image.asset(
                          ArtRegistry.pathFor(character.squareUiAssetKey!)!,
                          height: 96,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text('Dialogue expressions',
                  style: Theme.of(context).textTheme.titleMedium),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                children: character.expressionAssetKeys.entries.map((entry) {
                  final path = ArtRegistry.pathFor(entry.value)!;
                  return Column(
                    children: [
                      Expanded(child: Image.asset(path, fit: BoxFit.contain)),
                      Text(entry.key, maxLines: 1),
                    ],
                  );
                }).toList(growable: false),
              ),
              _StoryPortraitCheck(character: character, story: story),
            ],
          ],
        ),
      ),
    );
  }

  void _openStoryFixture(
    BuildContext context, {
    required int completedThrough,
  }) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => _Issue26StoryFixturePage(
          catalog: story,
          characters: characters,
          completedThrough: completedThrough,
        ),
      ),
    );
  }
}

class _Issue26StoryFixturePage extends StatefulWidget {
  const _Issue26StoryFixturePage({
    required this.catalog,
    required this.characters,
    required this.completedThrough,
  });

  final StoryCatalog catalog;
  final CharacterCatalog characters;
  final int completedThrough;

  @override
  State<_Issue26StoryFixturePage> createState() =>
      _Issue26StoryFixturePageState();
}

class _Issue26StoryFixturePageState extends State<_Issue26StoryFixturePage> {
  late final ProgressState _fixtureProgress = ProgressState()
    ..completedLevels.addAll(
      List<int>.generate(widget.completedThrough, (index) => index + 1),
    );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Story Fixture · Level ${widget.completedThrough + 1}'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xffffe8a8),
                child: Text(
                  'TEMPORARY QA FIXTURE — progress seeded through Level ${widget.completedThrough}. Any flags created here stay in memory and are discarded when this screen closes.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xff322743),
                      ),
                ),
              ),
              Expanded(
                child: StoryScreen(
                  catalog: widget.catalog,
                  characters: widget.characters,
                  progress: _fixtureProgress,
                  persist: () async {},
                ),
              ),
            ],
          ),
        ),
      );
}

class _StoryPortraitCheck extends StatelessWidget {
  const _StoryPortraitCheck({required this.character, required this.story});

  final CharacterRef character;
  final StoryCatalog story;

  @override
  Widget build(BuildContext context) {
    final lines = story.chapters
        .expand((chapter) => chapter.beats)
        .expand((beat) => beat.lines)
        .where((line) => line.speakerId == character.id);
    if (lines.isEmpty) return const SizedBox.shrink();
    final line = lines.first;
    final expression = line.expressionKey == null
        ? character.portraitAssetKey
        : character.expressionAssetKeys[line.expressionKey] ??
            character.portraitAssetKey;
    return Card(
      child: ListTile(
        leading: DialogueCharacterPortrait(
          character: character,
          assetKey: expression,
          size: 76,
        ),
        title: Text('${character.displayName} — story portrait'),
        subtitle: Text(line.text),
      ),
    );
  }
}

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({
    super.key,
    required this.catalog,
    required this.progress,
    required this.persist,
  });

  final CollectionCatalog catalog;
  final ProgressState progress;
  final Future<void> Function() persist;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  CollectibleRarity? _rarity;
  String? _collectionId;

  List<CollectibleCard> get _visibleCards {
    final cards = widget.catalog.query(
      rarity: _rarity,
      collectionId: _collectionId,
      sortByName: true,
    );
    return cards
        .map(
          (card) => card.withProgress(
            stage: widget.progress.collectibleEvolutionStages[card.id],
            discovered: widget.progress.discoveredCollectibleIds.contains(
              card.id,
            ),
            unlocked: widget.progress.unlockedCollectibleIds.contains(card.id),
            favorite: widget.progress.favoriteCollectibleIds.contains(card.id),
            evolutionXp: widget.progress.collectibleXp[card.id] ?? 0,
            equipped: widget.progress.equippedCollectibleId == card.id,
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _rarity?.name ?? 'all',
                    decoration: const InputDecoration(
                      labelText: 'Rarity',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('All rarities'),
                      ),
                      ...CollectibleRarity.values.map(
                        (rarity) => DropdownMenuItem(
                          value: rarity.name,
                          child: Text(rarity.label),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(
                      () => _rarity = value == 'all'
                          ? null
                          : CollectibleRarity.values.byName(value!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _collectionId ?? 'all',
                    decoration: const InputDecoration(
                      labelText: 'Collection',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: 'all', child: Text('All sets')),
                      ...widget.catalog.collectionIds.map(
                        (id) => DropdownMenuItem(
                          value: id,
                          child: Text(
                            widget.catalog.cards
                                .firstWhere((card) => card.collectionId == id)
                                .collectionName,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(
                      () => _collectionId = value == 'all' ? null : value,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.progress.unlockedCollectibleIds.length} of ${widget.catalog.cards.length} discovered · ${widget.progress.collectionXp} Collection XP · sorted by name',
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .68,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _visibleCards.length,
              itemBuilder: (context, index) {
                final card = _visibleCards[index];
                return CollectibleCardView(
                  card: card,
                  onTap: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CollectibleDetailScreen(
                          card: card,
                          progress: widget.progress,
                          persist: widget.persist,
                        ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      );
}

class CollectibleDetailScreen extends StatefulWidget {
  const CollectibleDetailScreen({
    super.key,
    required this.card,
    required this.progress,
    required this.persist,
  });

  final CollectibleCard card;
  final ProgressState progress;
  final Future<void> Function() persist;

  @override
  State<CollectibleDetailScreen> createState() =>
      _CollectibleDetailScreenState();
}

class _CollectibleDetailScreenState extends State<CollectibleDetailScreen> {
  CollectibleCard get _card => widget.card.withProgress(
        stage: widget.progress.collectibleEvolutionStages[widget.card.id],
        discovered: widget.progress.discoveredCollectibleIds.contains(
          widget.card.id,
        ),
        unlocked:
            widget.progress.unlockedCollectibleIds.contains(widget.card.id),
        favorite:
            widget.progress.favoriteCollectibleIds.contains(widget.card.id),
        evolutionXp: widget.progress.collectibleXp[widget.card.id] ?? 0,
        equipped: widget.progress.equippedCollectibleId == widget.card.id,
      );

  Future<void> _toggleFavorite() async {
    widget.progress.toggleFavorite(widget.card.id);
    await widget.persist();
    if (mounted) setState(() {});
  }

  Future<void> _displayOnShelf() async {
    widget.progress.displayCollectible(widget.card.id);
    await widget.persist();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Displayed on the Collection Shelf.')),
      );
      setState(() {});
    }
  }

  Future<void> _equipCard() async {
    if (!widget.progress.equipCollectible(widget.card.id)) return;
    await widget.persist();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;
    return Scaffold(
      appBar: AppBar(
        title: Text(card.unlocked ? card.displayName : 'Undiscovered card'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AspectRatio(
            aspectRatio: .92,
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: rarityColor(card.rarity), width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ArtAssetSlot(
                assetKey: card.artAssetKey,
                height: 420,
                icon: card.unlocked ? Icons.spa : Icons.lock_outline,
                borderRadius: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            card.unlocked ? card.displayName : 'Undiscovered',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            '${card.rarity.label} · ${card.collectionName} · ${card.category} · ${card.strainClass}',
          ),
          const SizedBox(height: 10),
          Text(
            card.unlocked
                ? card.lore
                : 'Complete Kingdom milestones to discover this card.',
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.auto_awesome),
            title: Text('Evolution · ${card.evolutionStage.label}'),
            subtitle: Text(
              '${card.evolutionXp} card XP${ProgressState.nextEvolutionThreshold(card.evolutionStage) == null ? ' · Evolution complete' : ' · ${ProgressState.nextEvolutionThreshold(card.evolutionStage)! - card.evolutionXp} XP to next stage'}',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              card.equipped ? Icons.check_circle : Icons.auto_awesome,
            ),
            title: Text(
              card.id == 'cloud_nine' && card.equipped
                  ? 'Active puzzle perk'
                  : 'Card ability',
            ),
            subtitle: Text(
              card.id == 'cloud_nine'
                  ? card.equipped
                      ? 'Start each level with +150 score. This is the active Phase 2B perk.'
                      : 'Equip this card to start each level with +150 score.'
                  : '${card.puzzleAbilityText} Other card abilities are catalog previews in this phase.',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: card.unlocked ? _toggleFavorite : null,
                icon: Icon(
                  card.favorite ? Icons.favorite : Icons.favorite_border,
                ),
                label: Text(card.favorite ? 'Unfavorite' : 'Favorite'),
              ),
              FilledButton.icon(
                onPressed: card.unlocked && !card.equipped ? _equipCard : null,
                icon: Icon(card.equipped ? Icons.check : Icons.bolt),
                label: Text(card.equipped ? 'Equipped' : 'Equip'),
              ),
              FilledButton.icon(
                onPressed: card.unlocked ? _displayOnShelf : null,
                icon: const Icon(Icons.shelves),
                label: const Text('Display on Shelf'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StoryScreen extends StatelessWidget {
  const StoryScreen({
    super.key,
    required this.catalog,
    required this.characters,
    required this.progress,
    required this.persist,
  });

  final StoryCatalog catalog;
  final CharacterCatalog characters;
  final ProgressState progress;
  final Future<void> Function() persist;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'STORY CHAPTERS',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(letterSpacing: 1.4),
          ),
          const SizedBox(height: 8),
          ...catalog.chapters.map((chapter) {
            final complete = progress.completedChapterIds.contains(chapter.id);
            final enabled = chapter.playable &&
                progress.unlockedThrough >= chapter.unlockAtLevel;
            final storyGate = progress.isStoryBeatAvailable;
            final availableBeats = chapter.beats
                .where((beat) => storyGate(beat.unlockAtLevel))
                .toList(growable: false);
            final canComplete = chapter.completeAtLevel == null ||
                progress.completedLevels.contains(chapter.completeAtLevel);
            return Card(
              child: ListTile(
                leading: Icon(
                  enabled ? Icons.menu_book : Icons.lock_outline,
                  color: complete ? const Color(0xffffd36e) : null,
                ),
                title: Text(chapter.title),
                subtitle: Text(
                  enabled
                      ? '${chapter.synopsis}\n${availableBeats.length} of ${chapter.beats.length} story beats available'
                      : '${chapter.synopsis}\nUnlocks at Level ${chapter.unlockAtLevel}',
                ),
                trailing: complete ? const Icon(Icons.check_circle) : null,
                enabled: enabled,
                onTap: enabled
                    ? () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChapterDialogPage(
                              chapter: chapter,
                              beats: availableBeats,
                              characters: characters,
                              canComplete: canComplete,
                              onComplete: () async {
                                progress.storyFlags.addAll(
                                  availableBeats.map(
                                    (beat) => 'story_${beat.id}_seen',
                                  ),
                                );
                                progress.storyFlags.addAll(
                                  characterKnownFlagsForBeats(availableBeats),
                                );
                                if (canComplete) {
                                  progress.completedChapterIds.add(chapter.id);
                                  progress.storyFlags
                                      .add(chapter.completionFlag);
                                }
                                await persist();
                              },
                            ),
                          ),
                        )
                    : null,
              ),
            );
          }),
          const SizedBox(height: 20),
          Text(
            'CHARACTER CATALOG',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(letterSpacing: 1.4),
          ),
          const SizedBox(height: 8),
          ...characters.characters.map((character) {
            final known = character.knownByDefault ||
                progress.storyFlags.contains('character_${character.id}_known');
            return Card(
              child: ListTile(
                leading: CharacterPortrait(
                  character: character,
                  size: 48,
                  showArtwork: known,
                ),
                title: Text(known ? character.displayName : '???'),
                subtitle: Text(
                  known ? character.role : 'A future Kingdom character',
                ),
                trailing: Icon(
                  known ? Icons.check_circle_outline : Icons.lock_outline,
                ),
              ),
            );
          }),
        ],
      );
}

class ChapterDialogPage extends StatelessWidget {
  const ChapterDialogPage({
    super.key,
    required this.chapter,
    required this.beats,
    required this.characters,
    required this.canComplete,
    required this.onComplete,
  });

  final StoryChapter chapter;
  final List<StoryBeat> beats;
  final CharacterCatalog characters;
  final bool canComplete;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(chapter.title)),
        body: SafeArea(
          child: DialogueOverlay(
            chapter: chapter,
            beats: beats,
            characters: characters,
            canComplete: canComplete,
            onComplete: () async {
              await onComplete();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ),
      );
}

class DialogueOverlay extends StatefulWidget {
  const DialogueOverlay({
    super.key,
    required this.chapter,
    required this.beats,
    required this.characters,
    required this.canComplete,
    required this.onComplete,
  });

  final StoryChapter chapter;
  final List<StoryBeat> beats;
  final CharacterCatalog characters;
  final bool canComplete;
  final Future<void> Function() onComplete;

  @override
  State<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends State<DialogueOverlay> {
  int _lineIndex = 0;

  List<DialogueLine> get _lines =>
      widget.beats.expand((beat) => beat.lines).toList(growable: false);
  DialogueLine get _line => _lines[_lineIndex];

  Future<void> _advance() async {
    if (_lineIndex + 1 < _lines.length) {
      setState(() => _lineIndex++);
    } else {
      await widget.onComplete();
    }
  }

  Widget _dialogueCard(BuildContext context, DialogueLine line) => Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xff172638).withValues(alpha: .96),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xff71c2cc)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line.text, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _advance,
                  icon: Icon(
                    _lineIndex + 1 == _lines.length
                        ? Icons.check
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    _lineIndex + 1 == _lines.length
                        ? (widget.canComplete
                            ? 'Complete Chapter'
                            : 'Close Story')
                        : 'Continue',
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_lines.isEmpty) {
      return const Center(child: Text('No dialogue in this chapter yet.'));
    }
    final line = _line;
    final speaker = widget.characters.byId(line.speakerId);
    final portrait = line.portraitAssetKey == null || speaker == null
        ? speaker
        : CharacterRef(
            id: speaker.id,
            displayName: speaker.displayName,
            portraitAssetKey: line.portraitAssetKey!,
            fullBodyAssetKey: speaker.fullBodyAssetKey,
            role: speaker.role,
            dialogueStyleKey: speaker.dialogueStyleKey,
            knownByDefault: speaker.knownByDefault,
            roundUiAssetKey: speaker.roundUiAssetKey,
            squareUiAssetKey: speaker.squareUiAssetKey,
            expressionAssetKeys: speaker.expressionAssetKeys,
          );
    final expressionAssetKey = line.expressionKey == null || speaker == null
        ? line.portraitAssetKey
        : speaker.expressionAssetKeys[line.expressionKey] ??
            line.portraitAssetKey;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 520;
        final portraitSize = compact ? 48.0 : 150.0;
        final portraitRegion = constraints.maxHeight * (compact ? .4 : .46);
        final dialogueMaxHeight = constraints.maxHeight * (compact ? .5 : .55);
        if (compact) {
          return Stack(
            fit: StackFit.expand,
            children: [
              if (line.backgroundAssetKey != null)
                ArtAssetSlot(
                  assetKey: line.backgroundAssetKey!,
                  height: 800,
                  icon: Icons.cloud,
                )
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xff39788e), Color(0xff192845)],
                    ),
                  ),
                ),
              Container(color: Colors.black.withValues(alpha: .24)),
              Column(
                children: [
                  SizedBox(
                    height: portraitRegion,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (portrait != null)
                          DialogueCharacterPortrait(
                            character: portrait,
                            assetKey: expressionAssetKey,
                            size: portraitSize,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          speaker?.displayName ?? 'Unknown voice',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _dialogueCard(context, line)),
                ],
              ),
            ],
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            if (line.backgroundAssetKey != null)
              ArtAssetSlot(
                assetKey: line.backgroundAssetKey!,
                height: 800,
                icon: Icons.cloud,
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xff39788e), Color(0xff192845)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.cloud,
                    size: 170,
                    color: Colors.white.withValues(alpha: .07),
                  ),
                ),
              ),
            Container(color: Colors.black.withValues(alpha: .24)),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: portraitRegion,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (portrait != null)
                      DialogueCharacterPortrait(
                        character: portrait,
                        assetKey: expressionAssetKey,
                        size: portraitSize,
                      ),
                    SizedBox(height: compact ? 4 : 14),
                    Text(
                      speaker?.displayName ?? 'Unknown voice',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: dialogueMaxHeight),
                child: _dialogueCard(context, line),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.progress,
    required this.persist,
  });
  final ProgressState progress;
  final Future<void> Function() persist;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.phone_android),
            title: Text('Local Cloud House save'),
            subtitle: Text('Progress stays on this device.'),
          ),
          for (final entry in const [
            ('sound', 'Sound effects'),
            ('music', 'Music'),
            ('haptics', 'Haptics'),
            ('reducedMotion', 'Reduced motion'),
          ])
            SwitchListTile(
              title: Text(entry.$2),
              value: widget.progress.settings[entry.$1] ?? false,
              onChanged: (value) async {
                widget.progress.settings[entry.$1] = value;
                await widget.persist();
                if (mounted) setState(() {});
              },
            ),
        ],
      );
}
