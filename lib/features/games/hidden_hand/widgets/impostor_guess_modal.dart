import 'package:flutter/material.dart';
import '../models/hidden_hand_player.dart';
import '../models/hidden_hand_state.dart';

class ImpostorGuessModal extends StatefulWidget {
  final HiddenHandState state;
  final String localPlayerId;
  final ValueChanged<String> onSubmitGuess;

  const ImpostorGuessModal({
    super.key,
    required this.state,
    required this.localPlayerId,
    required this.onSubmitGuess,
  });

  @override
  State<ImpostorGuessModal> createState() => _ImpostorGuessModalState();
}

class _ImpostorGuessModalState extends State<ImpostorGuessModal> {
  final TextEditingController _guessController = TextEditingController();

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  void _submit() {
    final String guess = _guessController.text.trim();
    if (guess.isNotEmpty) {
      widget.onSubmitGuess(guess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final HiddenHandPlayer? caughtPlayer = widget.state.eliminatedPlayer;
    final bool isLocalPlayerTheImpostor =
        caughtPlayer != null && caughtPlayer.id == widget.localPlayerId;

    return Container(
      color: Colors.black.withValues(alpha: 0.90),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xff231728),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xfff43f5e), width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xfff43f5e).withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Pulsing Impostor Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xff4c1d34),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Color(0xfff43f5e),
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "IMPOSTOR'S LAST CHANCE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xfff43f5e),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                isLocalPlayerTheImpostor
                    ? 'You were discovered! But you can still win if you can guess what everyone was drawing!'
                    : '${caughtPlayer?.displayName ?? "The impostor"} was caught! They are now attempting to guess the secret drawing to steal the win!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xffcbd5e1), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xfff43f5e).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'CATEGORY: ${widget.state.secretPrompt.category.toUpperCase()}',
                  style: const TextStyle(
                    color: Color(0xfffb7185),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (isLocalPlayerTheImpostor) ...<Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff181220),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xff5e203c)),
                  ),
                  child: TextField(
                    controller: _guessController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xfff43f5e)),
                      hintText: 'Enter your guess (e.g. Pizza, Bicycle)...',
                      hintStyle: TextStyle(color: Color(0xff717082), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff43f5e),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'SUBMIT FINAL GUESS',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ] else ...<Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Color(0xfff43f5e),
                      strokeWidth: 3,
                    ),
                  ),
                ),
                Text(
                  'Waiting for ${caughtPlayer?.displayName ?? "impostor"} to submit guess...',
                  style: const TextStyle(color: Colors.white60, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
