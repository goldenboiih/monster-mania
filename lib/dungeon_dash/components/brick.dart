import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Brick extends SpriteComponent {
  static final _random = Random();

  // asset path -> weight (higher = more common)
  static const Map<String, int> _weights = {
    'dungeon_dash/blocks/stone.png'       : 50,
    'dungeon_dash/blocks/coal.png'        : 8,
    'dungeon_dash/blocks/iron.png'        : 6,
    'dungeon_dash/blocks/gold.png'        : 3,
    'dungeon_dash/blocks/diamond.png'     : 1,
  };

  Brick({required super.position})
      : super(priority: 2, size: Vector2(32, 32));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.topLeft;

    final choice = _weightedChoice(_weights);
    sprite = await Sprite.load(choice);

    add(RectangleHitbox());
  }

  // ---- helpers ----
  static String _weightedChoice(Map<String, int> weights) {
    final total = weights.values.fold<int>(0, (a, b) => a + b);
    int pick = _random.nextInt(total); // 0..total-1
    for (final entry in weights.entries) {
      if (pick < entry.value) return entry.key;
      pick -= entry.value;
    }
    // Fallback (shouldn’t hit)
    return weights.keys.first;
  }
}
