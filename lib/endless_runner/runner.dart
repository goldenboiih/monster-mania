import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/endless_runner/obstacles/obstacle_fly_guy.dart';
import 'package:flamegame/endless_runner/runner_game.dart';

import 'obstacles/obstacle.dart';

class Runner extends SpriteAnimationComponent
    with HasGameReference<EndlessRunnerGame>, CollisionCallbacks {
  // Movement and physics
  double verticalSpeed = 0;
  final double defaultGravity = 1000;
  final double fastFallGravity = 4000;
  final double jumpForce = -400;
  late double gravity;

  double get groundY => game.size.y - game.floorHeight - (size.y / 2);

  // Dimensions
  final double normalHeight = 64;
  final double crouchHeight = 32;

  bool isDead = false;
  bool isCrouching = false;

  Runner() : super(size: Vector2(64, 64), position: Vector2(100, 100));

  @override
  Future<void> onLoad() async {
    final images = await Future.wait([
      for (int i = 0; i <= 6; i++)
        game.images.load('monster_blue/sprite_$i.png'),
    ]);

    animation = SpriteAnimation.spriteList(
      images.map((img) => Sprite(img)).toList(),
      stepTime: 0.1,
    );

    anchor = Anchor.center;
    gravity = defaultGravity;

    add(RectangleHitbox());
  }

  bool get isOnGround => y >= groundY;


  void jump() {
    if (!isDead && isOnGround) {
      if (isCrouching) {
        stopCrouch(); // Stand up before jumping
      }
      verticalSpeed = jumpForce;
    }
  }


  void crouch() {
    if (isDead) return;

    if (!isOnGround) {
      // Already in the air — apply fast-fall gravity
      gravity = fastFallGravity;
    } else if (!isCrouching && verticalSpeed == 0) {
      // Only crouch if on ground and not moving vertically
      isCrouching = true;
      size.y = crouchHeight;
      position.y += (normalHeight - crouchHeight) / 2;
    }
  }


  void stopCrouch() {
    gravity = defaultGravity;

    if (isOnGround && isCrouching) {
      position.y -= (normalHeight - crouchHeight) / 2;
      size.y = normalHeight;
      isCrouching = false;
    }
  }

  void die() {
    if (isDead) return;
    isDead = true;
    verticalSpeed = -300;
    animationTicker?.paused = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    verticalSpeed += gravity * dt;
    y += verticalSpeed * dt;

    if (!isDead) {
      if (isOnGround) {
        y = groundY;
        verticalSpeed = 0;
        gravity = defaultGravity; // reset gravity after fast-fall
      }
    } else {
      angle += 6 * dt;

      if (y > game.size.y + height) {
        game.onGameOver();
        removeFromParent();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (isDead) return;

    if (other is Obstacle || other is ObstacleFlyGuy) {
      die();
      game.onPlayerCollision();
    }
  }
}
