import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:design/core/models/user_profile.dart';
import 'package:design/core/services/auth_service.dart';
import 'package:design/core/services/profile_service.dart';
import '../models/sketch_party_player.dart';
import '../models/sketch_party_state.dart';
import '../services/sketch_party_engine.dart';
import '../widgets/sketch_canvas.dart';
import '../widgets/sketch_lobby_dialog.dart';
import '../widgets/sketch_round_result_modal.dart';
import '../widgets/sketch_scoreboard.dart';
import '../widgets/sketch_toolbar.dart';
import '../widgets/sketch_word_select_modal.dart';

class SketchPartyScreen extends StatefulWidget {
  final SketchPartyEngine? engine;
  final bool autoStart;
  final int totalPlayers;

  const SketchPartyScreen({
    super.key,
    this.engine,
    this.autoStart = false,
    this.totalPlayers = 4,
  });

  @override
  State<SketchPartyScreen> createState() => _SketchPartyScreenState();
}

class _SketchPartyScreenState extends State<SketchPartyScreen> {
  late final SketchPartyEngine _engine;
  late final bool _isExternalEngine;

  String _localUserId = 'player_guest';
  String _localDisplayName = 'You';
  String _localAvatarId = 'avatar_default';

  Color _selectedColor = const Color(0xffffffff);
  double _selectedWidth = 5.0;
  bool _isEraser = false;

