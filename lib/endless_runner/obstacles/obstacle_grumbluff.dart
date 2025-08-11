import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/endless_runner/runner_game.dart';
import 'grumbluff_drop.dart';
import 'obstacle_tag.dart';

enum GrumbluffState { floatingIn, dropping, escapingRight, descending, chargingLeft }

class ObstacleGrumbluff extends SpriteAnimationGroupComponent<GrumbluffState>
    with HasGameReference<EndlessRunnerGame>, ObstacleTag{
  final double floatAmplitude = 6.0;
  final double floatSpeed = 4.0;
  final double floorY = 311;
  final double dropTriggerX = 500;
  final double escapeTriggerX = 600;

  late double baseY;
  double floatTime = 0.0;

  int totalDrops = 0;
  late int dropsRemaining;

  late Timer dropIdleTimer;
  late bool skipDescend; // 40% chance to skip the descend path

  ObstacleGrumbluff()
      : super(
    size: Vector2(70, 70),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x + width, game.size.y / 5);
    baseY = y;

    // Decide once per instance
    skipDescend = Random().nextDouble() < 0.4;

    // Load animations and static sprites
    final spriteIdle = await Sprite.load('grumbluff/grumbluff_idle.png');
    final sprite0 = await Sprite.load('grumbluff/grumbluff_throw_0.png');
    final sprite1 = await Sprite.load('grumbluff/grumbluff_throw_1.png');
    final sprite2 = await Sprite.load('grumbluff/grumbluff_throw_2.png');

    final dropAnimation = SpriteAnimation.spriteList(
      [sprite0, sprite1, sprite2],
      stepTime: 0.05,
      loop: false,
    );

    animations = {
      GrumbluffState.floatingIn: SpriteAnimation.spriteList([sprite0], stepTime: double.infinity),
      GrumbluffState.dropping: dropAnimation,
      GrumbluffState.escapingRight: SpriteAnimation.spriteList([spriteIdle], stepTime: double.infinity),
      GrumbluffState.descending: SpriteAnimation.spriteList([sprite2], stepTime: double.infinity),
      GrumbluffState.chargingLeft: SpriteAnimation.spriteList([sprite1], stepTime: double.infinity),
    };

    current = GrumbluffState.floatingIn;

    totalDrops = Random().nextInt(3) + 1;
    dropsRemaining = totalDrops;

    dropIdleTimer = Timer(0);

    add(RectangleHitbox.relative(Vector2.all(0.7), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    dropIdleTimer.update(dt);

    switch (current) {
      case GrumbluffState.floatingIn:
        x -= (game.speed + 100) * dt;
        floatTime += dt;
        y = baseY + sin(floatTime * floatSpeed) * floatAmplitude;
        if (x <= dropTriggerX) {
          startDropping();
        }
        break;

      case GrumbluffState.dropping:
        floatTime += dt;
        y = baseY + sin(floatTime * floatSpeed) * floatAmplitude;
        break;

      case GrumbluffState.escapingRight:
        x += game.speed * dt;
        floatTime += dt;
        y = baseY + sin(floatTime * floatSpeed) * floatAmplitude;
        if (x >= escapeTriggerX) {
          current = GrumbluffState.descending;
        }
        break;

      case GrumbluffState.descending:
        y += game.speed * dt;
        if (y >= floorY - size.y / 2) {
          current = GrumbluffState.chargingLeft;
        }
        break;

      case GrumbluffState.chargingLeft:
        x -= game.speed * 2 * dt;
        if (x < -width) {
          removeFromParent();
        }
        break;
      case null:
        throw UnimplementedError();
    }
  }

  void startDropping() {
    // Always play the dropping animation from start
    current = GrumbluffState.dropping;

    // Calculate how long the drop animation takes
    final double animDuration =
        (animations![GrumbluffState.dropping]?.frames.length ?? 0) *
            (0.05);
    animationTicker?.reset();
    // After animation finishes, spawn the drop
    dropIdleTimer = Timer(animDuration, onTick: () {
      game.add(GrumbluffDrop(position.clone() + Vector2(0, size.y / 2)));
      dropsRemaining--;

      if (dropsRemaining > 0) {
        // Wait before starting next throw animation
        dropIdleTimer = Timer(
          Random().nextDouble() * 0.5 + 0.5,
          onTick: startDropping,
          repeat: false,
        )..start();
      } else {
        // Finished all drops → either skip descend or escape right
        dropIdleTimer = Timer(
          Random().nextDouble() * 0.5 + 0.5,
          onTick: () {
            current = skipDescend
                ? GrumbluffState.chargingLeft
                : GrumbluffState.escapingRight;
          },
          repeat: false,
        )..start();
      }
    }, repeat: false)..start();
  }

}
