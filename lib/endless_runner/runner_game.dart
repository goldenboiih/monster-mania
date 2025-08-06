import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/endless_runner/obstacles/obstacle_fly_guy.dart';
import 'package:flamegame/endless_runner/obstacles/obstacle_spiky.dart';
import 'package:flamegame/ui/crouch_button.dart';
import 'package:flamegame/ui/jump_button.dart';
import 'package:flamegame/ui/menu_button.dart';
import 'package:flamegame/ui/score.dart';
import 'package:flamegame/world/background.dart';
import 'package:flamegame/world/cloud.dart';
import 'package:flamegame/world/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../highscore_manager.dart';
import 'obstacles/obstacle.dart';
import 'obstacles/obstacle_grumbluff.dart';
import 'runner.dart';

class EndlessRunnerGame extends BaseGame
    with TapDetector, HasCollisionDetection, KeyboardEvents {

  @override
  final VoidCallback? onExitToMenu;
  final double floorHeight = 64;
  late Runner runner;

  // TODO: replace clouds
  late Timer cloudTimer;
  late GameState gameState;
  final Random _random = Random();

  EndlessRunnerGame({this.onExitToMenu});

  @override
  Future<void> onLoad() async {
    await initializeGame();
  }

  Future<void> initializeGame() async {
    score = 0;
    speed = 300;
    gameState = GameState.playing;

    cloudTimer = Timer(
      1,
      onTick: () {
        add(Cloud());
      },
      repeat: true,
    )..start();

    add(Background());
    add(Floor(tileHeight: floorHeight));

    runner = Runner();
    add(runner);


    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('flappy/background.png'),
      ],
      baseVelocity: Vector2(20, 0), // horizontal scroll to the left
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(1.0, 0.0),
      priority: -1, // ensure it renders in the background
    );
    add(parallax);
    add(JumpButton());
    add(CrouchButton());
    add(Score());
    add(
      MenuButton(
        onPressed: () {
          onExitToMenu?.call(); // Triggers Navigator.pop() via the parent
        },
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState == GameState.playing) {
      score++;
      spawnRandomObstacle();
      cloudTimer.update(dt);
    }
  }

  void spawnRandomObstacle() {
    // TODO: create convenience function for this
    final hasObstacle = children.whereType<Obstacle>().isNotEmpty || children.whereType<ObstacleFlyGuy>().isNotEmpty;
    if (hasObstacle) {
      return;
    }
    final int type = _random.nextInt(3); // 3 types
    late final Component obstacle;

    switch (type) {
      case 0:
        obstacle = ObstacleSpiky();
        break;
      case 1:
        obstacle = ObstacleFlyGuy();
        break;
      case 2:
        obstacle = ObstacleGrumbluff();

        // obstacles = ObstacleFloaty()
        //   ..position.y = 100;
        break;
    }
    add(obstacle);
  }

  void onPlayerCollision() {
    gameState = GameState.crashing;
    FlameAudio.play('die.mp3');
  }

  Future<void> onGameOver() async {
    gameState = GameState.gameOver;
    previousHighScore = await HighscoreManager.getHighscore('runner');
    await HighscoreManager.saveHighscore('runner', score);
    highScore = await HighscoreManager.getHighscore('runner');
    overlays.add('GameOver');
  }

  @override
  void restart() {
    // Remove all children (player, floor, background, etc.)
    children.whereType<Component>().forEach((c) => c.removeFromParent());
    // Restart after a short delay
    Future.delayed(const Duration(milliseconds: 0), () async {
      await initializeGame();
    });
  }

  // Keyboard controls for development
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        event is KeyDownEvent) {
      runner.jump();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (event is KeyDownEvent) {
        runner.crouch();
        return KeyEventResult.handled;
      } else if (event is KeyUpEvent) {
        runner.stopCrouch();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}
