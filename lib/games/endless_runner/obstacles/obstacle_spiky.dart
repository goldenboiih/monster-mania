import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flamegame/games/endless_runner/obstacles/obstacle_tag.dart';
import 'package:flamegame/games/endless_runner/runner_game.dart';


class ObstacleSpiky extends SpriteAnimationComponent
    with HasGameReference<EndlessRunnerGame>, ObstacleTag {
  ObstacleSpiky()
    : super(
        size: Vector2(64, 64), // Or match the sprite's logical size
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    position = Vector2(
      game.size.x + width,
      game.size.y - game.floorHeight - (size.y / 2),
    );
    animation = await game.loadSpriteAnimation(
      'spiky/spiky.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .1,
        textureSize: Vector2(32, 32),
      ),
    );
    add(RectangleHitbox.relative(Vector2.all(.7), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= game.speed  * dt + 4;
    if (x < -width) {
      removeFromParent();
    }
  }
}
