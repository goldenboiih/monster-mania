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
import 'package:flamegame/ui/music_toggle.dart';
import 'package:flamegame/ui/score.dart';
import 'package:flamegame/world/background.dart';
import 'package:flamegame/world/cloud.dart';
import 'package:flamegame/world/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../highscore_manager.dart';
import 'obstacles/obstacle.dart';
import 'obstacles/obstacle_floaty.dart';
import 'obstacles/obstacle_grumbluff.dart';
import 'runner.dart';

class EndlessRunnerGame extends BaseGame
    with TapDetector, HasCollisionDetection, KeyboardEvents {
  @override
  final VoidCallback? onExitToMenu;
  final double floorHeight = 64;
  late Runner runner;

  late Timer obstacleTimer;
  late GameState gameState;

  EndlessRunnerGame({this.onExitToMenu});

  @override
  Future<void> onLoad() async {
    add(MusicToggle());
    await initializeGame();
  }

  Future<void> initializeGame() async {
    score = 0;
    speed = 300;
    gameState = GameState.playing;

    // spawn every 2 seconds
    obstacleTimer = Timer(
      1.5,
      onTick: spawnRandomObstacle,
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
      baseVelocity: Vector2(20, 0),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(1.0, 0.0),
      priority: -1,
    );
    add(parallax);
    add(JumpButton());
    add(CrouchButton());
    add(Score());
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
    // Grumbluff alive? -> skip spawning anything
    if (children.whereType<ObstacleGrumbluff>().isNotEmpty) {
      return;
    }

    // Pick obstacle type
    final int type = Random().nextInt(4); // 4 types
    late final Component obstacle;

    switch (type) {
      case 0:
        obstacle = ObstacleSpiky();
        break;
      case 1:
        obstacle = ObstacleFlyGuy();
        break;
      case 2:
        obstacle = ObstacleGrumbluff(); // always alone
        break;
      case 3:
        obstacle = ObstacleFloaty();
        break;
      default:
        return;
    }
    add(obstacle);
  }

  void onPlayerCollision(PositionComponent other) {
    if (gameState == GameState.crashing) return;
    gameState = GameState.crashing;
    if (other is Obstacle || other is ObstacleFlyGuy || other is ObstacleGrumbluff) {
      runner.die();
    }
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
    children.whereType<Component>().forEach((c) => c.removeFromParent());
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
