import 'package:flutter/material.dart';

import '../domain/phase2_models.dart';
import 'art_registry.dart';

Color rarityColor(CollectibleRarity rarity) => switch (rarity) {
      CollectibleRarity.common => const Color(0xff8db6bf),
      CollectibleRarity.rare => const Color(0xff61a8e8),
      CollectibleRarity.epic => const Color(0xffb793ef),
      CollectibleRarity.legendary => const Color(0xffffc95e),
    };

class ArtAssetSlot extends StatelessWidget {
  const ArtAssetSlot({
    super.key,
    required this.assetKey,
    required this.height,
    this.width,
    this.label,
    this.icon = Icons.auto_awesome,
    this.borderRadius = 18,
  });

  final String assetKey;
  final double height;
  final double? width;
  final String? label;
  final IconData icon;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final path = ArtRegistry.pathFor(assetKey);
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(fit: StackFit.expand, children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff437f90), Color(0xff242c53)],
              ),
            ),
            child: Center(
                child: Icon(icon,
                    size: height * .34, color: const Color(0xffffd36e))),
          ),
          if (path != null)
            Image.asset(path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.expand()),
          if (label != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                color: Colors.black.withValues(alpha: .48),
                child: Text(label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ]),
      ),
    );
  }
}

class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({super.key, required this.character, this.size = 76});
  final CharacterRef character;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = ArtRegistry.pathFor(character.portraitAssetKey);
    return SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xff6db8c3), Color(0xff7253a4)]),
          ),
          child: path == null
              ? const Icon(Icons.person, color: Colors.white, size: 38)
              : Image.asset(path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, color: Colors.white, size: 38)),
        ),
      ),
    );
  }
}

class CollectibleCardView extends StatelessWidget {
  const CollectibleCardView(
      {super.key, required this.card, required this.onTap});
  final CollectibleCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = rarityColor(card.rarity);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: accent, width: 2),
          borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              ArtAssetSlot(
                  assetKey: card.artAssetKey,
                  height: 170,
                  icon: card.unlocked ? Icons.spa : Icons.lock,
                  borderRadius: 0),
              if (!card.unlocked)
                Container(
                    color: Colors.black.withValues(alpha: .48),
                    child: const Icon(Icons.lock_outline, size: 36)),
              if (card.favorite)
                const Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(Icons.favorite, color: Colors.pinkAccent)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card.unlocked ? card.displayName : 'Undiscovered',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(card.rarity.label,
                  style: TextStyle(color: accent, fontSize: 12)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class WorldNodeView extends StatelessWidget {
  const WorldNodeView(
      {super.key, required this.node, required this.state, this.onTap});
  final WorldNodeDefinition node;
  final WorldNodeState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = state != WorldNodeState.locked && onTap != null;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ArtAssetSlot(
                assetKey: node.assetKey,
                height: 68,
                icon: state == WorldNodeState.locked
                    ? Icons.lock_outline
                    : Icons.cloud),
            const SizedBox(height: 4),
            Text(node.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(state.label,
                style: TextStyle(
                    fontSize: 11,
                    color: state == WorldNodeState.locked
                        ? Colors.white54
                        : const Color(0xffffd36e))),
          ]),
        ),
      ),
    );
  }
}

class CollectionShelf extends StatelessWidget {
  const CollectionShelf({super.key, this.card, required this.onChoose});
  final CollectibleCard? card;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onChoose,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Icon(Icons.shelves,
                  size: 35, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('COLLECTION SHELF',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(
                        card?.displayName ??
                            'Choose a discovered card to display',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ])),
              if (card != null) ...[
                const SizedBox(width: 10),
                ArtAssetSlot(
                    assetKey: card!.artAssetKey,
                    height: 54,
                    width: 48,
                    icon: Icons.spa,
                    borderRadius: 10),
              ] else
                const Icon(Icons.add_circle_outline),
            ]),
          ),
        ),
      );
}

class RoomBackgroundSlot extends StatelessWidget {
  const RoomBackgroundSlot(
      {super.key, required this.assetKey, required this.child});
  final String assetKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        ArtAssetSlot(assetKey: assetKey, height: 300, icon: Icons.weekend),
        Container(color: Colors.black.withValues(alpha: .28)),
        child,
      ]);
}
