import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/wooly_wings/wooly_wings_game.dart';


class Wooly extends SpriteAnimationComponent
    with HasGameReference<WoolyWings>, CollisionCallbacks {
  double jumpSpeed = -200;
  double velocityY = 0;

  double targetAngle = 0;
  double angleLerpSpeed = 5; // Higher = faster reaction, lower = smoother

  Wooly() : super(size: Vector2(48, 48));

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x / 8, game.size.y / 4);
    await super.onLoad();
    final images = await Future.wait([
      game.images.load('flappy/flappy_1.png'),
      game.images.load('flappy/flappy_2.png'),
      game.images.load('flappy/flappy_3.png'),
    ]);
    animation = SpriteAnimation.spriteList(
      images.map((img) => Sprite(img)).toList(),
      stepTime: 0.1,
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
