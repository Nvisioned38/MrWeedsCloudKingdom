import 'dart:async';
import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/match3.dart';
import 'domain/phase2_models.dart';
import 'game/cloud_board_game.dart';
import 'presentation/art_manifest.dart';
import 'presentation/art_widgets.dart';
import 'presentation/cloud_kingdom_theme.dart';
import 'presentation/phase2_screens.dart';

const _saveKey = 'cloud_kingdom_progress_v2';

void main() => runApp(const CloudKingdomApp());

class CloudKingdomApp extends StatelessWidget {
  const CloudKingdomApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Mr. Weed's: Cloud Kingdom",
        theme: buildCloudKingdomTheme(),
        home: const BootScreen(),
      );
}

class BootScreen extends StatefulWidget {
  const BootScreen({super.key});
  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  ProgressState progress = ProgressState();
  List<LevelSpec> levels = [];
  late CollectionCatalog collectionCatalog;
  late WorldCatalog worldCatalog;
  late CharacterCatalog characterCatalog;
  late StoryCatalog storyCatalog;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_saveKey);
    var shouldPersistMigration = saved == null;
    if (saved != null) {
      final savedProgress = jsonDecode(saved) as Map<String, dynamic>;
      progress = ProgressState.fromJson(savedProgress);
      shouldPersistMigration = (savedProgress['schema'] as num? ?? 0) < 3;
    } else {
      final legacy = prefs.getString('cloud_kingdom_save_v1');
      if (legacy != null) {
        final old = jsonDecode(legacy) as Map<String, dynamic>;
        final completed = (old['completed'] as List? ?? []).cast<int>();
        final oldStyle = old['loungeStyle'] as String?;
        progress = ProgressState.fromJson({
          'completed': completed,
          'stars': completed,
          'best': old['best'] ?? <String, int>{},
          'coins': old['coins'] ?? 0,
          'loungeRestored':
              (old['loungeRestored'] as bool?) ?? (oldStyle != null),
          'loungeStyleId': switch (oldStyle) {
            'Classic Cloud' => 'classic_cloud',
            'Psychedelic' => 'psychedelic',
            'Retro 70s' => 'retro_70s',
            _ => null
          },
        });
      }
    }
    final dataFiles = await Future.wait([
      rootBundle.loadString('assets/data/levels_001_030.json'),
      rootBundle.loadString('assets/data/collectibles.json'),
      rootBundle.loadString('assets/data/world_nodes.json'),
      rootBundle.loadString('assets/data/characters.json'),
      rootBundle.loadString('assets/data/story_chapters.json'),
      rootBundle.loadString('assets/art/manifest.json'),
    ]);
    final data = jsonDecode(dataFiles[0]) as Map<String, dynamic>;
    levels = (data['levels'] as List)
        .cast<Map<String, dynamic>>()
        .map(LevelSpec.fromJson)
        .toList(growable: false);
    collectionCatalog = CollectionCatalog.fromJson(
        jsonDecode(dataFiles[1]) as Map<String, dynamic>);
    worldCatalog =
        WorldCatalog.fromJson(jsonDecode(dataFiles[2]) as Map<String, dynamic>);
    characterCatalog = CharacterCatalog.fromJson(
        jsonDecode(dataFiles[3]) as Map<String, dynamic>);
    storyCatalog =
        StoryCatalog.fromJson(jsonDecode(dataFiles[4]) as Map<String, dynamic>);
    final artManifest = ArtManifest.decode(dataFiles[5]);
    if (kDebugMode && artManifest.unavailableRuntimeArt.isNotEmpty) {
      final pending = artManifest.unavailableRuntimeArt;
      final sample = pending.take(12).map((record) => record.key).join(', ');
      debugPrint(
        '[V1 ART PENDING] ${pending.length} art references are not integrated; '
        'first keys: $sample. See assets/art/manifest.json.',
      );
    }
    if (shouldPersistMigration) await persist();
    if (mounted) setState(() => ready = true);
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKey, jsonEncode(progress.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return TitleScreen(
        progress: progress,
        levels: levels,
        collectionCatalog: collectionCatalog,
        worldCatalog: worldCatalog,
        characterCatalog: characterCatalog,
        storyCatalog: storyCatalog,
        persist: persist,
        onNewGame: () async {
          progress.resetForNewGame();
          await persist();
          if (mounted) setState(() {});
        });
  }
}

