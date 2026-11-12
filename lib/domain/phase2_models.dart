enum CollectibleRarity { common, rare, epic, legendary }

extension CollectibleRarityLabel on CollectibleRarity {
  String get label => switch (this) {
        CollectibleRarity.common => 'Common',
        CollectibleRarity.rare => 'Rare',
        CollectibleRarity.epic => 'Epic',
        CollectibleRarity.legendary => 'Legendary',
      };
}

enum EvolutionStage { seedling, bud, frosted, legendary }

extension EvolutionStageLabel on EvolutionStage {
  String get label => switch (this) {
        EvolutionStage.seedling => 'Seedling',
        EvolutionStage.bud => 'Bud',
        EvolutionStage.frosted => 'Frosted',
        EvolutionStage.legendary => 'Legendary',
      };
}

enum WorldNodeState { locked, available, restored, customized, preview }

extension WorldNodeStateLabel on WorldNodeState {
  String get label => switch (this) {
        WorldNodeState.locked => 'Locked',
        WorldNodeState.available => 'Available',
        WorldNodeState.restored => 'Restored',
        WorldNodeState.customized => 'Customized',
        WorldNodeState.preview => 'Preview',
      };
}

class CollectibleCard {
  const CollectibleCard({
    required this.id,
    required this.displayName,
    required this.collectionId,
    required this.collectionName,
    required this.rarity,
    required this.strainClass,
    required this.category,
    required this.lore,
    required this.puzzleAbilityText,
    required this.evolutionStage,
    required this.discovered,
    required this.unlocked,
    required this.favorite,
    required this.artAssetKey,
    this.evolutionXp = 0,
    this.equipped = false,
  });

  final String id;
  final String displayName;
  final String collectionId;
  final String collectionName;
  final CollectibleRarity rarity;
  final String strainClass;
  final String category;
  final String lore;
  final String puzzleAbilityText;
  final EvolutionStage evolutionStage;
  final bool discovered;
  final bool unlocked;
  final bool favorite;
  final String artAssetKey;
  final int evolutionXp;
  final bool equipped;

  factory CollectibleCard.fromJson(Map<String, dynamic> json) =>
      CollectibleCard(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        collectionId: json['collectionId'] as String,
        collectionName: json['collectionName'] as String,
        rarity: CollectibleRarity.values.byName(
          (json['rarity'] as String).toLowerCase(),
        ),
        strainClass: json['class'] as String? ?? 'Hybrid',
        category: json['category'] as String,
        lore: json['lore'] as String,
        puzzleAbilityText: json['puzzleAbilityText'] as String,
        evolutionStage: EvolutionStage.values.byName(
          (json['evolutionStage'] as String).toLowerCase(),
        ),
        discovered: json['discovered'] as bool? ?? false,
        unlocked: json['unlocked'] as bool? ?? false,
        favorite: json['favorite'] as bool? ?? false,
        artAssetKey: json['artAssetKey'] as String,
        evolutionXp: json['evolutionXp'] as int? ?? 0,
      );

  CollectibleCard withProgress({
    EvolutionStage? stage,
    bool? discovered,
    bool? unlocked,
    bool? favorite,
    int? evolutionXp,
    bool? equipped,
  }) =>
      CollectibleCard(
        id: id,
        displayName: displayName,
        collectionId: collectionId,
        collectionName: collectionName,
        rarity: rarity,
        strainClass: strainClass,
        category: category,
        lore: lore,
        puzzleAbilityText: puzzleAbilityText,
        evolutionStage: stage ?? evolutionStage,
        discovered: discovered ?? this.discovered,
        unlocked: unlocked ?? this.unlocked,
        favorite: favorite ?? this.favorite,
        artAssetKey: artAssetKey,
        evolutionXp: evolutionXp ?? this.evolutionXp,
        equipped: equipped ?? this.equipped,
      );
}

class CollectionCatalog {
  const CollectionCatalog(this.cards);
  final List<CollectibleCard> cards;

