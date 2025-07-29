import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flamegame/endless_runner/runner_game.dart';

class JumpButton extends SpriteComponent
    with HasGameReference<EndlessRunnerGame>, TapCallbacks {

  JumpButton()
      : super(
      size: Vector2(128, 128),
      priority: 10,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ui/jump_button.png');
    position = Vector2(game.size.x - size.x - 10, game.size.y - size.y);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.player.jump();
  }
}