class TitleScreen extends StatelessWidget {
  const TitleScreen(
      {super.key,
      required this.progress,
      required this.levels,
      required this.collectionCatalog,
      required this.worldCatalog,
      required this.characterCatalog,
      required this.storyCatalog,
      required this.persist,
      required this.onNewGame});
  final ProgressState progress;
  final List<LevelSpec> levels;
  final CollectionCatalog collectionCatalog;
  final WorldCatalog worldCatalog;
  final CharacterCatalog characterCatalog;
  final StoryCatalog storyCatalog;
  final Future<void> Function() persist;
  final Future<void> Function() onNewGame;

  void _openWorld(BuildContext context) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => HomeScreen(
              progress: progress,
              levels: levels,
              collectionCatalog: collectionCatalog,
              worldCatalog: worldCatalog,
              characterCatalog: characterCatalog,
              storyCatalog: storyCatalog,
              persist: persist)));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color(0xff8bd3df),
                Color(0xff22465d),
                Color(0xff132b40)
              ])),
          child: SafeArea(
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 320,
                              height: 240,
                              child: Image.asset(
                                'assets/art/brand/cloud_kingdom_title.png',
                                fit: BoxFit.contain,
                                cacheWidth: 960,
                                semanticLabel:
                                    "Mr. Weed's Cloud Kingdom official title",
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 106,
                              height: 54,
                              child: Image.asset(
                                'assets/art/brand/cloud_cup_logo.png',
                                fit: BoxFit.contain,
                                cacheWidth: 512,
                                semanticLabel: 'Official Cloud Cup logo',
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Match • Build • Collect • Explore'),
                            const SizedBox(height: 36),
                            FilledButton.icon(
                                onPressed: () async {
                                  if (progress.completedLevels.isEmpty) {
                                    await onNewGame();
                                  }
                                  if (context.mounted) _openWorld(context);
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: Text(progress.completedLevels.isEmpty
                                    ? 'New Game'
                                    : 'Continue'),
                                style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(54))),
                            if (progress.completedLevels.isNotEmpty) ...[
                              TextButton(
                                  onPressed: () => _openWorld(context),
                                  child: const Text('Level Path')),
                              TextButton(
                                  onPressed: () async {
                                    final startFresh = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                              title: const Text(
                                                  'Start a new game?'),
                                              content: const Text(
                                                  'This resets local Cloud House progress.'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            dialogContext,
                                                            false),
                                                    child:
                                                        const Text('Cancel')),
                                                FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            dialogContext,
                                                            true),
                                                    child: const Text(
                                                        'Start Fresh'))
                                              ],
                                            ));
                                    if (startFresh == true) {
                                      await onNewGame();
                                      if (context.mounted) _openWorld(context);
                                    }
                                  },
                                  child: const Text('New Game')),
                            ],
                          ])))),
        ),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.progress,
    required this.levels,
    required this.collectionCatalog,
    required this.worldCatalog,
    required this.characterCatalog,
    required this.storyCatalog,
    required this.persist,
  });

  final ProgressState progress;
  final List<LevelSpec> levels;
  final CollectionCatalog collectionCatalog;
  final WorldCatalog worldCatalog;
  final CharacterCatalog characterCatalog;
  final StoryCatalog storyCatalog;
  final Future<void> Function() persist;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey _levelPathKey = GlobalKey();

  String get _title =>
      const ['Cloud House', 'Collection', 'Story', 'Settings'][_selectedIndex];

  CollectibleCard? get _displayCard {
    final id = widget.progress.displayedCollectibleId;
    if (id == null) return null;
    for (final card in widget.collectionCatalog.cards) {
      if (card.id == id &&
          widget.progress.unlockedCollectibleIds.contains(id)) {
        return card.withProgress(
          stage: widget.progress.collectibleEvolutionStages[id],
          discovered: true,
          unlocked: true,
          favorite: widget.progress.favoriteCollectibleIds.contains(id),
        );
      }
    }
    return null;
  }

  Future<void> _playLevel(LevelSpec level) async {
    await Navigator.push<void>(
        context,
        MaterialPageRoute(
            builder: (_) => PlayScreen(
                level: level,
                progress: widget.progress,
                persist: widget.persist)));
    if (mounted) setState(() {});
  }

  Future<void> _openLounge(WorldNodeDefinition node) async {
    final state = widget.progress.stateForWorldNode(node);
    if (state == WorldNodeState.locked) return;
    if (state == WorldNodeState.available) {
      await Navigator.push<void>(
          context,
          MaterialPageRoute(
              builder: (_) => LoungeScreen(
                  progress: widget.progress, persist: widget.persist)));
    } else {
      await Navigator.push<void>(
          context,
          MaterialPageRoute(
              builder: (_) => LoungeRoomScreen(
                    progress: widget.progress,
                    displayedCard: _displayCard,
                    persist: widget.persist,
                    onChooseCard: () {
                      Navigator.pop(context);
                      setState(() => _selectedIndex = 1);
                    },
                    onChangeStyle: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LoungeScreen(
                                progress: widget.progress,
                                persist: widget.persist))),
                  )));
    }
    if (mounted) setState(() {});
  }

  Future<void> _showWorkshopHint() async {
    widget.progress.storyFlags.add('keefler_mystery_seen');
    await widget.persist();
    if (!mounted) return;
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Unmarked Workshop'),
              content: const Text(
                  'A tiny winged gear is carved into the stone. The mark has no name.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
  }

  Future<void> _showWorldMilestone(String title, String message,
      {String? assetKey}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (assetKey != null) ...[
            SizedBox(
              height: 170,
              width: double.infinity,
              child: ArtAssetSlot(
                assetKey: assetKey,
                height: 170,
                icon: assetKey == 'room_kitchen'
                    ? Icons.restaurant
                    : Icons.visibility_outlined,
                fit: assetKey == 'room_art_gallery'
                    ? BoxFit.contain
                    : BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(message),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _homeTab() {
    final nodes = widget.worldCatalog.nodes
        .where((node) => node.id != 'unmarked_workshop')
        .toList(growable: false);
    final nextLevel = widget.levels.firstWhere(
        (level) => level.id == widget.progress.unlockedThrough,
        orElse: () => widget.levels.first);
    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(children: [
              ArtAssetSlot(
                  assetKey: widget.progress.loungeRestorationUnlocked
                      ? 'room_cloud_house'
                      : 'room_cloud_house_damaged',
                  height: 150,
                  icon: Icons.home_work,
                  label: widget.progress.loungeRestorationUnlocked
                      ? 'CLOUD HOUSE RESTORED'
                      : 'CLOUD HOUSE'),
              Positioned(
                  right: 12,
                  top: 12,
                  child: Chip(
                    avatar: const Icon(Icons.stars, size: 18),
                    label: Text(
                        '${widget.progress.coins} coins · ${widget.progress.starLevelIds.length} stars'),
                  )),
            ]),
          ),
          const SizedBox(height: 14),
          CollectionShelf(
            card: _displayCard,
            onChoose: () => setState(() => _selectedIndex = 1),
          ),
          Text('CURRENT PATH',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(letterSpacing: 1.5)),
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.play_circle_fill, color: Color(0xffffd36e)),
              title: Text(nextLevel.name),
              subtitle: Text(
                  'Level ${nextLevel.id} · ${nextLevel.moves} moves${nextLevel.isChapterFinale ? ' · Chapter Finale' : ''}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _playLevel(nextLevel),
            ),
          ),
          Text('WORLD NODES',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(letterSpacing: 1.5)),
          if (widget.progress.loungeStyleId != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child:
                  Text('Saved Lounge style: ${widget.progress.loungeStyleId}'),
            ),
          const SizedBox(height: 6),
          SizedBox(
            height: 154,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final node in nodes)
                SizedBox(
                  width: 148,
                  child: WorldNodeView(
                    node: node,
                    state: widget.progress.stateForWorldNode(node),
                    displayAssetKey: node.id == 'lounge'
                        ? _loungeAssetKey(widget.progress.loungeStyleId)
                        : null,
                    onTap: node.id == 'cloud_house'
                        ? () {
                            final anchor = _levelPathKey.currentContext;
                            if (anchor != null) {
                              Scrollable.ensureVisible(anchor,
                                  duration: const Duration(milliseconds: 250));
                            }
                          }
                        : node.id == 'lounge'
                            ? () => _openLounge(node)
                            : node.id == 'kitchen' &&
                                    widget.progress.stateForWorldNode(node) ==
                                        WorldNodeState.available
                                ? () => _showWorldMilestone(
                                      'Chef Blaze’s Kitchen',
                                      'The Level 20 finale opened the Kitchen. Chef Blaze is ready for the next chapter of puzzle-sized culinary chaos.',
                                      assetKey: 'room_kitchen',
                                    )
                                : node.id == 'higher_art_gallery' &&
                                        widget.progress
                                                .stateForWorldNode(node) ==
                                            WorldNodeState.preview
                                    ? () => _showWorldMilestone(
                                          'Higher Art Gallery Preview',
                                          'The missing collection pieces reveal a gallery wing above the clouds. This is a preview; the rooms and full Gallery system remain closed for a later chapter.',
                                          assetKey: 'room_art_gallery',
                                        )
                                    : null,
                  ),
                ),
            ]),
          ),
          Card(
            child: ListTile(
              leading: const ArtAssetSlot(
                  assetKey: 'symbol_unknown_workshop',
                  height: 48,
                  width: 48,
                  icon: Icons.settings_suggest_outlined,
                  borderRadius: 12),
              title: const Text('An unmarked workshop'),
              subtitle: const Text(
                  'A small winged gear is carved near the sealed stairs.'),
              trailing: const Text('???',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: _showWorkshopHint,
            ),
          ),
          const SizedBox(height: 6),
          Text('LEVEL PATH',
              key: _levelPathKey,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 6),
          for (final level
              in widget.levels.where((level) => level.id != nextLevel.id))
            Builder(builder: (context) {
              final isOpen = level.id <= widget.progress.unlockedThrough;
              final isDone = widget.progress.completedLevels.contains(level.id);
              return Card(
                color: isOpen ? null : const Color(0xff263a48),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDone
                        ? const Color(0xffffd36e)
                        : const Color(0xff397d8d),
                    child: Text('${level.id}',
                        style: const TextStyle(
                            color: Color(0xff173344),
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(level.name),
                  subtitle: Text(
                      '${level.isChapterFinale ? 'Chapter Finale · ' : ''}Chapter ${level.chapter} • ${level.moves} moves • ${level.objectives.length} objective${level.objectives.length == 1 ? '' : 's'}'),
                  trailing: Icon(isDone
                      ? Icons.check_circle
                      : isOpen
                          ? Icons.play_arrow
                          : Icons.lock),
                  onTap: isOpen ? () => _playLevel(level) : null,
                ),
              );
            }),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homeTab(),
      CollectionScreen(
          catalog: widget.collectionCatalog,
          progress: widget.progress,
          persist: widget.persist),
      StoryScreen(
          catalog: widget.storyCatalog,
          characters: widget.characterCatalog,
          progress: widget.progress,
          persist: widget.persist),
      SettingsScreen(progress: widget.progress, persist: widget.persist),
    ];
    return Scaffold(
      appBar: AppBar(
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 76,
              height: 30,
              child: Image.asset(
                'assets/art/brand/mr_weeds_logo.png',
                fit: BoxFit.contain,
                cacheWidth: 512,
                semanticLabel: "Official Mr. Weed's logo",
              ),
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(_title, overflow: TextOverflow.ellipsis)),
          ]),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back))),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(Icons.collections_bookmark),
              label: 'Collection'),
          NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories),
              label: 'Story'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}

