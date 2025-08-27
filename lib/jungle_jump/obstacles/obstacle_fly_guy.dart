import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/jungle_jump/obstacles/obstacle_tag.dart';
import 'package:flamegame/jungle_jump/jungle_jump.dart';

class ObstacleFlyGuy extends SpriteAnimationComponent
    with HasGameReference<JungleJump>, ObstacleTag {
  ObstacleFlyGuy()
      : super(
    size: Vector2(64, 64), // Or match the sprite's logical size
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    double altitude = game.size.y - game.floorHeight - (size.y / 2) + 2;
    final int rand = Random().nextInt(3);
    switch (rand) {
      case 0:
        break;
      case 1:
        altitude -= 32;
        break;
      case 2:
        altitude -= 64;
    }
    position = Vector2(game.size.x + width, altitude);
    final images = await Future.wait([
      game.images.load('jungle_jump/fly_guy/fly_guy_down.png'),
      game.images.load('jungle_jump/fly_guy/fly_guy_mid.png'),
      game.images.load('jungle_jump/fly_guy/fly_guy_up.png'),
    ]);
    animation = SpriteAnimation.spriteList(
      images.map((img) => Sprite(img)).toList(),
      stepTime: 0.1,
    );
    add(RectangleHitbox.relative(Vector2.all(.7), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= (game.speed + 400) * dt;
    if (x < -width) {
      removeFromParent();
    }
  }
}
