import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/ui/menu_button.dart';
import 'package:flamegame/ui/score.dart';
import 'package:flamegame/world/background.dart';
import 'package:flamegame/world/floor.dart';

import 'obstacles/pipe_pair.dart';
import 'player.dart';

enum GameState { playing, crashing, gameOver }

class FlappyGame extends BaseGame with TapDetector, HasCollisionDetection {
  @override
  final VoidCallback? onExitToMenu;

  late Player bird;
  late Timer obstacleTimer;

  late GameState gameState;

  FlappyGame({this.onExitToMenu});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await initializeGame();
  }

  Future<void> initializeGame() async {
    gameState = GameState.playing;
    speed = 200;
    score = 0;

    // TODO: simplify position
    bird = Player()..position = Vector2(size.x / 8, size.y / 2);
    add(bird);
    add(Floor(hasHitBox: true));
    add(Background());

    obstacleTimer = Timer(1, repeat: true, onTick: spawnPipePair);
    obstacleTimer.start();
    add(MenuButton(onPressed: onExitToMenu));
    add(Score());
  }

  void spawnPipePair() {
    final double pipeWidth = 48;
    final verticalCenter = Random().nextDouble() * (size.y - 200) + 100;
    add(PipePair(
      position: Vector2(size.x + pipeWidth, verticalCenter),
      gap: 128,
      pipeWidth: pipeWidth,
    ));
  }

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
    obstacleTimer.update(dt);
    // if (gameState == GameState.playing) {
    //   super.update(dt);
    //   obstacleTimer.update(dt);
    // }
  }

  @override
  void onTap() {
    if (gameState == GameState.playing) {
      bird.jump();
    }
  }

  void onPlayerOutOfBounds() {
    if (gameState == GameState.playing) {
      FlameAudio.play('die.mp3');
      overlays.add('GameOver');
    } else if (gameState == GameState.crashing) {
    }
    gameState = GameState.gameOver;
  }

  void onPlayerCollision() {
    if (gameState == GameState.playing) {
      FlameAudio.play('die.mp3');
      gameState = GameState.crashing;
      overlays.add('GameOver');
      bird.startCrash();
    }
  }

  void increaseScore() {
    FlameAudio.play('coin_2.mp3');
    score++;
  }
}
