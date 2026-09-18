import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/models/user_profile.dart';
import 'core/services/auth_service.dart';
import 'core/services/profile_service.dart';
import 'features/auth/widgets/auth_gate.dart';
import 'features/profile/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthService.instance = FirebaseAuthService();
    ProfileService.instance = FirestoreProfileService();
    debugPrint('=============================================');
    debugPrint('[PlayPal] FIREBASE CONNECTED SUCCESSFULLY!');
    debugPrint('=============================================');
  } catch (e) {
    debugPrint('=============================================');
    debugPrint('[PlayPal] WARNING: Firebase init failed ($e). Using in-memory fallback.');
    debugPrint('=============================================');
  }
  runApp(const PlayPalApp());
}

class PlayPalApp extends StatefulWidget {
  const PlayPalApp({super.key});
  @override
  State<PlayPalApp> createState() => _PlayPalAppState();
}

class _PlayPalAppState extends State<PlayPalApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PlayPal',
        theme: ThemeData(useMaterial3: true, colorScheme: const ColorScheme.dark(primary: Color(0xffe8bd42))),
        home: const AuthGate(child: GameHome()),
      );
}

class GameHome extends StatefulWidget {
  const GameHome({super.key});
  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  final TextEditingController _searchController = TextEditingController();
  late final Future<Map<String, int>> _activePlayers;
  Game? _selectedGame;
  bool _searching = false;
  int _selectedTab = 0;

  final List<Game> _games = const <Game>[
    Game('hidden-hand', 'HIDDEN\nHAND', 'Blend in, find your team, and win.', Icons.front_hand_rounded, Color(0xff37235d), Color(0xff81438f), Color(0xffefc249)),
    Game('casefile', 'CASEFILE', 'Solve a fast-moving case with friends.', Icons.manage_search_rounded, Color(0xff1e345d), Color(0xff9b6031), Color(0xff4178d7)),
    Game('sketch-party', 'SKETCH\nPARTY', 'Draw, guess, and race the clock.', Icons.gesture_rounded, Color(0xff08abc4), Color(0xff2176c7), Color(0xfff4d935)),
    Game('georush', 'GEORUSH', 'Explore the world before time runs out.', Icons.public_rounded, Color(0xff08705c), Color(0xff0c3e46), Color(0xffe4be55)),
    Game('half-half', 'HALF &\nHALF', 'Collaborate to complete the picture.', Icons.contrast_rounded, Color(0xffb26945), Color(0xff2154aa), Color(0xfff4bd4d)),
    Game('match-hup', 'MATCH\nHUP', 'Find the matching pair first.', Icons.favorite_outline_rounded, Color(0xffb96b71), Color(0xff205966), Color(0xffee9e98)),
  ];

