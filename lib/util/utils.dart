import 'package:flame/components.dart';

Future<SpriteAnimation> loadSpriteAnimation({
  required List<String> images,
  required double stepTime,
}) async {
  final spriteFutures = images.map((path) => Sprite.load(path));
  final sprites = await Future.wait(spriteFutures);

  return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
}
