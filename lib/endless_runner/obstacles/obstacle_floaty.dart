import 'package:flamegame/endless_runner/obstacles/obstacle.dart';
import 'package:flamegame/endless_runner/runner_game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class ObstacleFloaty extends Obstacle
    with HasGameReference<EndlessRunnerGame> {
  ObstacleFloaty()
      : super(
    size: Vector2(64, 64),
    position: Vector2(800, 291),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('floaty/floaty_monster_32x32.png');
    add(RectangleHitbox.relative(Vector2.all(1.0), parentSize: size));
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
