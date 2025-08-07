import 'dart:math';
import 'package:flamegame/endless_runner/obstacles/obstacle.dart';
import 'package:flamegame/endless_runner/runner_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class ObstacleFloaty extends Obstacle with HasGameReference<EndlessRunnerGame> {
  double floatTime = 0.0;
  final double floatAmplitude = 88.0;
  final double floatSpeed = 0.25;
  late double baseY;

  ObstacleFloaty()
      : super(
    size: Vector2(64, 64),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('floaty/floaty_monster_32x32.png');
    // Position the obstacle just outside the right edge at a fixed vertical level
    position = Vector2(game.size.x + width, game.size.y / 2);
    baseY = position.y;

    add(RectangleHitbox.relative(Vector2.all(1.0), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    floatTime += dt;
    y = baseY + sin(floatTime * floatSpeed * 2 * pi) * floatAmplitude;

    x -= game.speed * dt;

    if (x < -width) {
      removeFromParent();
    }
  }
}
