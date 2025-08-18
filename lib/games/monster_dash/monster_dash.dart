import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/games/base_game.dart';
import 'package:flamegame/highscore_manager.dart';
import 'package:flutter/cupertino.dart';

import 'bat.dart';
import 'obstacles/brick_wall.dart';

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

  late Bat bat;

  late BrickWall leftWall;
  late BrickWall rightWall;


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    scoreText.position = Vector2(size.x / 2 - scoreText.width / 2, 16);
    await initializeGame();
  }

  @override
  Future<void> initializeGame() async {
    previousHighScore = await HighscoreManager.getHighscore('dash');
    gameState = GameState.playing;
    score = 0;
    speed = initialSpeed;
    bat = Bat();
    add(bat);
    leftWall = BrickWall(left: true);
    rightWall = BrickWall(left: false);
    add(rightWall);
  }

  @override
  void restart() {
    children.whereType<BrickWall>().forEach((c) => c.removeFromParent());
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

  void onPlayerCollision(PositionComponent other) {
    if (gameState == GameState.playing && other.parent is BrickWall) {
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
    FlameAudio.play('click.mp3');
    score++;
  }
}
