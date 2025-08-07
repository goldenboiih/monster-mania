import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Brick extends SpriteComponent {


  Brick({
    required super.position,
  }): super(priority: 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('brick.png');
    anchor = Anchor.topLeft;

    add(RectangleHitbox());
  }
}