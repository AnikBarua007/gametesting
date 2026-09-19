import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/models/user_profile.dart';
import 'core/services/auth_service.dart';
import 'core/services/profile_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/widgets/auth_gate.dart';
import 'features/games/hidden_hand/screens/hidden_hand_screen.dart';
import 'features/games/hidden_hand/widgets/thematic_components.dart';
import 'features/games/georush/screens/georush_screen.dart';
import 'features/games/half_and_half/screens/half_and_half_screen.dart';
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
    Game('hidden-hand', 'HIDDEN\nHAND', 'Draw your part. Unmask the fake artist.', Icons.front_hand_rounded, Color(0xff37235d), Color(0xff81438f), Color(0xffefc249)),
    Game('casefile', 'CASEFILE', 'Solve a fast-moving case with friends.', Icons.manage_search_rounded, Color(0xff1e345d), Color(0xff9b6031), Color(0xff4178d7)),
    Game('sketch-party', 'SKETCH\nPARTY', 'Draw, guess, and race the clock.', Icons.gesture_rounded, Color(0xff08abc4), Color(0xff2176c7), Color(0xfff4d935)),
    Game('georush', 'GEORUSH', 'Explore the world before time runs out.', Icons.public_rounded, Color(0xff08705c), Color(0xff0c3e46), Color(0xffe4be55)),
    Game('half-half', 'HALF &\nHALF', 'Collaborate to complete the picture.', Icons.back_hand_rounded, Color(0xff4a3272), Color(0xff6b47a4), Color(0xffc4b5fd)),
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
    if (game.id == 'hidden-hand') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const HiddenHandScreen()),
      );
      return;
    }
    if (game.id == 'georush') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const GeoRushScreen()),
      );
      return;
    }
    if (game.id == 'half-half') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const HalfAndHalfScreen()),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GameLaunchScreen(game: game)),
    );
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
    final bool isHiddenHand = game?.id == 'hidden-hand';
    final bool isHalfHalf = game?.id == 'half-half';

    return Container(
      height: 188,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHiddenHand
              ? HiddenHandTheme.gold.withValues(alpha: 0.8)
              : (isHalfHalf
                  ? const Color(0xffc4b5fd).withValues(alpha: 0.8)
                  : (game?.accent ?? const Color(0xff81438f)).withValues(alpha: 0.6)),
          width: (isHiddenHand || isHalfHalf) ? 1.8 : 1.2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isHiddenHand
                ? HiddenHandTheme.gold.withValues(alpha: 0.25)
                : (isHalfHalf
                    ? const Color(0xffa78bfa).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.35)),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Background Layer
            if (isHiddenHand) ...<Widget>[
              // Rich Royal Purple / Amethyst Base Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xff241344),
                      Color(0xff451a66),
                      Color(0xff612275),
                      Color(0xff2b1348),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Thematic Detective Study Texture (Semi-transparent overlay aligned to top lamp)
              Opacity(
                opacity: 0.30,
                child: Image.asset(
                  'assets/images/games/hidden_hand_bg.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              // Warm Candlelight / Desk Lamp Radial Glow on the Right
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.85, -0.45),
                    radius: 1.1,
                    colors: <Color>[
                      HiddenHandTheme.gold.withValues(alpha: 0.36),
                      HiddenHandTheme.gold.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // High-res Custom Illustrated Artwork on the Right
              Positioned(
                right: -2,
                top: 8,
                bottom: 8,
                child: Image.asset(
                  'assets/images/games/hh_bg.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.front_hand_rounded,
                    size: 110,
                    color: HiddenHandTheme.gold.withValues(alpha: 0.22),
                  ),
                ),
              ),
            ] else if (isHalfHalf) ...<Widget>[
              // Full Background Hand Illustration across the entire preview card
              Positioned.fill(
                child: Image.asset(
                  'assets/images/games/half_half_banner.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, _, _) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[Color(0xff1f1236), Color(0xff452273)],
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient overlay ensuring text and CTA button are sharp and readable
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        const Color(0xff160b29).withValues(alpha: 0.94),
                        const Color(0xff160b29).withValues(alpha: 0.82),
                        const Color(0xff160b29).withValues(alpha: 0.38),
                        const Color(0xff160b29).withValues(alpha: 0.12),
                      ],
                      stops: const <double>[0.0, 0.38, 0.70, 1.0],
                    ),
                  ),
                ),
              ),
            ] else ...<Widget>[
              // Generic Gradient for Other Games
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: game == null
                        ? const <Color>[Color(0xff24184e), Color(0xff522093), Color(0xff177eca)]
                        : <Color>[game.a, game.b],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                right: 5,
                top: 3,
                child: Icon(
                  game?.icon ?? Icons.sports_esports_rounded,
                  size: 120,
                  color: Colors.white24,
                ),
              ),
            ],

            // Content Foreground
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (isHiddenHand) ...<Widget>[
                    Image.asset(
                      'assets/images/games/hidden_hand_logo.png',
                      height: 26,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Text(
                        'HIDDEN HAND',
                        style: GoogleFonts.cinzelDecorative(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xff121528).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: HiddenHandTheme.gold.withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.auto_awesome_rounded, size: 10, color: HiddenHandTheme.gold),
                          const SizedBox(width: 4),
                          Text(
                            'FEATURED',
                            style: GoogleFonts.cinzel(
                              color: HiddenHandTheme.gold,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (isHalfHalf) ...<Widget>[
                    const Text(
                      'HALF & HALF',
                      style: TextStyle(
                        fontSize: 24,
                        height: .95,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xff160d26).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xffc4b5fd).withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.back_hand_rounded, size: 10, color: Color(0xffc4b5fd)),
                          SizedBox(width: 4),
                          Text(
                            '1.1k COLLABORATING',
                            style: TextStyle(
                              color: Color(0xffc4b5fd),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Text(
                      game?.name ?? 'Bored?\nNot for long.',
                      style: const TextStyle(
                        fontSize: 26,
                        height: .95,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(maxWidth: (isHiddenHand || isHalfHalf) ? 165 : 240),
                    child: Text(
                      isHalfHalf
                          ? 'Draw your half. Merge and have fun with friends!'
                          : (game?.description ??
                              (isHiddenHand
                                  ? 'Draw your part. Unmask the fake artist.'
                                  : 'Jump into a 5-minute match\nright now!')),
                      style: const TextStyle(
                        color: Color(0xfff1f5f9),
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Bottom Action: CTA Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onQuickJoin,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isHalfHalf
                                ? const <Color>[Color(0xffa78bfa), Color(0xff7c3aed)]
                                : const <Color>[Color(0xffefc249), Color(0xffd9a527)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: (isHalfHalf
                                      ? const Color(0xff7c3aed)
                                      : const Color(0xffefc249))
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.play_arrow_rounded,
                                size: 16,
                                color: isHalfHalf ? Colors.white : const Color(0xff1c1d2a)),
                            const SizedBox(width: 4),
                            Text(
                              'QUICK JOIN NOW',
                              style: TextStyle(
                                color: isHalfHalf ? Colors.white : const Color(0xff1c1d2a),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
  Widget build(BuildContext context) {
    final bool isHiddenHand = widget.game.id == 'hidden-hand';
    final bool isHalfHalf = widget.game.id == 'half-half';

    if (isHalfHalf) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xffa78bfa)
                  : const Color(0xff58298c).withValues(alpha: 0.7),
              width: widget.selected ? 2.4 : 1.4,
            ),
            boxShadow: widget.selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xff8b5cf6).withValues(alpha: 0.45),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: _buildHalfAndHalfModernCard(widget.activePlayers),
          ),
        ),
      );
    }

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.selected
                ? (isHiddenHand ? HiddenHandTheme.gold : Colors.white)
                : (isHiddenHand ? HiddenHandTheme.gold.withValues(alpha: 0.6) : widget.game.accent),
            width: widget.selected ? 2.4 : 1.4,
          ),
          boxShadow: widget.selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: (isHiddenHand ? HiddenHandTheme.gold : widget.game.accent).withValues(alpha: 0.38),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Background
              if (isHiddenHand) ...<Widget>[
                // Rich Royal Purple to Deep Amethyst Gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xff2d174d),
                        Color(0xff4a1b66),
                        Color(0xff6e2a7a),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Subtle study texture overlay
                Opacity(
                  opacity: 0.24,
                  child: Image.asset(
                    'assets/images/games/hidden_hand_bg.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                // Warm ambient glow in the top-right
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.9, -0.6),
                      radius: 0.8,
                      colors: <Color>[
                        HiddenHandTheme.gold.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Custom Illustrated Artwork (Easel & Drawing Hand)
                Positioned(
                  right: -4,
                  bottom: -2,
                  child: Image.asset(
                    'assets/images/games/hh_bg.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.front_hand_rounded,
                      size: 53,
                      color: HiddenHandTheme.gold.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ] else ...<Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[widget.game.a, widget.game.b],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 12,
                  child: Icon(
                    widget.game.icon,
                    size: 53,
                    color: widget.game.accent.withValues(alpha: .85),
                  ),
                ),
              ],

              // Card Text Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.game.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: .92,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xff10b981),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: const Color(0xff10b981).withValues(alpha: 0.7),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${widget.activePlayers} active',
                          style: const TextStyle(
                            color: Color(0xffe6e5eb),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildHalfAndHalfModernCard(int activePlayers) {
    final String playerText = activePlayers >= 1000
        ? '${(activePlayers / 1000).toStringAsFixed(1)}k'
        : '$activePlayers';

    return Column(
      children: <Widget>[
        // Top 63%: Studio Desk Illustration with drawing hands and papers
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Desk backdrop
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xff2b1a45), Color(0xff3f2663)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Crop image to top visual drawing area
              Positioned.fill(
                bottom: -16,
                child: Image.asset(
                  'assets/images/games/half_half_card.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, _, _) => _buildFallbackDoodleCanvas(),
                ),
              ),
              // Subtle top glass sheen
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 18,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom 37%: Modern Native Status Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: const BoxDecoration(
            color: Color(0xff4a3c61),
            border: Border(
              top: BorderSide(color: Color(0xff675683), width: 1.0),
            ),
          ),
          child: Row(
            children: <Widget>[
              // Squircle Lavender High-Five Icon Container
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xff9484b3),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.back_hand_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),

              const SizedBox(width: 8),

              // Title & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'HALF & HALF',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2.5),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 5.5,
                          height: 5.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xff22c55e),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: const Color(0xff22c55e).withValues(alpha: 0.8),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$playerText Collaborating',
                          style: const TextStyle(
                            color: Color(0xffdcd4eb),
                            fontSize: 9.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackDoodleCanvas() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xff2b1a45), Color(0xff4a2d75)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.gesture_rounded, color: Color(0xffc4b5fd), size: 36),
      ),
    );
  }
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