  factory CollectionCatalog.fromJson(Map<String, dynamic> json) =>
      CollectionCatalog(
        (json['cards'] as List)
            .cast<Map<String, dynamic>>()
            .map(CollectibleCard.fromJson)
            .toList(growable: false),
      );

  List<CollectibleCard> query({
    CollectibleRarity? rarity,
    String? collectionId,
    bool sortByName = true,
  }) {
    final result = cards
        .where((card) => rarity == null || card.rarity == rarity)
        .where(
          (card) => collectionId == null || card.collectionId == collectionId,
        )
        .toList();
    if (sortByName) {
      result.sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );
    }
    return result;
  }

  List<String> get collectionIds =>
      cards.map((c) => c.collectionId).toSet().toList()..sort();
}

class WorldNodeDefinition {
  const WorldNodeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.assetKey,
    required this.defaultState,
    this.unlockAtLevel,
    this.previewAtLevel,
    this.restoredWhen,
    this.customizedWhen,
    this.hookFlag,
  });

  final String id;
  final String title;
  final String description;
  final String assetKey;
  final WorldNodeState defaultState;
  final int? unlockAtLevel;
  final int? previewAtLevel;
  final String? restoredWhen;
  final String? customizedWhen;
  final String? hookFlag;

  factory WorldNodeDefinition.fromJson(Map<String, dynamic> json) =>
      WorldNodeDefinition(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        assetKey: json['assetKey'] as String,
        defaultState: WorldNodeState.values.byName(
          (json['defaultState'] as String).toLowerCase(),
        ),
        unlockAtLevel: json['unlockAtLevel'] as int?,
        previewAtLevel: json['previewAtLevel'] as int?,
        restoredWhen: json['restoredWhen'] as String?,
        customizedWhen: json['customizedWhen'] as String?,
        hookFlag: json['hookFlag'] as String?,
      );
}

class WorldCatalog {
  const WorldCatalog(this.nodes);
  final List<WorldNodeDefinition> nodes;

  factory WorldCatalog.fromJson(Map<String, dynamic> json) => WorldCatalog(
        (json['nodes'] as List)
            .cast<Map<String, dynamic>>()
            .map(WorldNodeDefinition.fromJson)
            .toList(growable: false),
      );
}

class CharacterRef {
  const CharacterRef({
    required this.id,
    required this.displayName,
    required this.portraitAssetKey,
    required this.fullBodyAssetKey,
    required this.role,
    required this.dialogueStyleKey,
    required this.knownByDefault,
    this.roundUiAssetKey,
    this.squareUiAssetKey,
    this.expressionAssetKeys = const {},
    this.uiAssetKeys = const {},
  });

  final String id;
  final String displayName;
  final String portraitAssetKey;
  final String fullBodyAssetKey;
  final String role;
  final String dialogueStyleKey;
  final bool knownByDefault;
  final String? roundUiAssetKey;
  final String? squareUiAssetKey;
  final Map<String, String> expressionAssetKeys;
  final Map<String, String> uiAssetKeys;

  factory CharacterRef.fromJson(Map<String, dynamic> json) => CharacterRef(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        portraitAssetKey: json['portraitAssetKey'] as String,
        fullBodyAssetKey: json['fullBodyAssetKey'] as String,
        role: json['role'] as String,
        dialogueStyleKey: json['dialogueStyleKey'] as String,
        knownByDefault: json['knownByDefault'] as bool? ?? false,
        roundUiAssetKey: json['roundUiAssetKey'] as String?,
        squareUiAssetKey: json['squareUiAssetKey'] as String?,
        expressionAssetKeys: (json['expressionAssetKeys'] as Map?)?.map(
              (key, value) => MapEntry(key as String, value as String),
            ) ??
            const {},
        uiAssetKeys: (json['uiAssetKeys'] as Map?)?.map(
              (key, value) => MapEntry(key as String, value as String),
            ) ??
            const {},
      );
}

class CharacterCatalog {
  const CharacterCatalog(this.characters);
  final List<CharacterRef> characters;

