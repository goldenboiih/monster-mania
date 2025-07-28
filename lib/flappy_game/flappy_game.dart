import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/endless_runner/ui/menu_button.dart';

import 'obstacles/pipe_pair.dart';
import 'player.dart';

enum GameState { playing, crashing, gameOver }

class FlappyGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Player bird;
  late Timer obstacleTimer;

  late Sprite topCap;
  late Sprite bodySegment;

  final VoidCallback? onExitToMenu;
  late GameState gameState;

  FlappyGame({this.onExitToMenu});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await initializeGame();
  }

  Future<void> initializeGame() async {
    gameState = GameState.playing;
    spawnPlayer();

    obstacleTimer = Timer(1, repeat: true, onTick: spawnPipePair);
    obstacleTimer.start();

    add(MenuButton(onPressed: onExitToMenu));
  }

  void spawnPlayer() {
    bird = Player()..position = Vector2(size.x / 8, size.y / 2);
    add(bird);
  }

  void spawnPipePair() {
    add(PipePair(position: Vector2(0, 100), gap: 200, pipeWidth: 32));
  }

  void onPlayerCollision() {
    if (gameState == GameState.playing) {
      FlameAudio.play('die.mp3');
      gameState = GameState.crashing;
      bird.startCrash();
    }
  }

  void restart() {
    children.whereType<Component>().forEach((c) => c.removeFromParent());

    Future.delayed(const Duration(milliseconds: 0), () async {
      await initializeGame();
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
    restart();
  }
}
