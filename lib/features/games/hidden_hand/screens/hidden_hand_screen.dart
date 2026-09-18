import 'package:flutter/material.dart';
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
import '../widgets/voting_overlay.dart';

class HiddenHandScreen extends StatefulWidget {
  const HiddenHandScreen({super.key});

  @override
  State<HiddenHandScreen> createState() => _HiddenHandScreenState();
}

class _HiddenHandScreenState extends State<HiddenHandScreen> {
  late final HiddenHandEngine _engine;
  late final String _localUserId;
  String _localDisplayName = 'Player';
  String _localAvatarId = 'avatar_phoenix';

  Color _selectedColor = const Color(0xffefc249);
  double _selectedWidth = 4.0;
  bool _hideSecretWord = false;
  int _roomPlayerCount = 4;

  @override
  void initState() {
    super.initState();
    _engine = HiddenHandEngine();

    final AuthUser? user = AuthService.instance.currentUser;
    _localUserId = user?.uid ?? 'player_local';

    final UserProfile? profile = ProfileService.instance.getProfileSync(_localUserId);
    if (profile != null) {
      _localDisplayName = profile.displayName.isEmpty ? 'Player' : profile.displayName;
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
                backgroundColor: const Color(0xff232537),
                title: const Text('Leave Hidden Hand?', style: TextStyle(color: Colors.white)),
                content: const Text(
                  'A round is currently in progress. Leaving will forfeit the match.',
                  style: TextStyle(color: Color(0xffa1a0b0)),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('STAY', style: TextStyle(color: Color(0xffefc249))),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('LEAVE', style: TextStyle(color: Color(0xfff87171))),
                  ),
                ],
              ),
            );
            if (shouldExit == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xff161722),
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  // Main Game Layout
                  Column(
                    children: <Widget>[
                      _buildHeader(state, localPlayer),
                      const SizedBox(height: 8),
                      _buildPlayerRibbon(state),
                      const SizedBox(height: 10),

                      // Canvas Area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DrawingCanvasWidget(
                            strokes: state.strokes,
                            isInteractive: isMyTurn,
                            activeColor: _selectedColor,
                            strokeWidth: _selectedWidth,
                            activePlayerId: _localUserId,
                            onStrokeCompleted: (stroke) {
                              _engine.addStroke(stroke);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Bottom Area (Lobby Setup or In-Game Toolbar)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: state.phase == GamePhase.lobby
                            ? _buildLobbyControls(state)
                            : DrawingToolbar(
                                selectedColor: _selectedColor,
                                selectedWidth: _selectedWidth,
                                isInteractive: isMyTurn,
                                onColorSelected: (c) => setState(() => _selectedColor = c),
                                onWidthSelected: (w) => setState(() => _selectedWidth = w),
                                onDoneTurn: () => _engine.endPlayerTurn(_localUserId),
                              ),
                      ),
                    ],
                  ),

                  // Phase Overlays
                  if (state.phase == GamePhase.roleReveal && localPlayer != null)
                    RoleRevealModal(
                      localPlayer: localPlayer,
                      prompt: state.secretPrompt,
                      onDismiss: () => _engine.beginDrawingPhase(),
                    ),

                  if (state.phase == GamePhase.voting)
                    VotingOverlay(
                      state: state,
                      localPlayerId: _localUserId,
                      onCastVote: (target) => _engine.castVote(_localUserId, target),
                    ),

                  if (state.phase == GamePhase.impostorGuess)
                    ImpostorGuessModal(
                      state: state,
                      localPlayerId: _localUserId,
                      onSubmitGuess: (guess) => _engine.submitImpostorGuess(guess),
                    ),

                  if (state.phase == GamePhase.gameOver)
                    GameResultDialog(
                      state: state,
                      localPlayerId: _localUserId,
                      onPlayAgain: () => _engine.startMatch(),
                      onExit: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(HiddenHandState state, HiddenHandPlayer? localPlayer) {
    final bool isImpostor = localPlayer?.isImpostor ?? false;
    final bool inGame = state.phase != GamePhase.lobby;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 16, 0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'HIDDEN HAND',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                state.roomCode,
                style: const TextStyle(color: Color(0xffefc249), fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Spacer(),

          // Secret Word Pill (for Artists) or Impostor Warning (for Impostor)
          if (inGame)
            GestureDetector(
              onTap: () => setState(() => _hideSecretWord = !_hideSecretWord),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isImpostor ? const Color(0xff4c1d34) : const Color(0xff232537),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isImpostor ? const Color(0xfff43f5e) : const Color(0xffefc249),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      isImpostor
                          ? Icons.visibility_off_rounded
                          : (_hideSecretWord ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      size: 15,
                      color: isImpostor ? const Color(0xfff43f5e) : const Color(0xffefc249),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isImpostor
                          ? 'IMPOSTOR'
                          : (_hideSecretWord
                              ? 'PEEK WORD'
                              : '${state.secretPrompt.category}: ${state.secretPrompt.word}'),
                      style: TextStyle(
                        color: isImpostor ? const Color(0xfff43f5e) : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerRibbon(HiddenHandState state) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: state.players.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final HiddenHandPlayer p = state.players[index];
          final bool isTurn = state.phase == GamePhase.drawing && p.id == state.currentTurnPlayerId;
          final bool isSelf = p.id == _localUserId;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isTurn ? const Color(0xff2d2245) : const Color(0xff1e202f),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isTurn
                    ? const Color(0xffefc249)
                    : (p.isEliminated ? Colors.transparent : const Color(0xff333547)),
                width: isTurn ? 2 : 1,
              ),
              boxShadow: isTurn
                  ? <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xffefc249).withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(p.assignedColorValue),
                      child: Text(
                        p.displayName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xff12131c),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (p.isEliminated)
                      const Icon(Icons.close_rounded, color: Colors.red, size: 26),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      p.displayName + (isSelf ? ' (You)' : ''),
                      style: TextStyle(
                        color: p.isEliminated ? Colors.white38 : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        decoration: p.isEliminated ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (isTurn)
                      Row(
                        children: <Widget>[
                          const Icon(Icons.timer_outlined, size: 11, color: Color(0xffefc249)),
                          const SizedBox(width: 3),
                          Text(
                            '${state.turnTimeRemaining}s',
                            style: const TextStyle(
                              color: Color(0xffefc249),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      )
                    else if (p.hasDrawnThisTurn)
                      const Text('Drawn', style: TextStyle(color: Color(0xff10b981), fontSize: 10))
                    else
                      Text(
                        p.isBot ? 'Bot' : 'Player',
                        style: const TextStyle(color: Color(0xff717082), fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLobbyControls(HiddenHandState state) {
    final int impostorCount = _roomPlayerCount <= 5 ? 1 : 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1e202f),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff333547)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.group_rounded, color: Color(0xffefc249), size: 20),
              const SizedBox(width: 8),
              const Text(
                'ROOM SIZE:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff2d2245),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xffefc249)),
                ),
                child: Text(
                  '$_roomPlayerCount Players ($impostorCount ${impostorCount == 1 ? 'Impostor' : 'Impostors'})',
                  style: const TextStyle(
                    color: Color(0xffefc249),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Player count selector buttons: 3, 4, 5, 6, 7, 8
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <int>[3, 4, 5, 6, 7, 8].map((count) {
              final bool isSelected = _roomPlayerCount == count;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: OutlinedButton(
                    onPressed: () => _onPlayerCountChanged(count),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: Size.zero,
                      backgroundColor: isSelected ? const Color(0xffefc249) : Colors.transparent,
                      foregroundColor: isSelected ? const Color(0xff12131c) : Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xffefc249) : const Color(0xff444760),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () => _engine.startMatch(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffefc249),
              foregroundColor: const Color(0xff1c1d2a),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: const Text(
              'START ROUND',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }
}
