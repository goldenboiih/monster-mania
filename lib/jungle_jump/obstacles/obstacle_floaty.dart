import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/jungle_jump/obstacles/obstacle_tag.dart';
import 'package:flamegame/jungle_jump/jungle_jump.dart';

class ObstacleFloaty extends SpriteComponent with HasGameReference<JungleJump>, ObstacleTag {
  double floatTime = 0.0;
  double floatAmplitude = 20.0; // reduced so it stays in one zone
  final double floatSpeed = 0.25;
  late double baseY;

  ObstacleFloaty()
      : super(
    size: Vector2(64, 64),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('jungle_jump/floaty/floaty_monster_32x32.png');

    // Decide if this floaty should be high or low
    final bool spawnHigh = Random().nextBool();

    // Lane positions
    final double highY = game.size.y / 3;     // Jump-over lane
    final double lowY = game.size.y / 1.5;    // Crouch-under lane

    baseY = spawnHigh ? highY : lowY;

    // Spawn just outside the right edge
    position = Vector2(game.size.x + width, baseY);

    add(RectangleHitbox.relative(Vector2.all(1.0), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Float in a limited range
    floatTime += dt;
    y = baseY + sin(floatTime * floatSpeed * 2 * pi) * floatAmplitude;

    // Move left
    x -= game.speed * dt;

    // Remove when off-screen
    if (x < -width) {
      removeFromParent();
    }
  }
}
