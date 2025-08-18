import 'dart:math';
import 'package:flame/components.dart';
import 'package:flamegame/games/monster_dash/monster_dash.dart';
import 'brick.dart';

enum WallState { idle, slidingOut, hidden }

class BrickWall extends PositionComponent with HasGameReference<MonsterDash> {
  final bool left;
  static const double brickHeight = 32;
  static const double gapHeight = 128;

  WallState _state = WallState.idle;
  BrickWall({required this.left});

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    await super.onLoad();
    await buildBricks();

    // Position the wall depending on its side
    position = Vector2(
      left ? 0 : game.size.x - brickHeight,
      0,
    );

    size = Vector2(brickHeight, game.size.y);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_state == WallState.slidingOut) {
      final dx = (left ? -1 : 1) * game.speed * 0.5 * dt;
      x += dx;

      if ((left && x + width < 0) || (!left && x > game.size.x)) {
        removeFromParent();
      }
    }
  }

  Future<void> buildBricks() async {
    removeAll(children);

    final numBricks = (game.size.y / brickHeight).floor();
    final gapSizeInBricks = (gapHeight / brickHeight).ceil();

    // Valid gap starts: not at the first or last rows
    final availableIndices = List.generate(
      numBricks - 2, // exclude first and last rows
          (i) => i + 1,   // start from index 1
    );

    final numGaps = min(Random().nextInt(3) + 1, availableIndices.length ~/ gapSizeInBricks);

    final gapStartIndices = <int>[];

    while (gapStartIndices.length < numGaps && availableIndices.length >= gapSizeInBricks) {
      final candidateIndex = availableIndices[Random().nextInt(availableIndices.length)];

      // Ensure no overlapping gaps
      final overlaps = gapStartIndices.any((start) =>
      (candidateIndex < start + gapSizeInBricks) &&
          (start < candidateIndex + gapSizeInBricks));

      if (!overlaps) {
        gapStartIndices.add(candidateIndex);

        // Remove affected indices from available
        for (int i = 0; i < gapSizeInBricks; i++) {
          availableIndices.remove(candidateIndex + i);
        }
      } else {
        availableIndices.remove(candidateIndex);
      }
    }

    // Build the wall
    for (int i = 0; i < numBricks; i++) {
      final isGap = gapStartIndices.any((start) => i >= start && i < start + gapSizeInBricks);
      if (isGap) continue;

      final brick = Brick(
        position: Vector2(0, i * brickHeight),
      );

      add(brick);
    }
  }

  void slideOut() {
    _state = WallState.slidingOut;
  }
}
