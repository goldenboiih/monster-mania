import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class Pipe extends SpriteComponent {

  final bool isFlipped;
  final double pipeWidth;

  Pipe({
    required this.isFlipped,
    required super.position,
    required this.pipeWidth,
  }): super(priority: 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('pipe/pipe.png');
    anchor = Anchor.topCenter;
    final ratio = sprite!.srcSize.y / sprite!.srcSize.x;
    size = Vector2(pipeWidth, pipeWidth * ratio);
    if (isFlipped) {
      flipVertically();
    }

    add(RectangleHitbox());
  }
}