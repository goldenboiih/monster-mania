import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/highscore_manager.dart';
import 'package:flutter/cupertino.dart';

import 'bat.dart';
import 'obstacles/brick_wall.dart';

class MonsterDash extends BaseGame with TapDetector, HasCollisionDetection {
  @override
  final VoidCallback? onExitToMenu;

  final gravity = 700;
  late Bat bat;

  late GameState gameState;

  late BrickWall leftWall;
  late BrickWall rightWall;

  MonsterDash({this.onExitToMenu});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    scoreText.position = Vector2(size.x / 2, 16);
    speed = 300;
    await initializeGame();
  }

  Future<void> initializeGame() async {
    gameState = GameState.playing;
    score = 0;
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
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onTap() {
    bat.flap();
  }

  Future<void> onGameOver() async {
    FlameAudio.play('die.mp3');
    previousHighScore = await HighscoreManager.getHighscore('dash');
    await HighscoreManager.saveHighscore('dash', score);
    highScore = await HighscoreManager.getHighscore('dash');
    bat.startCrash();
    overlays.add('GameOver');
    gameState = GameState.gameOver;
  }

  void onPlayerCollision(PositionComponent other) {
    if (gameState == GameState.playing && other.parent is BrickWall) {
      FlameAudio.play('die.mp3');
      bat.startCrash();
      gameState = GameState.crashing;
    }
  }
  void spawnLeftWall() {
    leftWall = BrickWall(left: true);
    add(leftWall);
  }

  void spawnRightWall() {
    rightWall = BrickWall(left: false);
    add(rightWall);
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
    FlameAudio.play('coin_2.mp3');
    score++;
  }
}
