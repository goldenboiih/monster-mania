import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

abstract class Obstacle extends SpriteComponent with CollisionCallbacks {
  Obstacle({
    required Vector2 size,
    required Vector2 position,
    Anchor anchor = Anchor.center,
  }) : super(size: size, position: position, anchor: anchor);
}
