import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/world/floor.dart';

import 'flappy_game.dart';
import 'obstacles/pipe.dart';

class Player extends SpriteAnimationComponent
    with HasGameReference<FlappyGame>, CollisionCallbacks {
  double gravity = 500;
  double jumpSpeed = -200;
  double velocityY = 0;

  double targetAngle = 0;
  double angleLerpSpeed = 5; // Higher = faster reaction, lower = smoother
  bool isCrashing = false;

  Player() : super(size: Vector2(48, 48));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final images = await Future.wait([
      game.images.load('flappy/flappy_down.png'),
      game.images.load('flappy/flappy_mid.png'),
      game.images.load('flappy/flappy_up.png'),
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
    velocityY += gravity * dt;
    y += velocityY * dt;

    if (isCrashing) {
      // Smoothly rotate to downward facing
      angle = lerpDouble(angle, 1.57, dt * 10)!;
    } else {
      // Tilt based on speed
      final target = (velocityY / 400).clamp(-0.5, 0.5);
      angle = lerpDouble(angle, target, dt * 5)!;
    }

    // End game when out of bounds
    if (y > game.size.y || y < -height) {
      game.onPlayerOutOfBounds();
    }
  }

  void jump() {
    if (!isCrashing) {
      velocityY = jumpSpeed;
    }
  }


  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Pipe || other.parent is Floor) {
      game.onPlayerCollision();
    }
  }

  void startCrash() {
    isCrashing = true;
    velocityY = 0; // cancel any upward momentum
  }

}
