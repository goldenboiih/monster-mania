import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/timer.dart';
import 'package:flamegame/endless_runner/runner_game.dart';
import 'package:flamegame/endless_runner/obstacles/obstacle.dart';
import 'grumbluff_drop.dart';

enum GrumbluffState { floatingIn, dropping, escapingRight, descending, chargingLeft }

class ObstacleGrumbluff extends Obstacle
    with HasGameReference<EndlessRunnerGame> {

  final Random random = Random();
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

  GrumbluffState state = GrumbluffState.floatingIn;

  ObstacleGrumbluff()
      : super(
    size: Vector2(64, 64),
    position: Vector2(800, 100),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('grumbluff/grumbluff_32x32.png');
    add(RectangleHitbox.relative(Vector2.all(0.7), parentSize: size));
    baseY = y;

    totalDrops = random.nextInt(3) + 1;
    dropsRemaining = totalDrops;

    dropIdleTimer = Timer(0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    dropIdleTimer.update(dt);

    switch (state) {
      case GrumbluffState.floatingIn:
        x -= 300 * dt;
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
        x += 250 * dt;
        floatTime += dt;
        y = baseY + sin(floatTime * floatSpeed) * floatAmplitude;
        if (x >= escapeTriggerX) {
          state = GrumbluffState.descending;
        }
        break;

      case GrumbluffState.descending:
        y += 200 * dt;
        if (y >= floorY - size.y / 2) {
          state = GrumbluffState.chargingLeft;
        }
        break;

      case GrumbluffState.chargingLeft:
        x -= 500 * dt;
        if (x < -width) {
          removeFromParent();
        }
        break;
    }
  }


  void startDropping() {
    state = GrumbluffState.dropping;
    performDrop();
  }

  void performDrop() {
    game.add(GrumbluffDrop(position.clone() + Vector2(0, size.y / 2)));
    dropsRemaining--;

    if (dropsRemaining > 0) {
      dropIdleTimer = Timer(random.nextDouble() * 1 + 0.5, onTick: performDrop, repeat: false);
      dropIdleTimer.start();
    } else {
      // All drops done, idle briefly, then escape
      dropIdleTimer = Timer(random.nextDouble() * 1 + 0.5, onTick: () {
        state = GrumbluffState.escapingRight;
      }, repeat: false);
      dropIdleTimer.start();
    }
  }
}
