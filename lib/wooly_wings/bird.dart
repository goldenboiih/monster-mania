import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';

import 'wooly_wings.dart';

class Bird extends SpriteAnimationComponent
    with HasGameReference<WoolyWings>, CollisionCallbacks {
  double jumpSpeed = -200;
  double velocityY = 0;

  double targetAngle = 0;
  double angleLerpSpeed = 5; // Higher = faster reaction, lower = smoother

  Bird() : super(size: Vector2(48, 48));

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x / 8, game.size.y / 4);
    await super.onLoad();
    animation = await game.loadSpriteAnimation(
      'flappy/bird.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .1,
        textureSize: Vector2(29, 26),
      ),
    );
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Gravity
    if (game.gameState != GameState.intro) {
      velocityY += game.gravity * dt;
      y += velocityY * dt;
    }

    if (game.gameState == GameState.crashing) {
      // Smoothly rotate to downward facing
      angle = lerpDouble(angle, 1.57, dt * 10)!;
    } else {
      // Tilt based on speed
      final target = (velocityY / 400).clamp(-0.5, 0.5);
      angle = lerpDouble(angle, target, dt * 5)!;
    }

    // End game when out of bounds
    if (y > game.size.y || y < -height) {
      FlameAudio.play('fall_2.mp3');
      removeFromParent();
      game.onGameOver();
    }
  }

  void flap() {
    if (game.gameState == GameState.playing) {
      velocityY = jumpSpeed;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    game.onPlayerCollision(other);
  }

  void startCrash() {
    animationTicker?.paused = true;
    velocityY = 0; // cancel any upward momentum
  }
}
