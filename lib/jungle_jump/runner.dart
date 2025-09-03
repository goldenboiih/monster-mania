import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/jungle_jump/jungle_jump.dart';

import 'obstacles/obstacle_tag.dart';

class Runner extends SpriteAnimationComponent
    with HasGameReference<JungleJump>, CollisionCallbacks {
  Runner() : super() {
    size = Vector2(64, 64);
    debugMode = true;
    position.x = 150;
  }


  // Movement and physics
  double verticalSpeed = 0;
  final double defaultGravity = 4000;
  final double fastFallGravity = 8000;
  final double jumpForce = -950;
  late double gravity;

  double get groundY => game.size.y - game.floorHeight - (size.y / 2) + 2;

  // Dimensions
  final double normalHeight = 64;
  final double crouchHeight = 32;

  bool isCrouching = false;

  @override
  Future<void> onLoad() async {
    animation = await game.loadSpriteAnimation(
      'jungle_jump/blinko.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .1,
        textureSize: Vector2(48, 36),
      ),
    );

    anchor = Anchor.center;
    gravity = defaultGravity;

    add(RectangleHitbox());
  }

  bool get isOnGround => y >= groundY;

  void jump() {
    if (game.gameState == GameState.playing && isOnGround) {
      if (isCrouching) {
        stopCrouch(); // Stand up before jumping
      }
      FlameAudio.play('jump_1.mp3');
      verticalSpeed = jumpForce;
    }
  }

  void crouch() {
    if (game.gameState != GameState.playing) return;

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
    FlameAudio.play('hit.mp3');
    verticalSpeed = -300;
    animationTicker?.paused = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    verticalSpeed += gravity * dt;
    y += verticalSpeed * dt;

    if (game.gameState != GameState.crashing) {
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
    if (game.gameState == GameState.playing) {
      if (other is ObstacleTag) {
        game.onPlayerCollision(other);
        die();
      }
    }
  }
}
