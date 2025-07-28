import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flamegame/endless_runner/runner_game.dart';
import 'package:flamegame/endless_runner/game_config.dart';

class GrumbluffDrop extends SpriteComponent
    with HasGameReference<EndlessRunnerGame>, CollisionCallbacks {
  bool hasLanded = false;
  final double groundY = 303;

  GrumbluffDrop(Vector2 spawnPosition)
      : super(
    size: Vector2(24, 24),
    position: spawnPosition,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('grumbluff/drop_8x8.png');
    add(RectangleHitbox.relative(Vector2.all(1.0), parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);

    x -= game.speed * dt;

    if (!hasLanded) {
      y += 250 * dt;
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