  final TextEditingController _guessController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isExternalEngine = widget.engine != null;
    _engine = widget.engine ?? SketchPartyEngine();
    _initUserAndLobby();
  }

  void _initUserAndLobby() {
    final AuthUser? user = AuthService.instance.currentUser;
    _localUserId = user?.uid ?? 'player_local';

    final UserProfile? profile = ProfileService.instance.getProfileSync(_localUserId);
    if (profile != null) {
      _localDisplayName = profile.displayName.isNotEmpty ? profile.displayName : 'Player';
      _localAvatarId = profile.avatarId;
    }

    _engine.initializeRoom(
      localUserId: _localUserId,
      localDisplayName: _localDisplayName,
      localAvatarId: _localAvatarId,
      totalPlayers: widget.totalPlayers,
    );

    if (widget.autoStart) {
      _engine.startMatch();
    }
  }

  @override
  void dispose() {
    _guessController.dispose();
    _chatScrollController.dispose();
    if (!_isExternalEngine) {
      _engine.dispose();
    }
    super.dispose();
  }

  void _submitGuess() {
    final String text = _guessController.text.trim();
    if (text.isEmpty) return;
    _engine.submitGuess(
      text,
      playerId: _localUserId,
      playerName: _localDisplayName,
    );
    _guessController.clear();
    _scrollChatToBottom();
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: const Color(0xff121d38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Leave Match?',
          style: GoogleFonts.fredoka(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Leaving will forfeit your current round points.',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Stay', style: GoogleFonts.outfit(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffef4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Leave', style: GoogleFonts.fredoka(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SketchPartyState>(
      stream: _engine.stateStream,
      initialData: _engine.state,
      builder: (BuildContext context, AsyncSnapshot<SketchPartyState> snapshot) {
        final SketchPartyState state = snapshot.data ?? _engine.state;
        final bool isLocalDrawer = state.isDrawer(_localUserId);
        final SketchPartyPlayer? localPlayer = state.getPlayer(_localUserId);
        final bool localHasGuessed = localPlayer?.hasGuessed ?? false;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            final bool exit = await _showExitConfirmation(context);
            if (exit && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xff090e1c),
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  // Main Game Layout - All cards aligned with 14px margins
                  Column(
                    children: <Widget>[
                      // Card 0: Top Bar with Logo & Round/Timer Card
                      _buildTopBar(state),

                      const SizedBox(height: 8),

                      // Card 1: Player Scores Ribbon Card
                      _buildPlayersRibbon(state),

                      const SizedBox(height: 8),

                      // Middle Card:
                      // 1. If wordSelect phase: show Word Select Card (for drawer) or waiting card (for guesser)
                      // 2. If roundResult phase: show Round Finished Card stretching full width and covering word banner
                      // 3. Otherwise (drawing phase): show Word Banner + Canvas Card!
                      if (state.phase == SketchPartyPhase.wordSelect) ...<Widget>[
                        Expanded(
                          child: isLocalDrawer
                              ? SketchWordSelectModal(
                                  choices: state.wordChoices,
                                  onWordSelected: _engine.selectWord,
                                )
                              : _buildGuesserWordSelectWaitingCard(state),
                        ),
                      ] else if (state.phase == SketchPartyPhase.roundResult) ...<Widget>[
                        Expanded(
                          child: SketchRoundResultModal(
                            word: state.currentWord,
                            players: state.players,
                            drawerName: state.activeDrawer?.displayName ?? 'Drawer',
                            onNextTurn: _engine.nextTurn,
                          ),
                        ),
                      ] else ...<Widget>[
                        // Card 2: Centered "You are drawing" / Word Banner (Points card removed)
                        _buildWordBanner(state, isLocalDrawer),

                        const SizedBox(height: 8),

                        // Card 3: Canvas Card
                        Expanded(
                          child: _buildCanvasCard(state, isLocalDrawer),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Card 4: Brush Toolbar Card (Positioned directly on top of guessing card for drawer)
                      if (isLocalDrawer && state.phase == SketchPartyPhase.drawing) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: SketchToolbar(
                            selectedColor: _selectedColor,
                            selectedWidth: _selectedWidth,
                            isEraser: _isEraser,
                            onColorChanged: (Color c) => setState(() => _selectedColor = c),
                            onWidthChanged: (double w) => setState(() => _selectedWidth = w),
                            onEraserToggled: (bool e) => setState(() => _isEraser = e),
                            onUndo: _engine.undoStroke,
                            onClear: _engine.clearCanvas,
                            canUndo: state.strokes.isNotEmpty,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Card 5: Chat / Live Guess Feed Card (Increased height)
                      _buildChatFeedCard(state, isLocalDrawer, localHasGuessed),

                      const SizedBox(height: 6),
                    ],
                  ),

                  // Overlay Phase Modals
                  if (state.phase == SketchPartyPhase.lobby)
                    SketchLobbyDialog(
                      roomCode: state.roomCode,
                      players: state.players,
                      onPlayerCountChanged: (int count) {
                        _engine.initializeRoom(
                          localUserId: _localUserId,
                          localDisplayName: _localDisplayName,
                          localAvatarId: _localAvatarId,
                          totalPlayers: count,
                        );
                      },
                      onStartMatch: _engine.startMatch,
                      onExit: () => Navigator.of(context).pop(),
                    ),

                  if (state.phase == SketchPartyPhase.gameOver)
                    Positioned.fill(
                      child: SketchScoreboard(
                        players: state.players,
                        localUserId: _localUserId,
                        onPlayAgain: _engine.startMatch,
                        onExit: () => Navigator.of(context).pop(),
                        onViewStats: () => Navigator.of(context).pop(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Card 0: Top Bar with transparent logo and Round/Timer Card on right
  Widget _buildTopBar(SketchPartyState state) {
    final double timerProgress = (state.timeRemaining / (state.turnDuration > 0 ? state.turnDuration : 60)).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Left: Exit icon button + Transparent Sketch Party Logo utilizing space
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final bool exit = await _showExitConfirmation(context);
                      if (exit && mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xff121d33),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xff08abc4).withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 15,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/games/sketch_party_logo.png',
                      height: 46,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Text(
                        'SKETCH PARTY',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: Round & Timer Card matching mock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xff0e1830),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xff08abc4).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xff08abc4).withValues(alpha: 0.15),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Round ${state.currentRound}/${state.totalRounds}',
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.access_time_filled_rounded,
                      size: 14,
                      color: Color(0xff08abc4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '00:${state.timeRemaining.toString().padLeft(2, '0')}',
                      style: GoogleFonts.fredoka(
                        color: state.timeRemaining <= 10 ? const Color(0xffef4444) : Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Glowing Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    width: 90,
                    height: 3.5,
                    child: LinearProgressIndicator(
                      value: timerProgress,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        state.timeRemaining <= 10 ? const Color(0xffef4444) : const Color(0xff08abc4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card 1: Player Scores Ribbon Card
  Widget _buildPlayersRibbon(SketchPartyState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xff0e1830),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: state.players.map((SketchPartyPlayer p) {
            final bool isDrawer = p.id == state.activeDrawerId;
            final bool isSelf = p.id == _localUserId;
            final PlayerAvatar avatar = PlayerAvatar.getById(p.avatarId);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                children: <Widget>[
                  // Avatar with jewel ring & badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.25, -0.35),
                            radius: 0.9,
                            colors: <Color>[
                              avatar.secondaryColor.withValues(alpha: 0.95),
                              avatar.primaryColor,
                            ],
                          ),
                          border: Border.all(
                            color: isDrawer
                                ? const Color(0xfff8df40)
                                : (p.hasGuessed ? const Color(0xff22c55e) : avatar.primaryColor),
                            width: 2,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: (isDrawer ? const Color(0xfff8df40) : avatar.primaryColor)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            p.isBot ? Icons.smart_toy_rounded : avatar.icon,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                      if (p.isHost)
                        Positioned(
                          bottom: -4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                              decoration: BoxDecoration(
                                color: const Color(0xfff8df40),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('👑', style: TextStyle(fontSize: 6.5)),
                            ),
                          ),
                        ),
                      if (p.hasGuessed)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              color: Color(0xff22c55e),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 8, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 7),

                  // Name & Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        isSelf ? 'You' : p.displayName,
                        style: GoogleFonts.outfit(
                          color: isSelf ? const Color(0xfff8df40) : Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${p.totalScore}',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Waiting Card for Guessers while Drawer is picking a word
  Widget _buildGuesserWordSelectWaitingCard(SketchPartyState state) {
    final String drawerName = state.activeDrawer?.displayName ?? 'Drawer';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xff091426),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xff08abc4),
          width: 1.8,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xff08abc4).withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff0e203c),
              border: Border.all(
                color: const Color(0xff08abc4),
                width: 1.6,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xff08abc4).withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.palette_rounded,
                color: Color(0xfff8df40),
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$drawerName is choosing a word...',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Get ready to guess! Turn starts shortly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: const Color(0xff94a3b8),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff08abc4)),
            ),
          ),
        ],
      ),
    );
  }

  /// Card 2: Word Banner (Points card removed, horizontally centered)
  Widget _buildWordBanner(SketchPartyState state, bool isLocalDrawer) {
    final String drawerName = state.activeDrawer?.displayName ?? 'Drawer';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            isLocalDrawer
                ? 'You are drawing'
                : (state.phase == SketchPartyPhase.drawing
                    ? '$drawerName is drawing'
                    : 'Get Ready to Guess!'),
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),

          // Large glowing neon blue pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xff0e2044),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xff08abc4),
                width: 1.6,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xff08abc4).withValues(alpha: 0.4),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              isLocalDrawer
                  ? (state.currentWord?.word.toUpperCase() ?? 'SKETCH')
                  : (state.maskedHint.isNotEmpty ? state.maskedHint : '_ _ _ _ _ _'),
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: isLocalDrawer ? 2.5 : 3.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card 3: Drawing Canvas Card
  Widget _buildCanvasCard(SketchPartyState state, bool isLocalDrawer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xff0e1830),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLocalDrawer
              ? const Color(0xff08abc4).withValues(alpha: 0.7)
              : const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isLocalDrawer
                ? const Color(0xff08abc4).withValues(alpha: 0.25)
                : Colors.black38,
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SketchCanvas(
          strokes: state.strokes,
          onStrokeComplete: isLocalDrawer ? _engine.submitStroke : null,
          currentColor: _selectedColor,
          currentStrokeWidth: _selectedWidth,
          isEraser: _isEraser,
          isInteractive: isLocalDrawer && state.phase == SketchPartyPhase.drawing,
          canvasBackgroundColor: const Color(0xff0b1426),
        ),
      ),
    );
  }

  /// Card 4: In-Game Chat / Live Guess Feed Card
  Widget _buildChatFeedCard(SketchPartyState state, bool isLocalDrawer, bool localHasGuessed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff0e1830),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xff08abc4).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Message stream (increased vertical height for comfortable reading)
          SizedBox(
            height: isLocalDrawer ? 115 : 140,
            child: state.chatMessages.isEmpty
                ? Center(
                    child: Text(
                      isLocalDrawer
                          ? 'Player guesses will appear here live...'
                          : 'Type your guess below!',
                      style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11.5),
                    ),
                  )
                : ListView.builder(
                    controller: _chatScrollController,
                    itemCount: state.chatMessages.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      final SketchChatMessage msg = state.chatMessages[index];
                      final SketchPartyPlayer? sender = state.getPlayer(msg.senderId);
                      final PlayerAvatar avatar = PlayerAvatar.getById(sender?.avatarId);
                      return _buildChatMessageItem(msg, avatar);
                    },
                  ),
          ),

          // Guess Input Field (Visible for guessers who haven't guessed yet)
          if (!isLocalDrawer && state.phase == SketchPartyPhase.drawing) ...<Widget>[
            const SizedBox(height: 6),
            _buildGuessInputField(localHasGuessed),
          ],
        ],
      ),
    );
  }

  Widget _buildChatMessageItem(SketchChatMessage msg, PlayerAvatar avatar) {
    final DateTime time = msg.timestamp;
    final String hour = time.hour > 12 ? '${time.hour - 12}' : '${time.hour == 0 ? 12 : time.hour}';
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.hour >= 12 ? 'PM' : 'AM';
    final String timeStr = '$hour:$minute $period';

    Color bubbleColor = const Color(0xff12203d);
    Color borderColor = Colors.white12;
    Color textColor = Colors.white;

    if (msg.type == ChatMessageType.correctGuess) {
      bubbleColor = const Color(0xff064e3b).withValues(alpha: 0.6);
      borderColor = const Color(0xff10b981).withValues(alpha: 0.6);
      textColor = const Color(0xff34d399);
    } else if (msg.type == ChatMessageType.closeGuess) {
      bubbleColor = const Color(0xff78350f).withValues(alpha: 0.5);
      borderColor = const Color(0xfff59e0b).withValues(alpha: 0.6);
      textColor = const Color(0xfffbbf24);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: <Widget>[
          // Avatar
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatar.primaryColor,
            ),
            child: Center(
              child: Icon(avatar.icon, size: 11, color: Colors.white),
            ),
          ),
          const SizedBox(width: 6),

          // Name
          Text(
            msg.senderName,
            style: GoogleFonts.fredoka(
              color: const Color(0xfff8df40),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),

          // Message Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 0.8),
              ),
              child: Text(
                msg.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Timestamp
          Text(
            timeStr,
            style: GoogleFonts.outfit(
              color: Colors.white30,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessInputField(bool localHasGuessed) {
    if (localHasGuessed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xff10b981).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xff10b981).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.check_circle_rounded, color: Color(0xff34d399), size: 16),
            const SizedBox(width: 6),
            Text(
              'You guessed the secret word correctly!',
              style: GoogleFonts.fredoka(
                color: const Color(0xff34d399),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xff121d38),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xff08abc4).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 10),
                const Icon(Icons.search_rounded, size: 16, color: Colors.white38),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _guessController,
                    textInputAction: TextInputAction.send,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'Type your guess here...',
                      hintStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onSubmitted: (_) => _submitGuess(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _submitGuess,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xff08abc4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Color(0xff0b1328), size: 17),
            ),
          ),
        ),
      ],
    );
  }
}
