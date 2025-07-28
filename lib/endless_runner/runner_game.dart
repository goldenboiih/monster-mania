import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flamegame/endless_runner/world/background.dart';

import 'obstacles/obstacle.dart';
import 'obstacles/obstacle_grumbluff.dart';
import 'player.dart';
import 'ui/jump_button.dart';
import 'ui/menu_button.dart';
import 'ui/score.dart';
import 'world/cloud.dart';
import 'world/floor.dart';

class EndlessRunnerGame extends FlameGame
    with TapDetector, HasCollisionDetection {
  late Player player;
  // late Timer obstacleTimer;
  late Timer cloudTimer;
  int speed = 300;
  bool isGameOver = false;
  final Random _random = Random();
  final VoidCallback? onExitToMenu;

  EndlessRunnerGame({this.onExitToMenu});

  @override
  Future<void> onLoad() async {
    await initializeGame();
  }

  Future<void> initializeGame() async {
    isGameOver = false;

    cloudTimer = Timer(
      1,
      onTick: () {
        add(Cloud());
      },
      repeat: true,
    )..start();

    add(Background());
    add(Floor());

    player = Player();
    add(player);

    add(
      MenuButton(

        onPressed: () {
          onExitToMenu?.call(); // Triggers Navigator.pop() via the parent
        },
      ),
    );

    add(JumpButton());
    add(Score());
  }

  @override
  bool get debugMode => true;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameOver) {
      spawnRandomObstacle();
      // obstacleTimer.update(dt);
      cloudTimer.update(dt);
    }
  }

  void spawnRandomObstacle() {
    final hasObstacle = children.whereType<Obstacle>().isNotEmpty;
    if (hasObstacle) {
      return;
    }
    final int type = _random.nextInt(3); // 3 types
    late final Component obstacle;

    switch (type) {
      case 0:
        obstacle = ObstacleGrumbluff();
        break;
      case 1:
        obstacle = ObstacleGrumbluff();
        break;
      case 2:
        obstacle = ObstacleGrumbluff();

        // obstacles = ObstacleFloaty()
        //   ..position.y = 100;
        break;
    }
    add(obstacle);
  }

  void reset() {
    isGameOver = true;
    speed = 300;
    // Remove all children (player, floor, background, etc.)
    children.whereType<Component>().forEach((c) => c.removeFromParent());
    // Restart after a short delay
    Future.delayed(const Duration(milliseconds: 0), () async {
      await initializeGame();
    });
  }
}