class LoungeRoomScreen extends StatefulWidget {
  const LoungeRoomScreen({
    super.key,
    required this.progress,
    required this.displayedCard,
    required this.persist,
    required this.onChooseCard,
    required this.onChangeStyle,
  });
  final ProgressState progress;
  final CollectibleCard? displayedCard;
  final Future<void> Function() persist;
  final VoidCallback onChooseCard;
  final Future<void> Function() onChangeStyle;

  @override
  State<LoungeRoomScreen> createState() => _LoungeRoomScreenState();
}

class _LoungeRoomScreenState extends State<LoungeRoomScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lounge Room')),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          SizedBox(
            height: 230,
            child: RoomBackgroundSlot(
              assetKey: _loungeAssetKey(widget.progress.loungeStyleId),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                      widget.progress.loungeStyleId ??
                          'A room above the clouds',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Style: ${widget.progress.loungeStyleId ?? 'Classic Cloud'}',
              style: Theme.of(context).textTheme.titleLarge),
          const Text(
              'Your restored room keeps its chosen look on this device.'),
          const SizedBox(height: 12),
          CollectionShelf(
              card: widget.displayedCard, onChoose: widget.onChooseCard),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () async {
              await widget.onChangeStyle();
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.palette_outlined),
            label: const Text('Change Lounge Style'),
          ),
        ]),
      );
}

