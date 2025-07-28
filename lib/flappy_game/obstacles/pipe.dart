import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Pipe extends PositionComponent {
  final bool isFlipped;
  final Sprite capSprite;
  final Sprite bodySegmentSprite;
  final double segmentHeight;
  final int segmentCount;

  Pipe({
    required this.isFlipped,
    required this.capSprite,
    required this.bodySegmentSprite,
    required this.segmentHeight,
    required this.segmentCount,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (isFlipped) {
      _buildFlipped();
    } else {
      _buildNormal();
    }

    // debugMode = true;
  }

  void _buildNormal() {
    final cap = SpriteComponent(
      sprite: capSprite,
      size: capSprite.srcSize,
      position: Vector2(0, 0),
    );
    add(cap);

    final bodyStartY = capSprite.srcSize.y;
    final bodyHeight = segmentCount * segmentHeight;

    // Add body segments (visual only, no hitboxes)
    for (int i = 0; i < segmentCount; i++) {
      final segment = SpriteComponent(
        sprite: bodySegmentSprite,
        size: Vector2(bodySegmentSprite.srcSize.x, segmentHeight),
        position: Vector2(0, bodyStartY + i * segmentHeight),
      );
      add(segment);
    }

    // Add single hitbox for full body (excluding cap)
    add(
      RectangleHitbox(
        position: Vector2(0, bodyStartY),
        size: Vector2(bodySegmentSprite.srcSize.x, bodyHeight),
      ),
    );

    size = Vector2(capSprite.srcSize.x, bodyStartY + bodyHeight);
  }

  void _buildFlipped() {
    final capHeight = capSprite.srcSize.y;
    final bodyHeight = segmentCount * segmentHeight;
    final bodyStartY = -capHeight - bodyHeight;

    // Add body segments (visual only, flipped vertically)
    for (int i = 0; i < segmentCount; i++) {
      final segment = SpriteComponent(
        sprite: bodySegmentSprite,
        size: Vector2(bodySegmentSprite.srcSize.x, segmentHeight),
        position: Vector2(0, bodyStartY + i * segmentHeight),
        scale: Vector2(1, -1),
        anchor: Anchor.topLeft,
      );
      add(segment);
    }

    // Add flipped cap
    final cap = SpriteComponent(
      sprite: capSprite,
      size: capSprite.srcSize,
      position: Vector2(0, -capHeight),
      scale: Vector2(1, -1),
      anchor: Anchor.topLeft,
    );
    add(cap);

    // Add single hitbox for full body
    add(
      RectangleHitbox(
        position: Vector2(0, bodyStartY),
        size: Vector2(bodySegmentSprite.srcSize.x, bodyHeight),
      ),
    );

    size = Vector2(capSprite.srcSize.x, capHeight + bodyHeight);
  }
}
