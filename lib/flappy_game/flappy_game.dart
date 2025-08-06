import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/ui/menu_button.dart';
import 'package:flamegame/ui/score.dart';
import 'package:flutter/cupertino.dart';

import '../highscore_manager.dart';
import 'bird.dart';
import 'obstacles/pipe_pair.dart';

class FlappyGame extends BaseGame with TapDetector, HasCollisionDetection {
  @override
  final VoidCallback? onExitToMenu;

  final double floorHeight = 64;
  final double pipeSpacing = 256;
  final gravity = 512;
  late Bird bird;
  late Timer obstacleTimer;

  late GameState gameState;
  late double distanceSinceLastPipe;

  FlappyGame({this.onExitToMenu});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await initializeGame();
    FlameAudio.bgm.play('energy_theme_jextor_bg.wav', volume: 0.5);
  }

  @override
  void onAttach() {
    super.onAttach();
    FlameAudio.bgm.play('energy_theme_jextor_bg.wav', volume: 0.5);
  }

  @override
  void onDetach() {
    super.onDetach();
    FlameAudio.bgm.stop();
  }

  Future<void> initializeGame() async {
    gameState = GameState.playing;
    speed = 200;
    score = 0;
    distanceSinceLastPipe = 0;

    bird = Bird();
    add(bird);
    final parallax = await loadParallaxComponent(
      [ParallaxImageData('flappy/background.png')],
      baseVelocity: Vector2(20, 0), // horizontal scroll to the right
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(1.0, 0.0),
      priority: -1, // ensure it renders in the background
    );
    add(parallax);

    add(MenuButton(onPressed: onExitToMenu));
    add(Score());
  }

  void spawnPipePair() {
    final double pipeWidth = 48;
    final verticalCenter = Random().nextDouble() * (size.y - 200) + 100;
    add(
      PipePair(
        position: Vector2(size.x + pipeWidth, verticalCenter),
        gap: 128,
        pipeWidth: pipeWidth,
      ),
    );
  }

  @override
  void restart() {
    children.whereType<Component>().forEach((c) => c.removeFromParent());
    Future.delayed(const Duration(milliseconds: 0), () async {
      await initializeGame();
      resumeEngine();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    final movedDistance = speed * dt;
    distanceSinceLastPipe += movedDistance;

    if (distanceSinceLastPipe >= pipeSpacing) {
      spawnPipePair();
      distanceSinceLastPipe = 0;
    }
  }

  @override
  void onTap() {
    bird.jump();
  }

  Future<void> onGameOver() async {
    await HighscoreManager.saveHighscore('flappy', score);
    highScore = await HighscoreManager.getHighscore('flappy');
    bird.startCrash();
    overlays.add('GameOver');

    gameState = GameState.gameOver;
  }

  void onPlayerCollision() {
    if (gameState == GameState.playing) {
      gameState = GameState.crashing;
      overlays.add('GameOver');
      bird.startCrash();
    }
  }

  void increaseScore() {
    FlameAudio.play('coin_2.mp3');
    score++;
    // speed += 10;
  }

}
