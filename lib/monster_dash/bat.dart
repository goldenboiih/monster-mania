import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/util/utils.dart';

import 'monster_dash.dart';

class Bat extends SpriteAnimationComponent
    with HasGameReference<MonsterDash>, CollisionCallbacks {
  double flapSpeed = -256;
  double velocityY = 0;
  double velocityX = 150;

  double angleLerpSpeed = 5;
  final double climbSpeed = 260;

  Bat() : super(size: Vector2(48, 48));
  late bool _facingRight;

  bool get isFacingRight => _facingRight;

  @override
  Future<void> onLoad() async {
    _facingRight = true;

    position = Vector2(game.size.x / 4, game.size.y / 4);
    await super.onLoad();
    animation = await loadSpriteAnimation(
      images: [
        'flappy/flappy_1.png',
        'flappy/flappy_2.png',
        'flappy/flappy_3.png',
      ],
      stepTime: 0.1,
    );
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.gameState != GameState.playing && game.gameState != GameState.crashing) return;

    // --- Vertical motion ---
    if (game.gameState == GameState.playing) {
      if (game.isPressing) {
        // Smoothly steer vertical speed toward upward target
        velocityY = lerpDouble(velocityY, -climbSpeed, dt * 10)!;
      } else {
        // Gravity only when not pressing
        velocityY += game.gravity * dt;
      }
    } else {
      // Crashing: pure gravity
      velocityY += game.gravity * dt;
    }
    y += velocityY * dt;

    // --- Horizontal motion (unchanged) ---
    x += velocityX * dt;
    if (x <= 0 + width) {
      velocityX = velocityX.abs();
      _flipIfNeeded(true);
    } else if (x + width >= game.size.x) {
      velocityX = -velocityX.abs();
      _flipIfNeeded(false);
    }

    // --- Tilt ---
    if (game.gameState == GameState.crashing) {
      angle = lerpDouble(angle, 1.57, dt * 10)!;
    } else {
      final target = (velocityY / 400).clamp(-0.5, 0.5);
      angle = lerpDouble(angle, target, dt * angleLerpSpeed)!;
    }

    // --- Bounds check ---
    if (y > game.size.y || y < -height) {
      removeFromParent();
      game.onGameOver();
    }
  }

  void flap() {
    if (game.gameState == GameState.playing) {
      velocityY = flapSpeed;
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

      // Tell the game to manage walls
      if (_facingRight) {
        game.onBatBounceLeftToRight();
      } else {
        game.onBatBounceRightToLeft();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    game.onPlayerCollision(other);
  }
}
