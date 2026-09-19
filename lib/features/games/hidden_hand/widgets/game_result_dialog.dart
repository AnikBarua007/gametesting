import 'package:flutter/material.dart';
import '../models/hidden_hand_player.dart';
import '../models/hidden_hand_state.dart';

class GameResultDialog extends StatelessWidget {
  final HiddenHandState state;
  final String localPlayerId;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const GameResultDialog({
    super.key,
    required this.state,
    required this.localPlayerId,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final bool artistsWon = state.winningRole == PlayerRole.artist;
    final HiddenHandPlayer? localPlayer = state.getPlayer(localPlayerId);
    final bool didLocalPlayerWin = localPlayer != null && localPlayer.role == state.winningRole;

    final Color accentColor = artistsWon ? const Color(0xffefc249) : const Color(0xfff43f5e);

    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xff1b1d2c),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: accentColor, width: 2.2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: accentColor.withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Trophy / Skull Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  artistsWon ? Icons.emoji_events_rounded : Icons.theater_comedy_rounded,
                  color: accentColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 14),

              // Winner Title
              Text(
                artistsWon ? 'ARTISTS VICTORY!' : 'HIDDEN HAND VICTORY!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                didLocalPlayerWin ? 'You won this round!' : 'Better luck next time!',
                style: TextStyle(
                  color: didLocalPlayerWin ? const Color(0xff10b981) : const Color(0xff94a3b8),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              // Secret Word Revealed
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xff232537),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xff3f415c)),
                ),
                child: Column(
                  children: <Widget>[
                    const Text(
                      'THE SECRET OBJECT WAS',
                      style: TextStyle(
                        color: Color(0xff94a3b8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.secretPrompt.word.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    if (state.impostorSubmittedGuess != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        "Impostor guessed: '${state.impostorSubmittedGuess}'",
                        style: TextStyle(
                          color: state.impostorGuessCorrect == true
                              ? const Color(0xff10b981)
                              : const Color(0xfff43f5e),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Player Roles Reveal List
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ROLES REVEALED:',
                  style: TextStyle(color: Color(0xffa1a0b0), fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),

              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.players.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final HiddenHandPlayer p = state.players[index];
                    final bool isImpostor = p.isImpostor;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xff232537),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(p.assignedColorValue),
                            child: Text(
                              p.displayName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xff12131c),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              p.displayName,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isImpostor
                                  ? const Color(0xfff43f5e).withValues(alpha: 0.2)
                                  : const Color(0xff10b981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isImpostor
                                    ? const Color(0xfff43f5e)
                                    : const Color(0xff10b981),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isImpostor ? 'HIDDEN HAND' : 'ARTIST',
                              style: TextStyle(
                                color: isImpostor ? const Color(0xfff43f5e) : const Color(0xff10b981),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onExit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xffa1a0b0),
                        side: const BorderSide(color: Color(0xff444760)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('LEAVE', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onPlayAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: const Color(0xff1c1d2a),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('PLAY AGAIN',
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

