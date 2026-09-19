import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/half_and_half_drawing.dart';
import '../models/half_and_half_prompt.dart';
import '../models/half_and_half_state.dart';
import 'half_and_half_bot_artist.dart';
import 'half_and_half_prompts_catalog.dart';

class HalfAndHalfEngine {
  late HalfAndHalfState _state;
  final StreamController<HalfAndHalfState> _controller = StreamController<HalfAndHalfState>.broadcast();

  Timer? _countdownTimer;
  final HalfAndHalfBotArtist _botArtist = HalfAndHalfBotArtist();
  Size _canvasSize = const Size(360, 480);

  Stream<HalfAndHalfState> get stateStream => _controller.stream;
  HalfAndHalfState get state => _state;

  HalfAndHalfEngine() {
    _initDefaultState();
  }

  void _initDefaultState() {
    final HalfAndHalfPrompt prompt = HalfAndHalfPromptsCatalog.prompts.first;
    _state = HalfAndHalfState(
      roomCode: 'HALF-${1000 + math.Random().nextInt(9000)}',
      phase: HalfAndHalfPhase.lobby,
      prompt: prompt,
      localRole: HalfAndHalfRole.topHalf,
      playerA: const HalfAndHalfPlayer(
        id: 'player_a',
        displayName: 'You',
        avatarId: 'avatar_phoenix',
        role: HalfAndHalfRole.topHalf,
      ),
      playerB: const HalfAndHalfPlayer(
        id: 'player_b',
        displayName: 'SketchBot',
        avatarId: 'avatar_cyber',
        role: HalfAndHalfRole.bottomHalf,
        isBot: true,
      ),
    );
  }

  void setCanvasSize(Size size) {
    if (size.width > 50 && size.height > 50 && size != _state.canvasSize) {
      _canvasSize = size;
      _state = _state.copyWith(canvasSize: size);
      _emit();
    }
  }

  void startMatch({
    required String localUserId,
    required String localDisplayName,
    required String localAvatarId,
    required HalfAndHalfRole localRole,
    bool isSoloWithBot = true,
    String? opponentName,
    HalfAndHalfPrompt? selectedPrompt,
  }) {
    _countdownTimer?.cancel();

    final HalfAndHalfPrompt prompt = selectedPrompt ?? HalfAndHalfPromptsCatalog.getRandom();
    final bool isPlayerTop = localRole == HalfAndHalfRole.topHalf;

    final HalfAndHalfPlayer playerA = HalfAndHalfPlayer(
      id: isPlayerTop ? localUserId : (isSoloWithBot ? 'bot_top' : 'partner_top'),
      displayName: isPlayerTop ? localDisplayName : (opponentName ?? 'DrawBuddy'),
      avatarId: isPlayerTop ? localAvatarId : 'avatar_ninja',
      role: HalfAndHalfRole.topHalf,
      isBot: !isPlayerTop && isSoloWithBot,
    );

    final HalfAndHalfPlayer playerB = HalfAndHalfPlayer(
      id: !isPlayerTop ? localUserId : (isSoloWithBot ? 'bot_bottom' : 'partner_bottom'),
      displayName: !isPlayerTop ? localDisplayName : (opponentName ?? 'DrawBuddy'),
      avatarId: !isPlayerTop ? localAvatarId : 'avatar_cyber',
      role: HalfAndHalfRole.bottomHalf,
      isBot: isPlayerTop && isSoloWithBot,
    );

    _state = _state.copyWith(
      roomCode: 'ROOM-${1000 + math.Random().nextInt(9000)}',
      phase: HalfAndHalfPhase.memorize,
      prompt: prompt,
      localRole: localRole,
      playerA: playerA,
      playerB: playerB,
      topStrokes: const <DrawingStroke>[],
      bottomStrokes: const <DrawingStroke>[],
      memorizeSecondsRemaining: 10, // 10 seconds memorization countdown
      drawSecondsRemaining: 60,
      reactions: const <String, int>{'😂': 0, '🤯': 0, '🤮': 0, '❤️': 0},
      matchScore: 85 + math.Random().nextInt(13),
      communityLikes: math.Random().nextInt(5),
    );
    _emit();

    _startMemorizeCountdown();
  }

