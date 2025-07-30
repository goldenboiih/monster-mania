import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flamegame/base_game.dart';

class Floor extends Component with HasGameReference<BaseGame> {
  final List<SpriteComponent> tiles = [];
  final double tileWidth = 256; // match actual sprite size
  final double tileHeight = 64;
  final bool hasHitBox;

  Floor({this.hasHitBox = false});

  @override
  Future<void> onLoad() async {
    final sprite = await Sprite.load('floor.png');
    final tilesNeeded = (game.size.x / tileWidth).ceil() + 2;
    final y = game.size.y - tileHeight;

    for (int i = 0; i < tilesNeeded; i++) {
      final tile = SpriteComponent(
        sprite: sprite,
        size: Vector2(tileWidth, tileHeight),
        position: Vector2(i * tileWidth, y),
      );

      if (hasHitBox) {
        tile.add(RectangleHitbox());
      }

      tiles.add(tile);
      add(tile);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (final tile in tiles) {
      tile.x -= game.speed * dt;
    }

    // Looping
    for (final tile in tiles) {
      if (tile.x + tileWidth < 0) {
        final rightmost = tiles.reduce((a, b) => a.x > b.x ? a : b);
        tile.x = rightmost.x + tileWidth;
      }
    }
  }
}
