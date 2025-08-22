import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/base_game.dart';
import 'package:flamegame/monster_dash/monster_dash.dart';

class Carrot extends SpriteComponent
    with HasGameReference<MonsterDash>, CollisionCallbacks {
  Carrot({required Vector2 position})
      : super(
    position: position,
    size: Vector2.all(24),
    anchor: Anchor.center,
    priority: 1,
  );

  double _lifetime = 5.0; // seconds

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('carrot.png');
    add(CircleHitbox.relative(1, parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);

    _lifetime -= dt;
    if (_lifetime <= 0) {
      removeFromParent(); // disappear after 5s
    }
  }

  void collect() {
    if (game.gameState == GameState.playing) {
      FlameAudio.play('coin.mp3');
      game.increaseScore();
      removeFromParent();
    }
  }
}
