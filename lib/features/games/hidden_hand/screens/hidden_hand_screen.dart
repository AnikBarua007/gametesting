import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:design/core/models/user_profile.dart';
import 'package:design/core/services/auth_service.dart';
import 'package:design/core/services/profile_service.dart';
import '../models/hidden_hand_player.dart';
import '../models/hidden_hand_state.dart';
import '../services/hidden_hand_engine.dart';
import '../widgets/drawing_canvas_widget.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/impostor_guess_modal.dart';
import '../widgets/role_reveal_modal.dart';
import '../widgets/thematic_components.dart';
import '../widgets/voting_overlay.dart';

class HiddenHandScreen extends StatefulWidget {
  const HiddenHandScreen({super.key});

  @override
  State<HiddenHandScreen> createState() => _HiddenHandScreenState();
}

class _HiddenHandScreenState extends State<HiddenHandScreen> {
  late final HiddenHandEngine _engine;
  late final String _localUserId;
  String _localDisplayName = 'ssavi';
  String _localAvatarId = 'avatar_phoenix';

  Color _selectedColor = const Color(0xffffffff);
  double _selectedWidth = 4.0;
  bool _hideSecretWord = false;
  int _roomPlayerCount = 4;
  int _activeNavTab = 0;

  @override
  void initState() {
    super.initState();
    _engine = HiddenHandEngine();

    final AuthUser? user = AuthService.instance.currentUser;
    _localUserId = user?.uid ?? 'player_local';

    final UserProfile? profile = ProfileService.instance.getProfileSync(_localUserId);
    if (profile != null) {
      _localDisplayName = profile.displayName.isEmpty ? 'ssavi' : profile.displayName;
      _localAvatarId = profile.avatarId;
    }

    _engine.initializeRoom(
      localUserId: _localUserId,
      localDisplayName: _localDisplayName,
      localAvatarId: _localAvatarId,
      playerCount: _roomPlayerCount,
    );
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  void _onPlayerCountChanged(int count) {
    setState(() => _roomPlayerCount = count);
    _engine.initializeRoom(
      localUserId: _localUserId,
      localDisplayName: _localDisplayName,
      localAvatarId: _localAvatarId,
      playerCount: count,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HiddenHandState>(
      stream: _engine.stateStream,
      initialData: _engine.state,
      builder: (context, snapshot) {
        final HiddenHandState state = snapshot.data ?? _engine.state;
        final HiddenHandPlayer? localPlayer = state.getPlayer(_localUserId);
        final bool isMyTurn = state.phase == GamePhase.drawing &&
            state.currentTurnPlayerId == _localUserId &&
            !(localPlayer?.isEliminated ?? false);

        return PopScope(
          canPop: state.phase == GamePhase.lobby || state.phase == GamePhase.gameOver,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final bool? shouldExit = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xff16192c),
                title: Text(
                  'Leave Hidden Hand?',
                  style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                content: const Text(
                  'A round is currently in progress. Leaving will forfeit the match.',
                  style: TextStyle(color: Color(0xff94a3b8)),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('STAY', style: GoogleFonts.cinzel(color: HiddenHandTheme.gold, fontWeight: FontWeight.w800)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text('LEAVE', style: GoogleFonts.cinzel(color: const Color(0xfff87171), fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            );
            if (shouldExit == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xff090b14),
            body: Stack(
              children: <Widget>[
                // Layer 0: Atmospheric Detective Study Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/games/hidden_hand_bg.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xff0e101d),
                    ),
                  ),
                ),

                // Layer 1: Radial Lamp Glow & Subtle Vignette
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.7, -0.8), // Lamp position at top-right
                        radius: 1.3,
                        colors: <Color>[
                          Colors.transparent, // Preserve warm lamp glow!
                          const Color(0xff070913).withValues(alpha: 0.38),
                          const Color(0xff070913).withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                ),

                // Layer 2: Main Game Layout
                SafeArea(
                  child: Column(
                    children: <Widget>[
                      // Header Logo & Room Info Bar
                      _buildHeader(state, localPlayer),
                      const SizedBox(height: 6),

                      // Elevated Player Cards Ribbon
                      _buildPlayerRibbon(state),

                      // Turn Banner (In-game only)
                      if (state.phase == GamePhase.drawing) ...<Widget>[
                        const SizedBox(height: 5),
                        _buildActiveArtistBanner(state, localPlayer),
                      ],

                      const SizedBox(height: 5),

                      // Main Canvas Area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: DrawingCanvasWidget(
                            strokes: state.strokes,
                            isInteractive: isMyTurn,
                            activeColor: _selectedColor,
                            strokeWidth: _selectedWidth,
                            activePlayerId: _localUserId,
                            glowColor: state.currentTurnPlayer != null
                                ? Color(state.currentTurnPlayer!.assignedColorValue)
                                : null,
                            artistName: state.currentTurnPlayer?.displayName,
                            showStickyNotes: true,
                            showMaskWatermark: state.phase == GamePhase.lobby || state.strokes.isEmpty,
                            onStrokeCompleted: (stroke) {
                              _engine.addStroke(stroke);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Bottom Area: Lobby Controls or Drawing Toolbar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: state.phase == GamePhase.lobby
                            ? _buildLobbyControls(state)
                            : DrawingToolbar(
                                selectedColor: _selectedColor,
                                selectedWidth: _selectedWidth,
                                isInteractive: isMyTurn,
                                submitLabel: 'DONE',
                                onColorSelected: (c) => setState(() => _selectedColor = c),
                                onWidthSelected: (w) => setState(() => _selectedWidth = w),
                                onDoneTurn: () => _engine.endPlayerTurn(_localUserId),
                              ),
                      ),

                      // Bottom Navigation Bar (In-game)
                      if (state.phase != GamePhase.lobby)
                        BottomNavBar(
                          activeIndex: state.phase == GamePhase.voting ? 2 : _activeNavTab,
                          onTabChanged: (index) {
                            setState(() => _activeNavTab = index);
                            if (index == 2 && state.phase == GamePhase.drawing) {
                              _engine.callEmergencyVote();
                            }
                          },
                        ),
                    ],
                  ),
                ),

                // Phase Overlays
                if (state.phase == GamePhase.roleReveal && localPlayer != null)
                  Positioned.fill(
                    child: RoleRevealModal(
                      localPlayer: localPlayer,
                      prompt: state.secretPrompt,
                      players: state.players,
                      onDismiss: () => _engine.beginDrawingPhase(),
                    ),
                  ),

                if (state.phase == GamePhase.voting)
                  Positioned.fill(
                    child: VotingOverlay(
                      state: state,
                      localPlayerId: _localUserId,
                      onCastVote: (target) => _engine.castVote(_localUserId, target),
                      onSkipVote: () => _engine.castVote(_localUserId, 'SKIP'),
                    ),
                  ),

                if (state.phase == GamePhase.impostorGuess)
                  Positioned.fill(
                    child: ImpostorGuessModal(
                      state: state,
                      localPlayerId: _localUserId,
                      onSubmitGuess: (guess) => _engine.submitImpostorGuess(guess),
                    ),
                  ),

                if (state.phase == GamePhase.gameOver)
                  Positioned.fill(
                    child: GameResultDialog(
                      state: state,
                      localPlayerId: _localUserId,
                      onPlayAgain: () => _engine.startMatch(),
                      onExit: () => Navigator.of(context).pop(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Header Logo & Multi-segment Glass Info Bar
  Widget _buildHeader(HiddenHandState state, HiddenHandPlayer? localPlayer) {
    final bool isImpostor = localPlayer?.isImpostor ?? false;
    final bool inGame = state.phase != GamePhase.lobby;
    final int impostorCount = state.players.length <= 5 ? 1 : 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Top Title Row with Authentic Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const Opacity(
                    opacity: 0.0,
                    child: Text(
                      'HIDDEN HAND',
                      style: TextStyle(fontSize: 1),
                    ),
                  ),
                  Image.asset(
                    'assets/images/games/hidden_hand_logo.png',
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(width: 36), // Balance back button
            ],
          ),
          const SizedBox(height: 3),

          // Multi-segment Glass Info Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xd9101326),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xff2d3250), width: 1.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                // Segment 1: Room Code
                const Icon(Icons.auto_awesome_rounded, size: 14, color: HiddenHandTheme.cyanAccent),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'ROOM CODE',
                      style: TextStyle(color: Color(0xff64748b), fontSize: 8, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      state.roomCode,
                      style: GoogleFonts.cinzel(
                        color: HiddenHandTheme.gold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: state.roomCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Room code copied!'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.copy_rounded, size: 12, color: Color(0xff94a3b8)),
                  ),
                ),

                const SizedBox(width: 4),
                Container(width: 1, height: 20, color: const Color(0xff262b45)),
                const SizedBox(width: 6),

                // Segment 2: Category & Word
                const Icon(Icons.category_rounded, size: 13, color: HiddenHandTheme.cyanAccent),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'CATEGORY',
                        style: TextStyle(color: Color(0xff64748b), fontSize: 8, fontWeight: FontWeight.w800),
                      ),
                      GestureDetector(
                        onTap: inGame ? () => setState(() => _hideSecretWord = !_hideSecretWord) : null,
                        child: Text(
                          inGame
                              ? (isImpostor
                                  ? 'Impostor'
                                  : (_hideSecretWord
                                      ? 'Peek'
                                      : '${state.secretPrompt.category}: ${state.secretPrompt.word}'))
                              : 'Objects',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isImpostor ? HiddenHandTheme.redAccent : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),
                Container(width: 1, height: 20, color: const Color(0xff262b45)),
                const SizedBox(width: 6),

                // Segment 3: Impostor Info
                Icon(
                  Icons.theater_comedy_rounded,
                  size: 14,
                  color: isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold,
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${state.players.length}P • $impostorCount Impostor',
                      style: TextStyle(
                        color: isImpostor ? HiddenHandTheme.redAccent : HiddenHandTheme.gold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'One draws differently',
                      style: TextStyle(color: Color(0xff64748b), fontSize: 7.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlayerAvatarIcon(HiddenHandPlayer player, int index) {
    if (player.avatarId.isNotEmpty) {
      final PlayerAvatar preset = PlayerAvatar.getById(player.avatarId);
      if (preset.id != 'avatar_phoenix' || player.avatarId == 'avatar_phoenix') {
        return preset.icon;
      }
    }
    const List<IconData> icons = <IconData>[
      Icons.military_tech_rounded,         // Monarch / Host
      Icons.sports_esports_rounded,        // Nova (Cyber)
      Icons.auto_awesome_rounded,          // Pixel (Magic/Stars)
      Icons.shield_moon_rounded,           // Viper (Night Shield)
      Icons.radar_rounded,                 // Echo (Radar)
      Icons.local_fire_department_rounded, // Blaze (Fire)
      Icons.public_rounded,                // Atlas (World)
      Icons.lock_rounded,                  // Cipher (Key)
    ];
    return icons[index % icons.length];
  }

  // Compact Elevated Player Cards Ribbon (Horizontally Centered for 3-4 players, scrollable if overflowing)
  Widget _buildPlayerRibbon(HiddenHandState state) {
    final int displayItemCount = state.phase == GamePhase.lobby && state.players.length < 8
        ? state.players.length + 1
        : state.players.length;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final List<Widget> cardWidgets = <Widget>[
            for (int i = 0; i < displayItemCount; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 8),
              if (i == state.players.length)
                _buildInviteCard()
              else
                _buildPlayerCard(state.players[i], i, state),
            ],
          ];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: cardWidgets,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerCard(HiddenHandPlayer p, int index, HiddenHandState state) {
    final bool isTurn = state.phase == GamePhase.drawing && p.id == state.currentTurnPlayerId;
    final bool isSelf = p.id == _localUserId;
    final Color pColor = Color(p.assignedColorValue);

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(
        color: isTurn
            ? const Color(0xff2a2210)
            : const Color(0xcc121528),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isTurn
              ? HiddenHandTheme.gold
              : (isSelf ? HiddenHandTheme.gold.withValues(alpha: 0.85) : pColor.withValues(alpha: 0.7)),
          width: isTurn ? 2.0 : 1.2,
        ),
        boxShadow: isTurn
            ? <BoxShadow>[
                BoxShadow(
                  color: HiddenHandTheme.gold.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Crystal Jewel Avatar with Custom Profile Icon
            JewelAvatarWidget(
              icon: _getPlayerAvatarIcon(p, index),
              color: pColor,
              isHost: false,
              isEliminated: p.isEliminated,
              size: 24,
            ),
            const SizedBox(height: 2),

            // Player Name
            Text(
              p.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cinzel(
                color: isTurn ? HiddenHandTheme.gold : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 8.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Invite Player Card (Dotted Border, Compact)
  Widget _buildInviteCard() {
    return InkWell(
      onTap: () {
        if (_roomPlayerCount < 8) {
          _onPlayerCountChanged(_roomPlayerCount + 1);
        }
      },
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0x3316192c),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xff374151), width: 1.2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xff22273f),
                child: Icon(Icons.add_rounded, color: Color(0xff94a3b8), size: 15),
              ),
              const SizedBox(height: 2),
              Text(
                'Invite',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(color: const Color(0xff94a3b8), fontSize: 8.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Active Artist Turn Banner
  Widget _buildActiveArtistBanner(HiddenHandState state, HiddenHandPlayer? localPlayer) {
    final HiddenHandPlayer? current = state.currentTurnPlayer;
    if (current == null) return const SizedBox.shrink();

    final bool isMyTurn = current.id == _localUserId;
    final Color playerColor = Color(current.assignedColorValue);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xeb101326),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMyTurn ? HiddenHandTheme.gold : const Color(0xff2d3148),
          width: 1.2,
        ),
        boxShadow: isMyTurn
            ? <BoxShadow>[
                BoxShadow(
                  color: HiddenHandTheme.gold.withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          // Round Progress Indicator: ROUND 1/4 (dots)
          RoundDotIndicator(
            currentRound: state.roundNumber,
            totalRounds: 4,
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: const Color(0xff262b45)),
          const SizedBox(width: 8),

          // Center Turn Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  isMyTurn
                      ? 'YOUR TURN TO DRAW'
                      : '${current.displayName.toUpperCase()} DRAWING',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(
                    color: isMyTurn ? HiddenHandTheme.gold : playerColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isMyTurn
                      ? (localPlayer?.isImpostor == true
                          ? 'Blend in! Sketch a plausible line.'
                          : 'Sketch one part of: ${state.secretPrompt.word}')
                      : (current.isBot ? 'AI artist adding a stroke...' : 'Collaborative drawing in progress...'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isMyTurn ? const Color(0xfffde68a) : const Color(0xff94a3b8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(width: 1, height: 24, color: const Color(0xff262b45)),
          const SizedBox(width: 8),

          // Circular Countdown Timer Ring
          TimerRingWidget(
            secondsRemaining: state.turnTimeRemaining,
            totalSeconds: 15,
            size: 40,
          ),
        ],
      ),
    );
  }

  // Lobby Controls & Start Button
  Widget _buildLobbyControls(HiddenHandState state) {
    final int impostorCount = _roomPlayerCount <= 5 ? 1 : 2;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xeb101326),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xff2c314d)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header Row: ROOM SIZE: | 4 Players • 1 Impostor
          Row(
            children: <Widget>[
              const Icon(Icons.group_rounded, color: HiddenHandTheme.gold, size: 18),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'ROOM SIZE:',
                    style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.5),
                  ),
                  const Text(
                    'Choose total players',
                    style: TextStyle(color: Color(0xff94a3b8), fontSize: 8.5),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff181c34),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: HiddenHandTheme.gold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.theater_comedy_rounded, size: 12, color: HiddenHandTheme.gold),
                    const SizedBox(width: 4),
                    Text(
                      '$_roomPlayerCount Players • $impostorCount ${impostorCount == 1 ? 'Impostor' : 'Impostors'}',
                      style: GoogleFonts.cinzel(
                        color: HiddenHandTheme.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Player Count Selector Buttons: 3, 4, 5, 6, 7, 8
          Row(
            children: <int>[3, 4, 5, 6, 7, 8].map((count) {
              final bool isSelected = _roomPlayerCount == count;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => _onPlayerCountChanged(count),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? HiddenHandTheme.goldGradient : null,
                        color: isSelected ? null : const Color(0xff16192c),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? HiddenHandTheme.gold : const Color(0xff2d3356),
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: HiddenHandTheme.gold.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: GoogleFonts.cinzel(
                            color: isSelected ? const Color(0xff12131c) : Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Large START ROUND Golden CTA Button
          GoldenCtaButton(
            height: 48,
            onPressed: () => _engine.startMatch(),
            icon: Icons.play_arrow_rounded,
            label: 'START ROUND',
          ),
        ],
      ),
    );
  }
}
