import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/endless_runner/runner_game.dart';

class ObstacleFlyGuy extends SpriteAnimationComponent
    with HasGameReference<EndlessRunnerGame> {
  ObstacleFlyGuy()
      : super(
    size: Vector2(64, 64), // Or match the sprite's logical size
    position: Vector2(800, 250),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    final images = await Future.wait([
      game.images.load('fly_guy/fly_guy_down.png'),
      game.images.load('fly_guy/fly_guy_mid.png'),
      game.images.load('fly_guy/fly_guy_up.png'),
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
