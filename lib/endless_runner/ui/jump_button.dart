import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../runner_game.dart';

class JumpButton extends SpriteComponent
    with HasGameReference<EndlessRunnerGame>, TapCallbacks {
  JumpButton(Sprite sprite)
      : super(
      size: Vector2(128, 128),
      priority: 10,
      sprite: sprite
  );

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x - size.x - 10, game.size.y - size.y);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.player.jump();
  }
}