class PlayScreen extends StatefulWidget {
  const PlayScreen(
      {super.key,
      required this.level,
      required this.progress,
      required this.persist,
      this.initialSession});
  final LevelSpec level;
  final ProgressState progress;
  final Future<void> Function() persist;
  final LevelSession? initialSession;
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final LevelSession session = widget.initialSession ??
      LevelSession(
        widget.level,
        puzzlePerk: widget.progress.equippedCollectibleId == 'cloud_nine'
            ? PuzzlePerk.cloudNineScoreHeadstart
            : PuzzlePerk.none,
      );
  late final CloudBoardGame game = CloudBoardGame(
    session: session,
    onTurn: _onTurn,
    onSelectionChanged: () {
      if (mounted) setState(() {});
    },
    reducedMotion: widget.progress.settings['reducedMotion'] ?? false,
  );
  bool _finished = false;

  void _onTurn(TurnResult result) {
    if (result.accepted && (widget.progress.settings['haptics'] ?? true)) {
      unawaited(HapticFeedback.selectionClick());
    }
    if (mounted) setState(() {});
    if (session.outcome != LevelOutcome.playing) _finish();
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    RewardResult? reward;
    widget.progress.recordBestScore(widget.level, session.board.score);
    if (session.outcome == LevelOutcome.won) {
      reward =
          widget.progress.grantFirstClear(widget.level, session.board.score);
    }
    await widget.persist();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultsScreen(
              level: widget.level,
              session: session,
              progress: widget.progress,
              persist: widget.persist,
              reward: reward,
              offerLounge: widget.level.id == 10 &&
                  session.outcome == LevelOutcome.won &&
                  !widget.progress.loungeRestored,
            )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text('Level ${widget.level.id} · ${widget.level.name}'),
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close))),
        body: SafeArea(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('OBJECTIVES',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text('Moves ${session.movesRemaining}',
                        style: const TextStyle(fontWeight: FontWeight.bold))
                  ])),
          ...session.objectives.map((progress) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
              child: Row(children: [
                Icon(
                    progress.complete
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: progress.complete
                        ? const Color(0xff83d7a0)
                        : const Color(0xffe6d393)),
                const SizedBox(width: 8),
                Expanded(child: Text(progress.label)),
                Text('${progress.value}/${progress.definition.target}')
              ]))),
          Expanded(
              child: Center(
                  child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: LayoutBuilder(builder: (context, constraints) {
                            final rows = session.board.rows;
                            final cols = session.board.cols;
                            return Stack(children: [
                              GameWidget(
                                key: const ValueKey('match3-board'),
                                game: game,
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Image.asset(
                                    'assets/art/match3/board_frame_transparent_center.png',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              for (var row = 0; row < rows; row++)
                                for (var col = 0; col < cols; col++)
                                  _BoardCellSemantics(
                                    key: ValueKey('board-cell-$row-$col'),
                                    row: row,
                                    col: col,
                                    width: constraints.maxWidth / cols,
                                    height: constraints.maxHeight / rows,
                                    piece: session.board.at(row, col),
                                    blocker: session.board.blockerAt(row, col),
                                    selected:
                                        game.selectedCell == Cell(row, col),
                                    onTap: () => game.tapCell(Cell(row, col)),
                                  ),
                            ]);
                          }))))),
          if (widget.level.tutorial != null)
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: Text(_tutorialText(widget.level.tutorial!),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall)),
        ])),
      );
}

