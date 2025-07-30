import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flamegame/endless_runner/runner_game.dart';
import 'package:flamegame/endless_runner/obstacles/grumbluff_drop.dart';

import 'obstacles/obstacle_floaty.dart';
import 'obstacles/obstacle_grumbluff.dart';
import 'obstacles/obstacle_spiky.dart';

class Player extends SpriteAnimationComponent
    with HasGameReference<EndlessRunnerGame>, CollisionCallbacks {
  double verticalSpeed = 0;
  double gravity = 1000;
  double jumpForce = -400;
  final double groundY = 283;

  bool isDead = false;

  Player() : super(size: Vector2(64, 64), position: Vector2(100, 100));

  @override
  Future<void> onLoad() async {
    final images = await Future.wait([
      game.images.load('monster_blue/sprite_0.png'),
      game.images.load('monster_blue/sprite_1.png'),
      game.images.load('monster_blue/sprite_2.png'),
      game.images.load('monster_blue/sprite_3.png'),
      game.images.load('monster_blue/sprite_4.png'),
      game.images.load('monster_blue/sprite_5.png'),
      game.images.load('monster_blue/sprite_6.png'),
    ]);

    animation = SpriteAnimation.spriteList(
      images.map((img) => Sprite(img)).toList(),
      stepTime: 0.1,
    );

    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  void jump() {
    if (y >= groundY && !isDead) {
      verticalSpeed = jumpForce;
    }
  }

  void die() {
    if (isDead) return;
    isDead = true;
    verticalSpeed = -300; // hurled upward
    animationTicker?.paused = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    verticalSpeed += gravity * dt;
    y += verticalSpeed * dt;

    if (!isDead) {
      if (y >= groundY) {
        y = groundY;
        verticalSpeed = 0;
      }
    } else {
      angle += 2 * dt; // optional: rotate while falling
      if (y > game.size.y + height) {
        game.onPlayerOutOfBounds();
        removeFromParent(); // remove when off screen
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (!isDead &&
        (other is ObstacleSpiky ||
            other is ObstacleFloaty ||
            other is ObstacleGrumbluff ||
            other is GrumbluffDrop)) {
      die();
      game.onPlayerCollision();
    }
  }
}
