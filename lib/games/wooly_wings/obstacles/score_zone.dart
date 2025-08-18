import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/games/base_game.dart';

import 'package:flamegame/games/wooly_wings//wooly_wings_game.dart';
import 'package:flamegame/games/wooly_wings/bird.dart';

class ScoreZone extends PositionComponent
    with HasGameReference<WoolyWings>, CollisionCallbacks {

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
    if (game.gameState == GameState.playing && other is Wooly) {
      game.increaseScore();
      removeFromParent(); // remove zone after scoring
    }
  }
}
