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

  // Default menu orientation: portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MonsterMania());
}

class MonsterMania extends StatelessWidget {
  const MonsterMania({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MainMenuScreen());
  }
}

enum Game { endlessRunner, flappy, dash }

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure menu is always portrait
    Flame.device.setPortrait();
  }

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
              onPressed: () => _openGame(context, Game.endlessRunner, Orientation.landscape),
              child: const Text('Start Endless Runner'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _openGame(context, Game.flappy, Orientation.landscape),
              child: const Text('Flappy Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _openGame(context, Game.dash, Orientation.portrait),
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

  static Future<void> _openGame(
      BuildContext context,
      Game gameType,
      Orientation orientation,
      ) async {
    final navigator = Navigator.of(context); // capture before awaits
    if (orientation == Orientation.landscape) {
      await Flame.device.setLandscape();
    } else {
      await Flame.device.setPortrait();
    }

    // Wait until constraints have updated to the desired orientation
    while (MediaQuery.of(context).orientation != orientation) {
      await WidgetsBinding.instance.endOfFrame;
      if (!context.mounted) return; // safety
    }

    // Now it's safe to create the GameWidget with correct (landscape) sizes
    final gameWidget = _buildGameWidget(gameType, context);
    await navigator.push(MaterialPageRoute(
      builder: (_) => PopScope(
        canPop: false,
        child: Scaffold(body: gameWidget),
      ),
    ));

    await Flame.device.setPortrait();
  }

// build the GameWidget only after orientation settled
  static Widget _buildGameWidget(Game gameType, BuildContext context) {
    switch (gameType) {
      case Game.endlessRunner:
        return GameWidget(
          game: EndlessRunnerGame(onExitToMenu: () => Navigator.of(context).pop()),
          overlayBuilderMap: {
            'GameOver': (ctx, g) => GameOverOverlay(game: g as EndlessRunnerGame),
          },
        );
      case Game.flappy:
        return GameWidget(
          game: FlappyGame(
            onExitToMenu: () {
              Navigator.of(context).pop();
            },
          ),
          overlayBuilderMap: {
            'GameOver':
                (context, game) => GameOverOverlay(game: game as FlappyGame),
            'GetReady': (context, game) {
              final g = game as FlappyGame;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  g.startFromIntro();
                  g.overlays.remove('GetReady');
                },
                child: Center(
                  child: Image.asset(
                    'assets/images/flappy/start_overlay.png',
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.contain,
                    width: 480,
                  ),
                ),
              );
            },
          },
          initialActiveOverlays: const ['GetReady'],
        );
      case Game.dash:
        return GameWidget(
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
  }

}
