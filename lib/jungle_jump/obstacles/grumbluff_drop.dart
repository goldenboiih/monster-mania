import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/jungle_jump/obstacles/obstacle_tag.dart';
import 'package:flamegame/jungle_jump/jungle_jump.dart';

class GrumbluffDrop extends SpriteComponent
    with HasGameReference<JungleJump>, ObstacleTag {
  bool hasLanded = false;
  late double groundY;

  GrumbluffDrop(Vector2 spawnPosition)
      : super(
    size: Vector2(24, 24),
    anchor: Anchor.center,
    position: spawnPosition
  );

  @override
  Future<void> onLoad() async {
    groundY = game.size.y - game.floorHeight - (size.y / 2);

    sprite = await Sprite.load('grumbluff/drop_8x8.png');
    add(RectangleHitbox.relative(Vector2.all(1.0), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);

    x -= game.speed * dt;

    if (!hasLanded) {
      y += game.speed * dt;
    }

    if (y >= groundY) {
      y = groundY;
      hasLanded = true;
    }

    if (x < -width) {
      removeFromParent();
    }
  }
}
