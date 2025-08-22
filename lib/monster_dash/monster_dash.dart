import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/highscore_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flamegame/monster_dash/components/bat.dart';
import 'package:flamegame/monster_dash/components/brick_wall.dart';
import 'dart:math';

import 'components/carrot.dart';


class MonsterDash extends BaseGame with TapDetector, HasCollisionDetection {

  @override
  final VoidCallback? onExitToMenu;
  @override

  String get gameId => 'dash';

  MonsterDash({this.onExitToMenu});

  bool isPressing = false;

  // Difficulty tuning
  final gravity = 700;
  double initialSpeed = 150;
  double maxSpeed = 300;
  double speedStep = 5;
  static const int maxCarrots = 5;

  late Bat bat;

  late BrickWall leftWall;
  late BrickWall rightWall;

  late Timer _carrotTimer;
  final _rng = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    gameState = GameState.intro;
    scoreText.position = Vector2(size.x / 2 - scoreText.width / 2, 16);

    // Spawn a carrot every 1.2–2.0s
    _carrotTimer = Timer(
      1.2,
      onTick: _spawnCarrot,
      repeat: true,
    )..stop();

    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('dungeon_dash/bg.png'),
        // ParallaxImageData('clouds/1.png'),
        // ParallaxImageData('clouds/2.png'),
        // ParallaxImageData('clouds/3.png'),
        // ParallaxImageData('clouds/4.png'),
        // ParallaxImageData('clouds/5.png'),
      ],
      baseVelocity: Vector2(20, 0), // scroll right->left visually
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(1.0, 0.0),
      priority: -1,
    );

    add(parallax);

    final Sprite bg = await Sprite.load('dungeon_dash/bg.png');
    // add(SpriteComponent(sprite: bg, size: Vector2(size.x, size.y)));
    // add(SpriteComponent(sprite: bg, size: size));
    add(SpriteComponent(sprite: bg, size: size));
  }

  @override
  Future<void> initializeGame() async {
    previousHighScore = await HighscoreManager.getHighscore('dash');
    gameState = GameState.playing;
    score = 0;
    speed = initialSpeed;
    bat = Bat();
    add(bat);
    _carrotTimer.start();

    leftWall = BrickWall(left: true);
    rightWall = BrickWall(left: false);
    add(rightWall);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState == GameState.playing) {
      _carrotTimer.update(dt);
    }
  }

  @override
  void restart() {
    children.whereType<BrickWall>().forEach((c) => c.removeFromParent());
    children.whereType<Carrot>().forEach((c) => c.removeFromParent());
    initializeGame();
  }

  @override
  void onTapDown(TapDownInfo info) {
    bat.flap();
    isPressing = true;
  }

  @override
  void onTapUp(TapUpInfo info) {
    isPressing = false;
  }

  @override
  void onTapCancel() {
    isPressing = false;
  }

  void _stopCarrotSpawns() {
    if (_carrotTimer.isRunning()) _carrotTimer.stop();
  }

  void onPlayerCollision(PositionComponent other) {
    if (gameState == GameState.playing && other.parent is BrickWall) {
      _stopCarrotSpawns();
      FlameAudio.play('die.mp3');
      bat.startCrash();
      gameState = GameState.crashing;
    }
  }

  void onBatBounceLeftToRight() {
    leftWall.slideOut();
    rightWall = BrickWall(left: false);
    add(rightWall);
  }

  void onBatBounceRightToLeft() {
    rightWall.slideOut();
    leftWall = BrickWall(left: true);
    add(leftWall);
  }

  void increaseScore() {
    score++;
  }

  void _spawnCarrot() {
    if (gameState != GameState.playing) {
      _carrotTimer.stop();
      return;
    }

    // Check current number of carrots
    final carrotCount = children.whereType<Carrot>().length;
    if (carrotCount >= maxCarrots) {
      // Don’t spawn new ones, just reschedule timer
      final next = 1.2 + _rng.nextDouble() * 0.8;
      _carrotTimer
        ..stop()
        ..limit = next
        ..start();
      return;
    }

    // Safe margins
    const double topMargin = 48;
    const double bottomMargin = 48;
    final double y = _rng.nextDouble() * (size.y - topMargin - bottomMargin) + topMargin;

    // Spawn roughly in the corridor
    final double x = size.x * 0.5 + _rng.nextDouble() * 160 - 30;

    add(Carrot(position: Vector2(x, y)));

    // Reschedule next spawn
    final next = 1.2 + _rng.nextDouble() * 0.8;
    _carrotTimer
      ..stop()
      ..limit = next
      ..start();
  }


}
