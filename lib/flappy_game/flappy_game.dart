import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/ui/menu_button.dart';
import 'package:flamegame/world/floor.dart';

import 'obstacles/pipe_pair.dart';
import 'player.dart';

enum GameState { playing, crashing, gameOver }

class FlappyGame extends BaseGame with TapDetector, HasCollisionDetection {
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
    speed = 200;

    // TODO: simplify position
    bird = Player()..position = Vector2(size.x / 8, size.y / 2);
    add(bird);
    add(Floor());

    obstacleTimer = Timer(1, repeat: true, onTick: spawnPipePair);
    obstacleTimer.start();
    add(MenuButton(onPressed: onExitToMenu));
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
    if (gameState == GameState.playing) {
      FlameAudio.play('die.mp3');
    }
    restart();
  }
}
