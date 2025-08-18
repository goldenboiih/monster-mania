import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/highscore_manager.dart';
import 'package:flamegame/ui/crouch_button.dart';
import 'package:flamegame/ui/jump_button.dart';
import 'package:flamegame/world/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'diagnostics_overlay.dart';
import 'obstacles/obstacle_fly_guy.dart';
import 'obstacles/obstacle_grumbluff.dart';
import 'obstacles/obstacle_spiky.dart';
import 'obstacles/obstacle_tag.dart';
import 'runner.dart';

class EndlessRunnerGame extends BaseGame
    with TapDetector, HasCollisionDetection, KeyboardEvents {
  @override
  final VoidCallback? onExitToMenu;

  @override
  String get gameId => 'runner';

  EndlessRunnerGame({this.onExitToMenu});

  final double floorHeight = 64;
  late Runner runner;

  late GameState gameState;

  // Difficulty ramp
  late double spawnInterval; // seconds between spawns (starts here)
  final double minSpawnInterval = 0.6;
  final double spawnStep = 0.1; // subtract this when ramping

  final double initialSpeed = 400;
  final double speedStep = 40; // add this each ramp
  final double maxSpeed = 800;

  double difficultyClock = 0.0; // seconds since last ramp
  final double rampEvery = 8.0; // ramp every N seconds

  // Distance-based scoring
  // Define how many pixels are "one meter" for your UI
  static const double pixelsPerMeter = 100.0;
  double distanceMeters = 0.0;

  // Spawning
  late Timer obstacleTimer;
  final _random = Random();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final double floorTopY = size.y - floorHeight;
    final double parallaxHeight = floorTopY; // everything above the floor

    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('jungle_bg.png'),
      ],
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(5, 0.0),
      repeat: ImageRepeat.repeatX, // only scroll/tile horizontally
      priority: -1,
      size: Vector2(size.x, parallaxHeight), // don't cover the floor area
    );

    // Place the parallax so its bottom sits on top of the floor
    parallax.anchor = Anchor.bottomLeft;
    parallax.position = Vector2(0, floorTopY);
    add(parallax);

    add(Floor(tileHeight: floorHeight));
    add(JumpButton());
    add(CrouchButton());
    assert(() {
      add(DiagnosticsOverlay());
      return true;
    }());
    await initializeGame();
  }

  @override
  Future<void> initializeGame() async {
    previousHighScore = await HighscoreManager.getHighscore('runner');
    gameState = GameState.playing;

    distanceMeters = 0.0;
    score = 0;

    speed = initialSpeed;
    spawnInterval = 1;
    difficultyClock = 0.0;

    _createObstacleTimer(spawnInterval);

    // add(Background());

    runner = Runner();
    add(runner);
  }

  void _createObstacleTimer(double interval) {
    obstacleTimer = Timer(interval, onTick: spawnRandomObstacle, repeat: true)
      ..start();
  }

  void _restartObstacleTimer(double interval) {
    obstacleTimer.stop();
    obstacleTimer = Timer(interval, onTick: spawnRandomObstacle, repeat: true)
      ..start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState != GameState.playing) return;

    // Distance-based score: convert pixels to meters
    // distanceMeters += (pixels traveled this frame) / pixelsPerMeter
    distanceMeters += (speed * dt) / pixelsPerMeter;
    score = distanceMeters.toInt(); // keep Score() component happy

    // Spawning & difficulty timing
    obstacleTimer.update(dt);

    difficultyClock += dt;
    if (difficultyClock >= rampEvery) {
      difficultyClock = 0.0;

      // 1) Increase world speed
      speed = (speed + speedStep).clamp(0, maxSpeed);

      // 2) Decrease spawn interval
      final next = (spawnInterval - spawnStep).clamp(minSpawnInterval, 10.0);
      if (next != spawnInterval) {
        spawnInterval = next;
        _restartObstacleTimer(spawnInterval);
      }
    }
  }

  void spawnRandomObstacle() {
    // Ensure Grumbluff spawns alone
    if (children.whereType<ObstacleGrumbluff>().isNotEmpty) return;

    final int type = _random.nextInt(4);
    // final int type = 1;
    late final Component obstacle;

    switch (type) {
      case 0:
        obstacle = ObstacleGrumbluff();
        break;
      case 1:
        obstacle = ObstacleFlyGuy();
        break;
      case 2:
        obstacle = ObstacleSpiky();
        break;
      case 3:
        obstacle = ObstacleFlyGuy();
        break;
      default:
        return;
    }
    add(obstacle);
  }

  void onPlayerCollision(PositionComponent other) {
    if (gameState == GameState.crashing) return;
    if (other is ObstacleTag) {
      gameState = GameState.crashing;
      runner.die();
      FlameAudio.play('die.mp3');
    }
  }

  @override
  void restart() {
    print('Total children: ${children.length}');
    // iterate components and filter by the tag
    for (final c in children.whereType<ObstacleTag>()) {
      (c as Component).removeFromParent();
    }
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