  factory CharacterCatalog.fromJson(Map<String, dynamic> json) =>
      CharacterCatalog(
        (json['characters'] as List)
            .cast<Map<String, dynamic>>()
            .map(CharacterRef.fromJson)
            .toList(growable: false),
      );

  CharacterRef? byId(String id) {
    for (final character in characters) {
      if (character.id == id) return character;
    }
    return null;
  }
}

class StoryFlag {
  const StoryFlag({required this.id, required this.description});
  final String id;
  final String description;

  factory StoryFlag.fromJson(Map<String, dynamic> json) => StoryFlag(
        id: json['id'] as String,
        description: json['description'] as String,
      );
}

class DialogueLine {
  const DialogueLine({
    required this.speakerId,
    required this.text,
    this.portraitAssetKey,
    this.backgroundAssetKey,
    this.expressionKey,
  });

  final String speakerId;
  final String text;
  final String? portraitAssetKey;
  final String? backgroundAssetKey;
  final String? expressionKey;

  factory DialogueLine.fromJson(Map<String, dynamic> json) => DialogueLine(
        speakerId: json['speakerId'] as String,
        text: json['text'] as String,
        portraitAssetKey: json['portraitAssetKey'] as String?,
        backgroundAssetKey: json['backgroundAssetKey'] as String?,
        expressionKey: json['expressionKey'] as String?,
      );
}

class StoryBeat {
  const StoryBeat({
    required this.id,
    required this.lines,
    this.unlockAtLevel = 1,
  });
  final String id;
  final List<DialogueLine> lines;
  final int unlockAtLevel;

  factory StoryBeat.fromJson(Map<String, dynamic> json) => StoryBeat(
        id: json['id'] as String,
        unlockAtLevel: json['unlockAtLevel'] as int? ?? 1,
        lines: (json['lines'] as List)
            .cast<Map<String, dynamic>>()
            .map(DialogueLine.fromJson)
            .toList(growable: false),
      );
}

Set<String> characterKnownFlagsForBeats(Iterable<StoryBeat> beats) => beats
    .expand((beat) => beat.lines)
    .map((line) => line.speakerId)
    .where((speakerId) => speakerId != 'mr_weed')
    .map((speakerId) => 'character_${speakerId}_known')
    .toSet();

class StoryChapter {
  const StoryChapter({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.completionFlag,
    required this.characterIds,
    required this.beats,
    required this.playable,
    this.unlockAtLevel = 1,
    this.completeAtLevel,
  });

  final String id;
  final String title;
  final String synopsis;
  final String completionFlag;
  final List<String> characterIds;
  final List<StoryBeat> beats;
  final bool playable;
  final int unlockAtLevel;
  final int? completeAtLevel;

  List<DialogueLine> get dialogue =>
      beats.expand((beat) => beat.lines).toList();

  factory StoryChapter.fromJson(Map<String, dynamic> json) => StoryChapter(
        id: json['id'] as String,
        title: json['title'] as String,
        synopsis: json['synopsis'] as String,
        completionFlag: json['completionFlag'] as String,
        characterIds: (json['characterIds'] as List).cast<String>(),
        beats: (json['beats'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(StoryBeat.fromJson)
            .toList(growable: false),
        playable: json['playable'] as bool? ?? false,
        unlockAtLevel: json['unlockAtLevel'] as int? ?? 1,
        completeAtLevel: json['completeAtLevel'] as int?,
      );
}

class StoryCatalog {
  const StoryCatalog({required this.chapters, required this.flags});
  final List<StoryChapter> chapters;
  final List<StoryFlag> flags;

  factory StoryCatalog.fromJson(Map<String, dynamic> json) => StoryCatalog(
        chapters: (json['chapters'] as List)
            .cast<Map<String, dynamic>>()
            .map(StoryChapter.fromJson)
            .toList(growable: false),
        flags: (json['flags'] as List)
            .cast<Map<String, dynamic>>()
            .map(StoryFlag.fromJson)
            .toList(growable: false),
      );
}
