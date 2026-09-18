import 'package:flutter/material.dart';
import '../models/game_words.dart';
import '../models/hidden_hand_player.dart';

class RoleRevealModal extends StatelessWidget {
  final HiddenHandPlayer localPlayer;
  final DrawingWordPrompt prompt;
  final VoidCallback onDismiss;

  const RoleRevealModal({
    super.key,
    required this.localPlayer,
    required this.prompt,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImpostor = localPlayer.isImpostor;

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isImpostor ? const Color(0xff2d1727) : const Color(0xff1d2338),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isImpostor ? const Color(0xfff43f5e) : const Color(0xffefc249),
              width: 2.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (isImpostor ? const Color(0xfff43f5e) : const Color(0xffefc249))
                    .withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isImpostor ? const Color(0xff4c1d34) : const Color(0xff28314e),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isImpostor ? Icons.visibility_off_rounded : Icons.palette_rounded,
                  color: isImpostor ? const Color(0xfff43f5e) : const Color(0xffefc249),
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                isImpostor ? 'YOU ARE THE HIDDEN HAND' : 'YOU ARE AN ARTIST',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isImpostor ? const Color(0xfff43f5e) : const Color(0xffefc249),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Prompt Box or Impostor Warning
              if (!isImpostor) ...<Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xffefc249).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'CATEGORY: ${prompt.category.toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xffefc249),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff121626),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xff3f4663)),
                  ),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'YOUR SECRET OBJECT TO DRAW:',
                        style: TextStyle(
                          color: Color(0xff94a3b8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        prompt.word.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Draw a small piece on your turn. Blend with teammates and identify the fake artist!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xffcbd5e1), fontSize: 13, height: 1.4),
                ),
              ] else ...<Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xff1f121d),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xff5e203c)),
                  ),
                  child: Column(
                    children: const <Widget>[
                      Text(
                        'THE SECRET WORD IS HIDDEN FROM YOU',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xfffb7185),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Observe lines drawn by other players. Add plausible strokes without giving yourself away!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tip: If caught during voting, you can still win by guessing the secret object!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xfffda4af), fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],

              const SizedBox(height: 22),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isImpostor ? const Color(0xfff43f5e) : const Color(0xffefc249),
                    foregroundColor: const Color(0xff1c1d2a),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'I UNDERSTAND — ENTER ARENA',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