String _tutorialText(String id) => switch (id) {
      'basic_swap_match' =>
        'Swap neighboring tiles to make a line of three or more.',
      'objective_counter' =>
        'Collect the blue Cloud tiles. Your objective counter updates after each move.',
      'four_match_rocket' =>
        'A straight match of four creates a Rocket. Match it to clear a full row or column.',
      'five_match_prism' =>
        'A straight match of five creates a Prism. Swap it with a tile to clear that family.',
      'crate_one_hit' =>
        'Crates take one hit from an adjacent match or special blast.',
      't_l_cloud_bomb' =>
        'A T or L match creates a Cloud Bomb that clears a 3×3 area.',
      _ => '',
    };

class _BoardCellSemantics extends StatelessWidget {
  const _BoardCellSemantics({
    super.key,
    required this.row,
    required this.col,
    required this.width,
    required this.height,
    required this.piece,
    required this.blocker,
    required this.selected,
    required this.onTap,
  });

  final int row;
  final int col;
  final double width;
  final double height;
  final Piece? piece;
  final BlockerState? blocker;
  final bool selected;
  final VoidCallback onTap;

  String get _label {
    if (blocker != null) {
      final kind =
          blocker!.kind == BlockerKind.crate ? 'crate' : 'reinforced crate';
      return '${blocker!.damaged ? 'damaged ' : ''}$kind, ${blocker!.hp} hit${blocker!.hp == 1 ? '' : 's'} remaining, row ${row + 1}, column ${col + 1}';
    }
    if (piece == null) return 'Empty cell, row ${row + 1}, column ${col + 1}';
    final family = switch (piece!.family) {
      TileFamily.cloud => 'Cloud Puff',
      TileFamily.leaf => 'Mystic Bloom',
      TileFamily.sun => 'Ember Drop',
      TileFamily.moon => 'Dream Crystal',
      TileFamily.star => 'Golden Nugget',
    };
    final special = switch (piece!.special) {
      SpecialKind.rocket => ' Torch special',
      SpecialKind.prism => ' Prism special',
      SpecialKind.cloudBomb => ' Cloud Bomb special',
      null => '',
    };
    final conditions = [
      if (piece!.fogged) 'hidden by Fog',
      if (piece!.stickySyrup) 'stuck in Sticky Syrup',
      if (piece!.special != null) special,
    ];
    return '$family${conditions.isEmpty ? '' : ', ${conditions.join(', ')}'}, row ${row + 1}, column ${col + 1}';
  }

