import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flamegame/endless_runner/runner_game.dart';

class Cloud extends SpriteComponent
    with HasGameReference<EndlessRunnerGame>, CollisionCallbacks {
  Cloud()
      : super(
    size: Vector2(64, 16), // Or match the sprite's logical size
    position: Vector2(800, 100),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('cloud.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= 190 * dt;
    if (x < -width) {
      removeFromParent();
    }
  }
}
