import 'package:flamegame/base_game.dart';
import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  final BaseGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final bool isNewHighScore = game.score == game.highScore;

    return Center(
      child: Container(
        width: 384,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3B3),
          border: Border.all(color: Colors.brown, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 20,
                color: Color(0xFFDA6317),
                shadows: [Shadow(color: Colors.white, offset: Offset(2, 2))],
              ),
            ),
            const SizedBox(height: 24),

            // Scoreboard
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Medal
                Column(
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
                    // Image.asset(
                    //   'assets/images/medal_silver.png',
                    //   width: 48,
                    //   height: 48,
                    // ),
                  ],
                ),

                // Score and Highscore
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'SCORE',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 16,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${game.score}',
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isNewHighScore ? 'NEW BEST' : 'BEST',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 16,
                        color: isNewHighScore ? Colors.redAccent : Colors.orangeAccent,
                      ),
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
              ],
            ),

            const SizedBox(height: 32),

            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 64,
                  onPressed: () {
                    game.overlays.remove('GameOver');
                    game.onExitToMenu?.call();
                  },
                  icon: Image.asset('assets/images/menu_button.png'),
                ),
                IconButton(
                  onPressed: () {
                    game.overlays.remove('GameOver');
                    game.restart();
                  },
                  icon: Image.asset('assets/images/play_button.png'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
