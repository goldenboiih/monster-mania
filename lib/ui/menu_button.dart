import 'package:flame/components.dart';
import 'package:flame/events.dart';

class MenuButton extends SpriteComponent with TapCallbacks, HasGameReference {
  final void Function()? onPressed;

  MenuButton({
    required this.onPressed,
    // Vector2? position,
  }) : super(
    size: Vector2(128, 32),
    // position: position ?? Vector2.zero(),
    priority: 10,
  );

  @override
  Future<void> onLoad() async {

    // Place top-right corner with 10px padding
    position = Vector2(
      game.size.x - size.x - 10,
      10,
    );
    sprite = await Sprite.load('ui/menu_button.png');
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onPressed?.call();
  }
}