  @override
  void initState() {
    super.initState();
    _activePlayers = GameApi.fetchActivePlayers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectGame(Game game) => setState(() {
        _selectedGame = game;
        _searching = false;
        _searchController.clear();
      });

  void _launchGame(Game game) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GameLaunchScreen(game: game)));
  }

  @override
  Widget build(BuildContext context) {
    final String query = _searchController.text.toLowerCase();
    final List<Game> shownGames = _games.where((game) => game.name.replaceAll('\n', ' ').toLowerCase().contains(query)).toList();
    return Scaffold(
      backgroundColor: const Color(0xff1c1d2a),
      body: SafeArea(
        child: Column(children: <Widget>[
          _topBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 100),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                if (!_searching) ...<Widget>[
                  GamePreviewBanner(
                    game: _selectedGame,
                    onQuickJoin: () => _launchGame(_selectedGame ?? _games.first),
                  ),
                  const SizedBox(height: 22),
                  const Text('Dive into the Action', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 15),
                ] else
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: Text('Games matching: ${_searchController.text}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
                FutureBuilder<Map<String, int>>(
                  future: _activePlayers,
                  initialData: const <String, int>{},
                  builder: (context, snapshot) {
                    final Map<String, int> players = snapshot.data ?? const <String, int>{};
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shownGames.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 18, crossAxisSpacing: 16, childAspectRatio: 1.46),
                      itemBuilder: (_, index) {
                        final Game game = shownGames[index];
                        return GameCard(game: game, activePlayers: players[game.id] ?? 0, selected: game.id == _selectedGame?.id, onTap: () => _selectGame(game));
                      },
                    );
                  },
                ),
                if (shownGames.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No games found - try another search.', style: TextStyle(color: Colors.white70)))),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1.4),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _selectedGame == null
                ? const SizedBox.shrink()
                : GameLaunchBar(
                    key: ValueKey<String>(_selectedGame!.id),
                    game: _selectedGame!,
                    onLaunch: () => _launchGame(_selectedGame!),
                  ),
          ),
          _bottomNavigation(),
        ],
      ),
    );
  }

  void _openProfile([UserProfile? profile]) async {
    final String currentUid = AuthService.instance.currentUser?.uid ?? '';
    final UserProfile p = profile ??
        (await ProfileService.instance.getProfile(currentUid)) ??
        UserProfile(
          uid: currentUid.isEmpty ? 'guest' : currentUid,
          displayName: 'Player',
          isGuest: true,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProfileScreen(profile: p),
        ),
      );
    }
  }

  Widget _topBar() {
    final String uid = AuthService.instance.currentUser?.uid ?? '';
    return StreamBuilder<UserProfile?>(
      stream: ProfileService.instance.watchProfile(uid),
      builder: (context, snapshot) {
        final UserProfile? profile = snapshot.data;
        final PlayerAvatar avatar = profile?.avatar ?? PlayerAvatar.presets.first;

        return Padding(
          padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
          child: Row(children: <Widget>[
            GestureDetector(
              onTap: () => _openProfile(profile),
              child: Stack(clipBehavior: Clip.none, children: <Widget>[
                CircleAvatar(
                  radius: 19,
                  backgroundColor: avatar.primaryColor,
                  child: Icon(avatar.icon, color: Colors.white, size: 22),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xff48e38e),
                      border: Border.all(color: const Color(0xff1c1d2a), width: 2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xff262735),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xff56566b)),
                ),
                child: TextField(
                  controller: _searchController,
                  onTap: () => setState(() => _searching = true),
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xffd3d1dc)),
                    suffixIcon: _searching
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => setState(() {
                              _searchController.clear();
                              _searching = false;
                            }),
                          )
                        : null,
                    hintText: profile != null
                        ? 'Hi, ${profile.displayName}! Search games...'
                        : 'Search games or friends...',
                    hintStyle: const TextStyle(color: Color(0xffc1bfca), fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Inbox',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const InboxScreen()),
              ),
              icon: const Icon(Icons.mail_outline_rounded,
                  color: Color(0xffd6d4dd), size: 28),
            ),
          ]),
        );
      },
    );
  }

  Widget _bottomNavigation() {
    final List<IconData> icons = <IconData>[
      Icons.home_rounded,
      Icons.explore_outlined,
      Icons.groups_outlined,
      Icons.person_outline_rounded,
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(13, 0, 13, 8),
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xff363848),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(
            icons.length,
            (int index) => IconButton(
              onPressed: () {
                if (index == 3) {
                  _openProfile();
                } else {
                  setState(() => _selectedTab = index);
                }
              },
              icon: Icon(
                icons[index],
                size: 28,
                color: _selectedTab == index
                    ? const Color(0xfff0c957)
                    : const Color(0xffb4b5c2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GamePreviewBanner extends StatefulWidget {
  const GamePreviewBanner({super.key, required this.game, this.onQuickJoin});
  final Game? game;
  final VoidCallback? onQuickJoin;
  @override
  State<GamePreviewBanner> createState() => _GamePreviewBannerState();
}

class _GamePreviewBannerState extends State<GamePreviewBanner> {
  @override
  Widget build(BuildContext context) {
    final Game? game = widget.game;
    return Container(
      height: 177,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: game == null ? const <Color>[Color(0xff24184e), Color(0xff522093), Color(0xff177eca)] : <Color>[game.a, game.b], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Stack(children: <Widget>[
        Positioned(right: 5, top: 3, child: Icon(game?.icon ?? Icons.sports_esports_rounded, size: 120, color: Colors.white24)),
        Text(game?.name ?? 'Bored?\nNot for long.', style: const TextStyle(fontSize: 26, height: .95, color: Colors.white, fontWeight: FontWeight.w900)),
        Positioned(top: 61, left: 0, right: 85, child: Text(game?.description ?? 'Jump into a 5-minute match\nright now!', style: const TextStyle(color: Color(0xffe6dff4), fontSize: 12))),
        Positioned(
          bottom: 0,
          left: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onQuickJoin,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xffefc249),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'QUICK JOIN NOW',
                  style: TextStyle(
                    color: Color(0xff1c1d2a),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class GameLaunchBar extends StatefulWidget {
  const GameLaunchBar({super.key, required this.game, required this.onLaunch});

  final Game game;
  final VoidCallback onLaunch;

  @override
  State<GameLaunchBar> createState() => _GameLaunchBarState();
}

class _GameLaunchBarState extends State<GameLaunchBar> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 8),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 130),
        scale: _pressed ? .96 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              setState(() => _pressed = false);
              widget.onLaunch();
            },
            borderRadius: BorderRadius.circular(15),
            child: Ink(
              height: 53,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[widget.game.a, widget.game.b],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: widget.game.accent, width: 1.3),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: widget.game.accent.withValues(alpha: .35), blurRadius: 18, spreadRadius: 1),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 7),
                  const Text('LAUNCH GAME', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameCard extends StatefulWidget {
  const GameCard({super.key, required this.game, required this.activePlayers, required this.selected, required this.onTap});
  final Game game;
  final int activePlayers;
  final bool selected;
  final VoidCallback onTap;
  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), gradient: LinearGradient(colors: <Color>[widget.game.a, widget.game.b]), border: Border.all(color: widget.selected ? Colors.white : widget.game.accent, width: widget.selected ? 2.5 : 1.5)),
          child: Stack(children: <Widget>[
            Positioned(right: 8, bottom: 12, child: Icon(widget.game.icon, size: 53, color: widget.game.accent.withValues(alpha: .85))),
            Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(widget.game.name, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, height: .92)), const Spacer(), Text('${widget.activePlayers} active', style: const TextStyle(color: Color(0xffe6e5eb), fontSize: 12))])),
          ]),
        ),
      );
}

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<String> _messages = <String>['Maya invited you to Sketch Party.', 'Your Casefile match is ready.', 'Sam reacted to your Hidden Hand win.'];
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xff1c1d2a), appBar: AppBar(title: const Text('Inbox'), backgroundColor: const Color(0xff1c1d2a), foregroundColor: Colors.white), body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: _messages.length, separatorBuilder: (_, _) => const Divider(color: Color(0xff3c3d4b)), itemBuilder: (_, index) => ListTile(leading: const CircleAvatar(backgroundColor: Color(0xff7062b5), child: Icon(Icons.person, color: Colors.white)), title: Text(_messages[index], style: const TextStyle(color: Colors.white)), subtitle: const Text('Just now', style: TextStyle(color: Colors.white54)))));
}

class GameLaunchScreen extends StatefulWidget {
  const GameLaunchScreen({super.key, required this.game});
  final Game game;
  @override
  State<GameLaunchScreen> createState() => _GameLaunchScreenState();
}

class _GameLaunchScreenState extends State<GameLaunchScreen> {
  bool _launching = true;
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 1), () { if (mounted) setState(() => _launching = false); });
  }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: widget.game.a, appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white), body: Center(child: _launching ? const CircularProgressIndicator(color: Colors.white) : Column(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(widget.game.icon, color: widget.game.accent, size: 90), const SizedBox(height: 18), Text('${widget.game.name.replaceAll('\n', ' ')} is ready!', style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('Your game session has started.', style: TextStyle(color: Colors.white70))])));
}

class Game {
  const Game(this.id, this.name, this.description, this.icon, this.a, this.b, this.accent);
  final String id, name, description;
  final IconData icon;
  final Color a, b, accent;
}

class GameApi {
  static Future<Map<String, int>> fetchActivePlayers() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return const <String, int>{'hidden-hand': 1542, 'casefile': 950, 'sketch-party': 2801, 'georush': 720, 'half-half': 1104, 'match-hup': 450};
  }
}
