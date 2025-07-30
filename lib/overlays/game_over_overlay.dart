import 'package:flutter/material.dart';
import 'package:flamegame/flappy_game/flappy_game.dart';

class GameOverOverlay extends StatelessWidget {
  final FlappyGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.black.withOpacity(0.8),
        margin: const EdgeInsets.all(40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Score: ${game.score}',
                style: const TextStyle(fontSize: 24, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  game.overlays.remove('GameOver');
                  game.restart();
                },
                child: const Text('Again'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  game.overlays.remove('GameOver');
                  game.pauseEngine();
                  game.onExitToMenu?.call();
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
