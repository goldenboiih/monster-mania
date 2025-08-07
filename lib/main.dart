import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flamegame/monster_dash/monster_dash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'endless_runner/runner_game.dart';
import 'flappy_game/flappy_game.dart';
import 'monster_maker/avatar_maker_screen.dart';
import 'overlays/game_over_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(const MonsterMania());
}

class MonsterMania extends StatelessWidget {
  const MonsterMania({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainMenuScreen(),
    );
  }
}

enum Game { endlessRunner, flappy, dash }

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Monster Mania',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _openGame(context, Game.endlessRunner),
              child: const Text('Start Endless Runner'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _openGame(context, Game.flappy),
              child: const Text('Flappy Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _openGame(context, Game.dash),
              child: const Text('Monster Dash'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AvatarMakerScreen()),
                );
              },
              child: const Text('Monster Maker'),
            ),
          ],
        ),
      ),
    );
  }

  static void _openGame(BuildContext context, Game gameType) async {
    Widget gameWidget;

    switch (gameType) {
      case Game.endlessRunner:
      // Lock to landscape when game starts
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        gameWidget = GameWidget(
          game: EndlessRunnerGame(
            onExitToMenu: () {
              Navigator.of(context).pop();
            },
          ),
          overlayBuilderMap: {
            'GameOver':
                (context, game) => GameOverOverlay(game: game as EndlessRunnerGame),
          },
        );
        break;
      case Game.flappy:
      // Lock to landscape when game starts
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        gameWidget = GameWidget(
          game: FlappyGame(
            onExitToMenu: () {
              Navigator.of(context).pop();
            },
          ),
          overlayBuilderMap: {
            'GameOver':
                (context, game) => GameOverOverlay(game: game as FlappyGame),
          },
        );
        break;
      case Game.dash:
      // Lock to landscape when game starts
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        gameWidget = GameWidget(
          game: MonsterDash(
            onExitToMenu: () {
              Navigator.of(context).pop();
            },
          ),
          overlayBuilderMap: {
            'GameOver':
                (context, game) => GameOverOverlay(game: game as MonsterDash),
          },
        );
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => Scaffold(body: gameWidget)));
  }
}
