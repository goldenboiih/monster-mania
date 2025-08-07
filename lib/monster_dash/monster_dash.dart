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

  final double floorHeight = 64;
  final double pipeSpacing = 256;
  final gravity = 700;
  late Bat bat;
  late Timer obstacleTimer;

  late GameState gameState;

  MonsterDash({this.onExitToMenu});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await initializeGame();
  }

  Future<void> initializeGame() async {
    gameState = GameState.playing;
    speed = 300;
    score = 0;
    bat = Bat();
    add(bat);
    final wall = BrickWall(left: true);
    final wall2 = BrickWall(left: false);
    add(wall);
    add(wall2);
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

  void increaseScore() {
    FlameAudio.play('coin_2.mp3');
    score++;
  }
}
