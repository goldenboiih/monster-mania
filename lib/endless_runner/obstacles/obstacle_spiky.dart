import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flamegame/endless_runner/runner_game.dart';
import 'package:flamegame/endless_runner/obstacles/obstacle.dart';

class ObstacleSpiky extends Obstacle
    with HasGameReference<EndlessRunnerGame> {
  ObstacleSpiky()
      : super(
    size: Vector2(64, 64), // Or match the sprite's logical size
    position: Vector2(800, 291),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('spiky/spiky_monster_32x32.png');
    add(RectangleHitbox.relative(Vector2.all(.7), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= game.speed * dt;
    if (x < -width) {
      removeFromParent();
    }
  }
}
