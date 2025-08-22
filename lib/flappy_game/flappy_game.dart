import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/highscore_manager.dart';
import 'package:flutter/cupertino.dart';

import 'bird.dart';
import 'obstacles/pipe.dart';
import 'obstacles/pipe_pair.dart';

class FlappyGame extends BaseGame with TapDetector, HasCollisionDetection {
  @override
  final VoidCallback? onExitToMenu;

  @override
  String get gameId => 'flappy';

  bool hasShownIntro = false;

  final double floorHeight = 64;
  final double pipeSpacing = 256;
  final gravity = 512;
  final double initialSpeed = 256;

  late Bird bird;

  // Spawn pacing
  late double distanceSinceLastPipe;

  // Fairness & difficulty knobs
  final _rng = Random();
  double _lastCenterY = 0;
  int _sinceLastMover = 999; // big so early ones can move

  // Config
  final double _pipeWidth = 64;
  final double _edgeMargin = 80; // keep gap away from top/bottom
  final double _maxCenterDelta = 140; // limit vertical hop between pairs
  final double _minGap = 110;
  final double _maxGap = 150;

  FlappyGame({this.onExitToMenu});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await initializeGame();

    // Parallax background behind everything
    final parallax = await loadParallaxComponent(
      [ParallaxImageData('flappy/background.png')],
      baseVelocity: Vector2(20, 0), // scroll right->left visually
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(1.0, 0.0),
      priority: -1,
    );
    add(parallax);
  }

  @override
  Future<void> initializeGame() async {
    previousHighScore = await HighscoreManager.getHighscore('flappy');
    if (!hasShownIntro) {
      gameState = GameState.intro;
      speed = 0;
    } else {
      gameState = GameState.playing;
      speed = initialSpeed;
    }

    score = 0;
    distanceSinceLastPipe = 0;

    bird = Bird();
    add(bird);

    _lastCenterY = size.y * 0.5;

    // Spawn first pipes immediately
    if (gameState == GameState.playing) {
      _spawnPipePair();
    }
  }

  void startFromIntro() {
    if (gameState == GameState.intro) {
      speed = initialSpeed;
      _spawnPipePair();
      gameState = GameState.playing;
      hasShownIntro = true;
    }
  }

  // ======== SPAWNING LOGIC ========
  void _spawnPipePair() {
    // 1) Gap scales with score (harder over time, within bounds)
    final targetGap =
        (_maxGap - min(30, score * 2)).clamp(_minGap, _maxGap).toDouble();

    // 2) Pick a new center Y with limited vertical jump from previous
    final minCenter = targetGap / 2 + _edgeMargin;
    final maxCenter = size.y - targetGap / 2 - _edgeMargin;
    final proposedCenter =
        _lastCenterY + (_rng.nextDouble() * 2 - 1) * _maxCenterDelta;
    final centerY = proposedCenter.clamp(minCenter, maxCenter);
    _lastCenterY = centerY;

    // 3) Decide if this pair moves (fair, with cooldown)
    //    Base chance grows a bit with score, but capped; forced cooldown after a mover.
    final baseMoveChance = (0.20 + score * 0.01).clamp(0.20, 0.55);
    final canMove =
        _sinceLastMover >= 2; // require at least 2 static between movers
    final willMove = canMove && (_rng.nextDouble() < baseMoveChance);

    // 4) If moving, pick sane amplitude & speed, clamped so we don’t hit edges
    double oscillationAmplitude = 0;
    double oscillationSpeed = 0;
    if (willMove) {
      oscillationSpeed = 0.25 + _rng.nextDouble() * 0.35; // 0.25–0.60 Hz
      // request 30–70px but clamp so center ± amp stays within safe band
      final requestedAmp = 30 + _rng.nextDouble() * 40;
      final allowedTop = centerY - (targetGap / 2 + _edgeMargin);
      final allowedBottom = (size.y - targetGap / 2 - _edgeMargin) - centerY;
      oscillationAmplitude = max(
        0,
        min(requestedAmp, min(allowedTop, allowedBottom)),
      );
    }

    // 5) Track mover cooldown
    if (oscillationAmplitude > 0) {
      _sinceLastMover = 0;
    } else {
      _sinceLastMover++;
    }

    // 6) Actually add the pair
    add(
      PipePair(
        position: Vector2(size.x + _pipeWidth, centerY),
        gap: targetGap,
        pipeWidth: _pipeWidth,
        // Movement is optional—0 disables it
        oscillationAmplitude: oscillationAmplitude,
        oscillationSpeed: oscillationSpeed,
      ),
    );
  }

  @override
  void restart() {
    // Keep background (priority -1) but remove pipes & bird
    children.whereType<PipePair>().forEach((c) => c.removeFromParent());
    children.whereType<Pipe>().forEach((c) => c.removeFromParent());
    children.whereType<Bird>().forEach((c) => c.removeFromParent());
    initializeGame();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Distance-based pacing—independent from frame rate
    final moved = speed * dt;
    distanceSinceLastPipe += moved;
    if (distanceSinceLastPipe >= pipeSpacing) {
      distanceSinceLastPipe = 0;
      _spawnPipePair();
    }
  }

  @override
  void onTap() {
    if (gameState == GameState.playing) {
      bird.flap();
    }
  }

  void onPlayerCollision(PositionComponent other) {
    if (gameState == GameState.playing && other is Pipe) {
      FlameAudio.play('die.mp3');
      bird.startCrash();
      gameState = GameState.crashing;
    }
  }

  void increaseScore() {
    FlameAudio.play('coin_2.mp3');
    score++;
  }
}