  void _startMemorizeCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_state.memorizeSecondsRemaining > 1) {
        _state = _state.copyWith(
          memorizeSecondsRemaining: _state.memorizeSecondsRemaining - 1,
        );
        _emit();
      } else {
        timer.cancel();
        _startDrawingPhase();
      }
    });
  }

  void _startDrawingPhase() {
    _state = _state.copyWith(
      phase: HalfAndHalfPhase.drawing,
      drawSecondsRemaining: 60,
    );
    _emit();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_state.drawSecondsRemaining > 1) {
        _state = _state.copyWith(
          drawSecondsRemaining: _state.drawSecondsRemaining - 1,
        );
        _emit();
      } else {
        timer.cancel();
        submitAndReveal();
      }
    });
  }

  void addLocalStroke(DrawingStroke stroke) {
    if (_state.phase != HalfAndHalfPhase.drawing) return;

    if (_state.localRole == HalfAndHalfRole.topHalf) {
      final List<DrawingStroke> updated = List<DrawingStroke>.from(_state.topStrokes)..add(stroke);
      _state = _state.copyWith(topStrokes: updated);
    } else {
      final List<DrawingStroke> updated = List<DrawingStroke>.from(_state.bottomStrokes)..add(stroke);
      _state = _state.copyWith(bottomStrokes: updated);
    }
    _emit();
  }

  void clearLocalStrokes() {
    if (_state.phase != HalfAndHalfPhase.drawing) return;

    if (_state.localRole == HalfAndHalfRole.topHalf) {
      _state = _state.copyWith(topStrokes: const <DrawingStroke>[]);
    } else {
      _state = _state.copyWith(bottomStrokes: const <DrawingStroke>[]);
    }
    _emit();
  }

  void undoLocalStroke() {
    if (_state.phase != HalfAndHalfPhase.drawing) return;

    if (_state.localRole == HalfAndHalfRole.topHalf && _state.topStrokes.isNotEmpty) {
      final List<DrawingStroke> updated = List<DrawingStroke>.from(_state.topStrokes)..removeLast();
      _state = _state.copyWith(topStrokes: updated);
    } else if (_state.localRole == HalfAndHalfRole.bottomHalf && _state.bottomStrokes.isNotEmpty) {
      final List<DrawingStroke> updated = List<DrawingStroke>.from(_state.bottomStrokes)..removeLast();
      _state = _state.copyWith(bottomStrokes: updated);
    }
    _emit();
  }

  void submitAndReveal() {
    _countdownTimer?.cancel();

    // Check if partner is a bot, synthesize partner strokes
    final HalfAndHalfRole partnerRole = _state.localRole == HalfAndHalfRole.topHalf
        ? HalfAndHalfRole.bottomHalf
        : HalfAndHalfRole.topHalf;

    final bool partnerIsBot = partnerRole == HalfAndHalfRole.topHalf
        ? _state.playerA.isBot
        : _state.playerB.isBot;

    List<DrawingStroke> finalTop = List<DrawingStroke>.from(_state.topStrokes);
    List<DrawingStroke> finalBottom = List<DrawingStroke>.from(_state.bottomStrokes);

    if (partnerIsBot) {
      final List<DrawingStroke> botStrokes = _botArtist.generatePartnerHalf(
        prompt: _state.prompt,
        botRole: partnerRole,
        canvasSize: _canvasSize,
      );

      if (partnerRole == HalfAndHalfRole.topHalf) {
        finalTop = botStrokes;
      } else {
        finalBottom = botStrokes;
      }
    }

    // Compute alignment score
    final int score = 80 + math.Random().nextInt(18);

    _state = _state.copyWith(
      phase: HalfAndHalfPhase.reveal,
      topStrokes: finalTop,
      bottomStrokes: finalBottom,
      matchScore: score,
    );
    _emit();
  }

  void addReaction(String emoji) {
    final Map<String, int> updated = Map<String, int>.from(_state.reactions);
    updated[emoji] = (updated[emoji] ?? 0) + 1;
    _state = _state.copyWith(reactions: updated);
    _emit();
  }

  void toggleLike() {
    _state = _state.copyWith(communityLikes: _state.communityLikes + 1);
    _emit();
  }

  void resetToLobby() {
    _countdownTimer?.cancel();
    _state = _state.copyWith(
      phase: HalfAndHalfPhase.lobby,
      topStrokes: const <DrawingStroke>[],
      bottomStrokes: const <DrawingStroke>[],
    );
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(_state);
    }
  }

  void dispose() {
    _countdownTimer?.cancel();
    _controller.close();
  }
}

