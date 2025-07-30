import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flamegame/flappy_game/flappy_game.dart';
import 'package:flamegame/flappy_game/player.dart';

class ScoreZone extends PositionComponent
    with HasGameReference<FlappyGame>, CollisionCallbacks {

  ScoreZone({required Vector2 size}) {
    this.size = size;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if ( other is Player) {
      game.increaseScore();
      removeFromParent(); // remove zone after scoring
    }
  }
}
