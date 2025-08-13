import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flamegame/base_game.dart';

class GameOverOverlay extends StatelessWidget {
  final BaseGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bool isNewHighScore = game.highScore > game.previousHighScore;
    final double panelWidth = mq.size.width.clamp(280.0, 420.0);

    final _Medal medal = _pickMedal(game.score);

    return Stack(
      children: [
        // Dim + blur the running game behind the overlay
        ModalBarrier(color: Colors.black.withOpacity(0.35), dismissible: false),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Center(
            child: Semantics(
              label: 'Game over. Score ${game.score}. Best ${game.highScore}.',
              container: true,
              child: Container(
                width: panelWidth,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3B3),
                  border: Border.all(color: Colors.brown, width: 3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26, offset: Offset(0, 6))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME OVER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 20,
                        color: Color(0xFFDA6317),
                        shadows: [Shadow(color: Colors.white, offset: Offset(2, 2))],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Scoreboard
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Medal
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'MEDAL',
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 8,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (medal.asset != null)
                                Image.asset(medal.asset!, width: 56, height: 56)
                              else
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(color: Colors.orangeAccent, width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('—',
                                      style: TextStyle(fontFamily: 'PressStart2P', fontSize: 10)),
                                ),
                            ],
                          ),
                        ),

                        // Score / Best
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'SCORE',
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 12,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (c, a) =>
                                    ScaleTransition(scale: a, child: c),
                                child: Text(
                                  '${game.score}',
                                  key: ValueKey<int>(game.score),
                                  style: const TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 24,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 14,
                                  color: isNewHighScore ? Colors.redAccent : Colors.orangeAccent,
                                ),
                                child: Text(isNewHighScore ? 'NEW BEST' : 'BEST'),
                              ),
                              Text(
                                '${game.highScore}',
                                style: const TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BigIconButton(
                          tooltip: 'Menu',
                          asset: 'assets/images/menu_button.png',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            game.overlays.remove('GameOver');
                            game.onExitToMenu?.call();
                          },
                        ),
                        _BigIconButton(
                          tooltip: 'Play again',
                          asset: 'assets/images/play_button.png',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            game.overlays.remove('GameOver');
                            game.restart();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _Medal _pickMedal(int score) {
    if (score >= 30) return _Medal('assets/images/medal_gold.png');
    if (score >= 20) return _Medal('assets/images/medal_silver.png');
    if (score >= 10) return _Medal('assets/images/medal_bronze.png');
    return const _Medal(null);
  }
}

class _BigIconButton extends StatelessWidget {
  final String asset;
  final VoidCallback onPressed;
  final String? tooltip;
  const _BigIconButton({required this.asset, required this.onPressed, this.tooltip, super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkResponse(
        onTap: onPressed,
        radius: 40,
        child: Image.asset(asset, width: 96, height: 64),
      ),
    );
  }
}

class _Medal {
  final String? asset;
  const _Medal(this.asset);
}
