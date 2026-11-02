import 'package:flutter/material.dart';

import '../domain/match3.dart';
import '../domain/phase2_models.dart';
import 'art_widgets.dart';

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
    final cards = widget.catalog
        .query(rarity: _rarity, collectionId: _collectionId, sortByName: true);
    return cards
        .map((card) => card.withProgress(
              stage: widget.progress.collectibleEvolutionStages[card.id],
              discovered:
                  widget.progress.discoveredCollectibleIds.contains(card.id),
              unlocked:
                  widget.progress.unlockedCollectibleIds.contains(card.id),
              favorite:
                  widget.progress.favoriteCollectibleIds.contains(card.id),
            ))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _rarity?.name ?? 'all',
                decoration: const InputDecoration(
                    labelText: 'Rarity', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(
                      value: 'all', child: Text('All rarities')),
                  ...CollectibleRarity.values.map((rarity) => DropdownMenuItem(
                        value: rarity.name,
                        child: Text(rarity.label),
                      )),
                ],
                onChanged: (value) => setState(() => _rarity = value == 'all'
                    ? null
                    : CollectibleRarity.values.byName(value!)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _collectionId ?? 'all',
                decoration: const InputDecoration(
                    labelText: 'Collection', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All sets')),
                  ...widget.catalog.collectionIds.map((id) => DropdownMenuItem(
                        value: id,
                        child: Text(widget.catalog.cards
                            .firstWhere((card) => card.collectionId == id)
                            .collectionName),
                      )),
                ],
                onChanged: (value) => setState(
                    () => _collectionId = value == 'all' ? null : value),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                '${widget.progress.unlockedCollectibleIds.length} of ${widget.catalog.cards.length} discovered · sorted by name'),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .68,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
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
                              persist: widget.persist)));
                  if (mounted) setState(() {});
                },
              );
            },
          ),
        ),
      ]);
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
        discovered:
            widget.progress.discoveredCollectibleIds.contains(widget.card.id),
        unlocked:
            widget.progress.unlockedCollectibleIds.contains(widget.card.id),
        favorite:
            widget.progress.favoriteCollectibleIds.contains(widget.card.id),
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
          const SnackBar(content: Text('Displayed on the Collection Shelf.')));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;
    return Scaffold(
      appBar: AppBar(
          title: Text(card.unlocked ? card.displayName : 'Undiscovered card')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        AspectRatio(
          aspectRatio: .92,
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: rarityColor(card.rarity), width: 3),
                borderRadius: BorderRadius.circular(24)),
            child: ArtAssetSlot(
                assetKey: card.artAssetKey,
                height: 420,
                icon: card.unlocked ? Icons.spa : Icons.lock_outline,
                borderRadius: 0),
          ),
        ),
        const SizedBox(height: 14),
        Text(card.unlocked ? card.displayName : 'Undiscovered',
            style: Theme.of(context).textTheme.headlineSmall),
        Text(
            '${card.rarity.label} · ${card.collectionName} · ${card.category}'),
        const SizedBox(height: 10),
        Text(card.unlocked
            ? card.lore
            : 'Complete Kingdom milestones to discover this card.'),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.auto_awesome),
          title: Text('Puzzle ability · ${card.evolutionStage.label}'),
          subtitle: Text(card.puzzleAbilityText),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 10, children: [
          OutlinedButton.icon(
            onPressed: card.unlocked ? _toggleFavorite : null,
            icon: Icon(card.favorite ? Icons.favorite : Icons.favorite_border),
            label: Text(card.favorite ? 'Unfavorite' : 'Favorite'),
          ),
          FilledButton.icon(
            onPressed: card.unlocked ? _displayOnShelf : null,
            icon: const Icon(Icons.shelves),
            label: const Text('Display on Shelf'),
          ),
        ]),
      ]),
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
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(16), children: [
        Text('STORY CHAPTERS',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(letterSpacing: 1.4)),
        const SizedBox(height: 8),
        ...catalog.chapters.map((chapter) {
          final complete = progress.completedChapterIds.contains(chapter.id);
          final enabled = chapter.playable;
          return Card(
            child: ListTile(
              leading: Icon(enabled ? Icons.menu_book : Icons.lock_outline,
                  color: complete ? const Color(0xffffd36e) : null),
              title: Text(chapter.title),
              subtitle: Text(chapter.synopsis),
              trailing: complete ? const Icon(Icons.check_circle) : null,
              enabled: enabled,
              onTap: enabled
                  ? () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChapterDialogPage(
                                chapter: chapter,
                                characters: characters,
                                onComplete: () async {
                                  progress.completedChapterIds.add(chapter.id);
                                  progress.storyFlags
                                      .add(chapter.completionFlag);
                                  await persist();
                                },
                              )))
                  : null,
            ),
          );
        }),
        const SizedBox(height: 20),
        Text('CHARACTER CATALOG',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(letterSpacing: 1.4)),
        const SizedBox(height: 8),
        ...characters.characters.map((character) {
          final known = character.knownByDefault ||
              progress.storyFlags.contains('character_${character.id}_known');
          return Card(
            child: ListTile(
              leading: CharacterPortrait(character: character, size: 48),
              title: Text(known ? character.displayName : '???'),
              subtitle:
                  Text(known ? character.role : 'A future Kingdom character'),
              trailing:
                  Icon(known ? Icons.check_circle_outline : Icons.lock_outline),
            ),
          );
        }),
      ]);
}

class ChapterDialogPage extends StatelessWidget {
  const ChapterDialogPage({
    super.key,
    required this.chapter,
    required this.characters,
    required this.onComplete,
  });

  final StoryChapter chapter;
  final CharacterCatalog characters;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(chapter.title)),
        body: SafeArea(
          child: DialogueOverlay(
            chapter: chapter,
            characters: characters,
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
    required this.characters,
    required this.onComplete,
  });

  final StoryChapter chapter;
  final CharacterCatalog characters;
  final Future<void> Function() onComplete;

  @override
  State<DialogueOverlay> createState() => _DialogueOverlayState();
}

class _DialogueOverlayState extends State<DialogueOverlay> {
  int _lineIndex = 0;

  List<DialogueLine> get _lines => widget.chapter.dialogue;
  DialogueLine get _line => _lines[_lineIndex];

  Future<void> _advance() async {
    if (_lineIndex + 1 < _lines.length) {
      setState(() => _lineIndex++);
    } else {
      await widget.onComplete();
    }
  }

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
          );
    return Stack(fit: StackFit.expand, children: [
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
                colors: [Color(0xff39788e), Color(0xff192845)]),
          ),
          child: Center(
              child: Icon(Icons.cloud,
                  size: 170, color: Colors.white.withValues(alpha: .07))),
        ),
      Container(color: Colors.black.withValues(alpha: .24)),
      Align(
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (portrait != null)
            CharacterPortrait(character: portrait, size: 150),
          const SizedBox(height: 14),
          Text(speaker?.displayName ?? 'Unknown voice',
              style: Theme.of(context).textTheme.titleLarge),
        ]),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: const Color(0xff172638).withValues(alpha: .96),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xff71c2cc))),
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
                    icon: Icon(_lineIndex + 1 == _lines.length
                        ? Icons.check
                        : Icons.arrow_forward),
                    label: Text(_lineIndex + 1 == _lines.length
                        ? 'Complete Chapter'
                        : 'Continue'),
                  ),
                ),
              ]),
        ),
      ),
    ]);
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(
      {super.key, required this.progress, required this.persist});
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
