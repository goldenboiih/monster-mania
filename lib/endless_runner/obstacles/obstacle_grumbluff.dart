import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/endless_runner/runner_game.dart';

import 'grumbluff_drop.dart';

enum GrumbluffState { floatingIn, dropping, escapingRight, descending, chargingLeft }

class ObstacleGrumbluff extends SpriteAnimationGroupComponent<GrumbluffState>
    with HasGameReference<EndlessRunnerGame> {
  final double floatAmplitude = 6.0;
  final double floatSpeed = 4.0;
  final double floorY = 311;
  final double dropTriggerX = 500;
  final double escapeTriggerX = 600;

  late double baseY;
  double floatTime = 0.0;

  int totalDrops = 0;
  int dropsRemaining = 0;

  late Timer dropIdleTimer;

  ObstacleGrumbluff()
      : super(
    size: Vector2(70, 70),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x + width, game.size.y / 5);
    baseY = y;

    // Load animations and static sprites

    final sprite_idle = await Sprite.load('grumbluff/grumbluff_idle.png');
    final sprite_0 = await Sprite.load('grumbluff/grumbluff_throw_0.png');
    final sprite_1 = await Sprite.load('grumbluff/grumbluff_throw_1.png');
    final sprite_2 = await Sprite.load('grumbluff/grumbluff_throw_2.png');
    final dropAnimation = SpriteAnimation.spriteList([sprite_0, sprite_1, sprite_2], stepTime: 0.15);


    // Assign animations per state
    animations = {
      GrumbluffState.floatingIn: SpriteAnimation.spriteList([sprite_0], stepTime: double.infinity),
      GrumbluffState.dropping: dropAnimation,
      GrumbluffState.escapingRight: SpriteAnimation.spriteList([sprite_idle], stepTime: double.infinity),
      GrumbluffState.descending: SpriteAnimation.spriteList([sprite_2], stepTime: double.infinity),
      GrumbluffState.chargingLeft: SpriteAnimation.spriteList([sprite_1], stepTime: double.infinity),
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
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void startDropping() {
    current = GrumbluffState.dropping;
    performDrop();
  }

  void performDrop() {
    game.add(GrumbluffDrop(position.clone() + Vector2(0, size.y / 2)));
    dropsRemaining--;

    if (dropsRemaining > 0) {
      dropIdleTimer = Timer(
        Random().nextDouble() * 1 + 0.5,
        onTick: performDrop,
        repeat: false,
      )..start();
    } else {
      dropIdleTimer = Timer(
        Random().nextDouble() * 1 + 0.5,
        onTick: () {
          current = GrumbluffState.escapingRight;
        },
        repeat: false,
      )..start();
    }
  }
}
