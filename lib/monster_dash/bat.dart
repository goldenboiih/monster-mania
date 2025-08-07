import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/base_game.dart';

import 'monster_dash.dart';

class Bat extends SpriteAnimationComponent
    with HasGameReference<MonsterDash>, CollisionCallbacks {
  double jumpSpeed = -300;
  double velocityY = 0;
  double velocityX = 150;

  double angleLerpSpeed = 5;

  Bat() : super(size: Vector2(48, 48));

  bool _facingRight = true;

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x / 4, game.size.y / 4);
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

    if (game.gameState != GameState.playing &&
        game.gameState != GameState.crashing)
      return;

    // Y movement (gravity)
    velocityY += game.gravity * dt;
    y += velocityY * dt;

    // X movement (side-to-side bounce)
    x += velocityX * dt;

    // Bounce horizontally and flip sprite
    if (x <= 0 + width) {
      velocityX = velocityX.abs(); // go right
      _flipIfNeeded(true);
    } else if (x + width >= game.size.x) {
      velocityX = -velocityX.abs(); // go left
      _flipIfNeeded(false);
    }

    // Rotate sprite based on vertical speed
    if (game.gameState == GameState.crashing) {
      angle = lerpDouble(angle, 1.57, dt * 10)!;
    } else {
      final target = (velocityY / 400).clamp(-0.5, 0.5);
      angle = lerpDouble(angle, target, dt * angleLerpSpeed)!;
    }

    // Out of bounds check (bottom/top)
    if (y > game.size.y || y < -height) {
      removeFromParent();
      game.onGameOver();
    }
  }

  void flap() {
    if (game.gameState == GameState.playing) {
      velocityY = jumpSpeed;
    }
  }

  void startCrash() {
    animationTicker?.paused = true;
    velocityY = 0;
    velocityX = 0;
  }

  void _flipIfNeeded(bool facingRight) {
    if (_facingRight != facingRight) {
      game.increaseScore();
      flipHorizontallyAroundCenter();
      _facingRight = facingRight;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    game.onPlayerCollision(other);
  }
}