  @override
  Widget build(BuildContext context) => Positioned(
        left: col * width,
        top: row * height,
        width: width,
        height: height,
        child: Semantics(
          container: true,
          button: blocker == null,
          enabled: blocker == null,
          selected: selected,
          label: _label,
          hint: blocker == null
              ? 'Double tap to select this cell, then select a neighboring cell to swap.'
              : 'This blocker cannot be selected.',
          onTap: blocker == null ? onTap : null,
          child: const SizedBox.expand(),
        ),
      );
}

String _loungeAssetKey(String? styleId) => switch (styleId) {
      'psychedelic' => 'room_lounge_psychedelic',
      'retro_70s' => 'room_lounge_retro_70s',
      _ => 'room_lounge',
    };

class ResultsScreen extends StatelessWidget {
  const ResultsScreen(
      {super.key,
      required this.level,
      required this.session,
      required this.progress,
      required this.persist,
      required this.reward,
      required this.offerLounge});
  final LevelSpec level;
  final LevelSession session;
  final ProgressState progress;
  final Future<void> Function() persist;
  final RewardResult? reward;
  final bool offerLounge;

  @override
  Widget build(BuildContext context) {
    final won = session.outcome == LevelOutcome.won;
    final navigator = Navigator.of(context);
    return Scaffold(
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(won ? Icons.celebration : Icons.cloud_off,
                          size: 76,
                          color: won
                              ? const Color(0xffffd36e)
                              : const Color(0xff89b9c8)),
                      const SizedBox(height: 14),
                      Text(won ? 'Clouds cleared!' : 'So close!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Level ${level.id} · score ${session.board.score}'),
                      if (won && reward != null)
                        Text(reward!.firstClear
                            ? '+${reward!.coins} coins · +${reward!.stars} Star · +${reward!.collectionXp} Collection XP${reward!.keys > 0 ? ' · +${reward!.keys} Key' : ''}'
                            : 'Replay complete · no duplicate first-clear reward'),
                      if (won)
                        Text(
                            'Collection XP: ${progress.collectionXp} · Keys: ${progress.keys}'),
                      if (won)
                        Text(
                            'Best score ${reward?.bestScore ?? session.board.score}'),
                      const SizedBox(height: 26),
                      FilledButton(
                          onPressed: () async {
                            navigator.pop();
                            if (offerLounge) {
                              await navigator.push(MaterialPageRoute(
                                  builder: (_) => LoungeScreen(
                                      progress: progress, persist: persist)));
                            }
                          },
                          child: Text(offerLounge
                              ? 'Restore the Lounge'
                              : 'Back to Cloud House')),
                      if (!won)
                        TextButton(
                            onPressed: () {
                              navigator.pop();
                              navigator.push(MaterialPageRoute(
                                  builder: (_) => PlayScreen(
                                      level: level,
                                      progress: progress,
                                      persist: persist)));
                            },
                            child: const Text('Replay Level')),
                    ]))));
  }
}

class LoungeScreen extends StatelessWidget {
  const LoungeScreen(
      {super.key, required this.progress, required this.persist});
  final ProgressState progress;
  final Future<void> Function() persist;
  static const choices = <(String, String)>[
    ('Classic Cloud', 'classic_cloud'),
    ('Psychedelic', 'psychedelic'),
    ('Retro 70s', 'retro_70s'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Lounge Restoration')),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.weekend,
                        size: 68, color: Color(0xffffd36e)),
                    const SizedBox(height: 14),
                    const Text('A room above the clouds',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Choose a look for your restored Lounge.'),
                    const SizedBox(height: 18),
                    ...choices.map((choice) => Padding(
                        padding: const EdgeInsets.all(5),
                        child: FilledButton.tonal(
                          onPressed: () async {
                            progress.loungeStyleId = choice.$2;
                            progress.loungeRestoredFlag = true;
                            await persist();
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48)),
                          child: Text(choice.$1),
                        ))),
                  ]))));
}
