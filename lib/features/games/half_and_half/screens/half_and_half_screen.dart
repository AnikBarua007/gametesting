import 'package:flutter/material.dart';
import 'package:design/core/models/user_profile.dart';
import 'package:design/core/services/auth_service.dart';
import 'package:design/core/services/profile_service.dart';
import '../models/half_and_half_drawing.dart';
import '../models/half_and_half_state.dart';
import '../services/half_and_half_engine.dart';
import '../widgets/half_and_half_canvas.dart';
import '../widgets/half_and_half_theme.dart';
import '../widgets/half_and_half_toolbar.dart';
import '../widgets/half_lobby_dialog.dart';
import '../widgets/memorize_phase_widget.dart';
import '../widgets/merged_reveal_widget.dart';

class HalfAndHalfScreen extends StatefulWidget {
  const HalfAndHalfScreen({super.key});

  @override
  State<HalfAndHalfScreen> createState() => _HalfAndHalfScreenState();
}

class _HalfAndHalfScreenState extends State<HalfAndHalfScreen> {
  late final HalfAndHalfEngine _engine;
  String _displayName = 'Player';
  String _avatarId = 'avatar_phoenix';
  String _localUserId = 'user_local';

  Color _selectedColor = const Color(0xff1e1b2e);
  double _selectedWidth = 3.5;
  bool _isEraser = false;

  @override
  void initState() {
    super.initState();
    _engine = HalfAndHalfEngine();
    _loadUser();

    // Auto-open lobby matchmaking selection on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLobbyDialog();
    });
  }

  void _loadUser() {
    final AuthUser? user = AuthService.instance.currentUser;
    if (user != null) {
      _localUserId = user.uid;
      final UserProfile? profile = ProfileService.instance.getProfileSync(user.uid);
      if (profile != null) {
        setState(() {
          _displayName = profile.displayName.isNotEmpty ? profile.displayName : 'Player';
          _avatarId = profile.avatarId;
        });
      }
    }
  }

  void _showLobbyDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => HalfLobbyDialog(
        onStartMatch: ({required HalfAndHalfRole role, required bool isSoloWithBot, String? roomCode}) {
          _engine.startMatch(
            localUserId: _localUserId,
            localDisplayName: _displayName,
            localAvatarId: _avatarId,
            localRole: role,
            isSoloWithBot: isSoloWithBot,
            opponentName: isSoloWithBot ? 'SketchBot' : 'AlexM',
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HalfAndHalfState>(
      stream: _engine.stateStream,
      initialData: _engine.state,
      builder: (BuildContext context, AsyncSnapshot<HalfAndHalfState> snapshot) {
        final HalfAndHalfState state = snapshot.data ?? _engine.state;

        return Scaffold(
          backgroundColor: const Color(0xff0e0b1a),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xff18122d),
                  Color(0xff100c20),
                  Color(0xff090714),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  // Top Navigation Header
                  _buildHeader(state),

                  // Main Phase Body
                  Expanded(
                    child: _buildPhaseContent(state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(HalfAndHalfState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: <Widget>[
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
            onPressed: () {
              if (state.phase == HalfAndHalfPhase.drawing) {
                _confirmExit();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),

          // Game Title & Phase Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'HALF & HALF',
                  style: HalfAndHalfTheme.title(
                    fontSize: 17,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  _getPhaseStatusText(state),
                  style: HalfAndHalfTheme.body(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Player Role Indicator Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xff2d1f4e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HalfAndHalfTheme.purplePrimary, width: 1.1),
            ),
            child: Text(
              state.localRole.playerLabel,
              style: HalfAndHalfTheme.badge(
                color: HalfAndHalfTheme.accentGold,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPhaseStatusText(HalfAndHalfState state) {
    switch (state.phase) {
      case HalfAndHalfPhase.lobby:
        return 'Lobby';
      case HalfAndHalfPhase.memorize:
        return 'Memorize (${state.memorizeSecondsRemaining}s)';
      case HalfAndHalfPhase.drawing:
        return 'Drawing Phase: 00:${state.drawSecondsRemaining.toString().padLeft(2, '0')}';
      case HalfAndHalfPhase.reveal:
        return 'Results & Compare';
    }
  }

  Widget _buildPhaseContent(HalfAndHalfState state) {
    switch (state.phase) {
      case HalfAndHalfPhase.lobby:
        return Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff7c3aed),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text('Join / Start Match', style: HalfAndHalfTheme.button(fontSize: 16)),
            onPressed: _showLobbyDialog,
          ),
        );

      case HalfAndHalfPhase.memorize:
        return MemorizePhaseWidget(
          prompt: state.prompt,
          localRole: state.localRole,
          secondsRemaining: state.memorizeSecondsRemaining,
        );

      case HalfAndHalfPhase.drawing:
        final bool isTop = state.localRole == HalfAndHalfRole.topHalf;
        final List<DrawingStroke> strokes = isTop ? state.topStrokes : state.bottomStrokes;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Column(
            children: <Widget>[
              // Title matching Phone 2 & 3
              Text(
                isTop ? 'Draw the Top Half' : 'Draw Bottom Half to Match',
                style: HalfAndHalfTheme.title(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),

              const SizedBox(height: 10),

              // Interactive Split Canvas
              Expanded(
                child: HalfAndHalfCanvas(
                  localRole: state.localRole,
                  currentStrokes: strokes,
                  selectedColor: _selectedColor,
                  selectedWidth: _selectedWidth,
                  isEraser: _isEraser,
                  onStrokeCompleted: (DrawingStroke s) => _engine.addLocalStroke(s),
                  onSizeDetermined: (Size s) => _engine.setCanvasSize(s),
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Drawing Toolbar
              HalfAndHalfToolbar(
                selectedColor: _selectedColor,
                selectedWidth: _selectedWidth,
                isEraser: _isEraser,
                onSelectPencil: () => setState(() => _isEraser = false),
                onSelectEraser: () => setState(() => _isEraser = true),
                onSelectColor: (Color c) => setState(() {
                  _selectedColor = c;
                  _isEraser = false;
                }),
                onSelectWidth: (double w) => setState(() => _selectedWidth = w),
                onUndo: () => _engine.undoLocalStroke(),
                onClear: () => _engine.clearLocalStrokes(),
                onSubmit: () => _engine.submitAndReveal(),
              ),
            ],
          ),
        );

      case HalfAndHalfPhase.reveal:
        return MergedRevealWidget(
          prompt: state.prompt,
          state: state,
          onAddReaction: (String emoji) => _engine.addReaction(emoji),
          onToggleLike: () => _engine.toggleLike(),
          onPlayAgain: () => _showLobbyDialog(),
          onReturnToLobby: () => Navigator.of(context).pop(),
        );
    }
  }

  void _confirmExit() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: const Color(0xff18122d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Leave Match?', style: HalfAndHalfTheme.title(fontSize: 18)),
        content: Text(
          'Your drawing will be discarded and your partner will be notified.',
          style: HalfAndHalfTheme.body(fontSize: 13, color: Colors.white70),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Drawing', style: HalfAndHalfTheme.button(fontSize: 14, color: HalfAndHalfTheme.purpleAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
            child: Text('Exit', style: HalfAndHalfTheme.button(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

