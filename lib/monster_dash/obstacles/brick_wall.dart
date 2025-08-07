import 'dart:math';
import 'package:flame/components.dart';
import 'package:flamegame/monster_dash/monster_dash.dart';
import 'brick.dart';

class BrickWall extends PositionComponent with HasGameReference<MonsterDash> {
  final bool left;
  static const double brickHeight = 32;
  static const double gapHeight = 128;

  BrickWall({required this.left});

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;

    await super.onLoad();

    final numBricks = (game.size.y / brickHeight).ceil();
    final gapSizeInBricks = (gapHeight / brickHeight).ceil();
    final availableIndices = List.generate(numBricks, (i) => i);

    // Randomly choose 1–3 gaps
    final numGaps = Random().nextInt(3) + 1;

    // Store start index of each gap
    final gapStartIndices = <int>[];

    while (gapStartIndices.length < numGaps && availableIndices.length >= gapSizeInBricks) {
      final candidateIndex = availableIndices[Random().nextInt(availableIndices.length)];

      // Check for overlap with existing gaps
      bool overlaps = gapStartIndices.any((start) =>
      (candidateIndex < start + gapSizeInBricks) &&
          (start < candidateIndex + gapSizeInBricks));

      if (!overlaps) {
        gapStartIndices.add(candidateIndex);

        // Remove affected indices to avoid future overlaps
        for (int i = 0; i < gapSizeInBricks; i++) {
          availableIndices.remove(candidateIndex + i);
        }
      } else {
        // Try another index
        availableIndices.remove(candidateIndex);
      }
    }

    for (int i = 0; i < numBricks; i++) {
      final isGap = gapStartIndices.any((start) => i >= start && i < start + gapSizeInBricks);
      if (isGap) continue;

      final brick = Brick(
        position: Vector2(0, i * brickHeight),
      );

      add(brick);
    }

    // Place wall just off-screen based on direction
    position = Vector2(
      left ? 0 : game.size.x - brickHeight,
      0,
    );

    size = Vector2(brickHeight, game.size.y);
  }

  @override
  void update(double dt) {
    super.update(dt);

  }
}
