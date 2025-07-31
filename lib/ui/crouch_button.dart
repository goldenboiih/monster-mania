import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flamegame/endless_runner/runner_game.dart';

class CrouchButton extends SpriteComponent
    with HasGameReference<EndlessRunnerGame>, TapCallbacks {
  CrouchButton() : super(size: Vector2(128, 128), priority: 10);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ui/jump_button.png');
    position = Vector2(0, game.size.y - size.y);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.runner.crouch();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    game.runner.stopCrouch();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    game.runner.stopCrouch();
  }
}
