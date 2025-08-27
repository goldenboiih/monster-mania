import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/dungeon_dash/components/brick_wall.dart';
import 'package:flamegame/dungeon_dash/dungeon_dash.dart';
import 'carrot.dart';

class Bat extends SpriteAnimationComponent
    with HasGameReference<DungeonDash>, CollisionCallbacks {
  double flapSpeed = -256;
  double velocityY = 0;
  late double velocityX;

  double angleLerpSpeed = 5;
  final double climbSpeed = 260;

  Bat() : super(size: Vector2(28 * 2.2, 19 * 2.2));
  late bool _facingRight;
  final Random _random = Random();

  // --- New: crash timer + guard ---
  late Timer _crashTimer;
  bool _gameOverTriggered = false;

  bool get isFacingRight => _facingRight;

  @override
  Future<void> onLoad() async {
    _facingRight = true;
    velocityX = game.speed;
    position = Vector2(game.size.x / 4, game.size.y / 4);

    // Init crash timer (fire once, e.g. after 0.8s)
    _crashTimer = Timer(0.6, onTick: _triggerGameOver)..stop();

    await super.onLoad();
    animation = await game.loadSpriteAnimation(
      'dungeon_dash/boom_bat.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: .1,
        textureSize: Vector2(28, 19),
      ),
    );
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update crash timer regardless of state (safe no-op if not started)
    _crashTimer.update(dt);

    // --- Vertical motion ---
    if (game.gameState == GameState.playing) {
      if (game.isPressing) {
        velocityY = lerpDouble(velocityY, -climbSpeed, dt * 10)!;
      } else {
        velocityY += game.gravity * dt;
      }
    } else if (game.gameState == GameState.crashing ||
        game.gameState == GameState.gameOver) {
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

    // Fallback: if it leaves screen before timer, still end the game once
    if ((y > game.size.y || y < -height) && !_gameOverTriggered) {
      removeFromParent();
      _triggerGameOver();
    }
  }

  void flap() {
    if (game.gameState == GameState.playing) {
      velocityY = flapSpeed;
    }
  }

  void startCrash() {
    // Freeze animation and horizontal motion immediately
    animationTicker?.paused = true;
    velocityY = 0;
    velocityX = 0;

    // Start the crash timer (restarts if called again)
    _crashTimer.stop();
    _crashTimer.start();
  }

  void _flipIfNeeded(bool facingRight) {
    if (_facingRight != facingRight) {
      game.increaseScore();
      FlameAudio.play('click.mp3');
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

  void _triggerGameOver() {
    if (_gameOverTriggered) return;
    _gameOverTriggered = true;

    FlameAudio.play('fall_2.mp3');
    game.onGameOver(); // show game over overlay
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (game.gameState == GameState.playing) {
      if (other is Carrot) {
        FlameAudio.play('eat_${_random.nextInt(4)}.mp3');
        other.collect();
      } else if (other.parent is BrickWall) {
        game.onPlayerCollision(other);
      }
    }
  }

  @override
  void onRemove() {
    _crashTimer.stop();
    super.onRemove();
  }
}
