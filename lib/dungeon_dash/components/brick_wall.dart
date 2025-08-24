import 'dart:math';
import 'package:flame/components.dart';
import 'package:flamegame/dungeon_dash/dungeon_dash.dart';
import 'brick.dart';

enum WallState { idle, slidingOut, hidden }

class BrickWall extends PositionComponent with HasGameReference<DungeonDash> {
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

    final rng = Random();

    // Fill the full height (no bottom sliver)
    final numBricks = (game.size.y / brickHeight).ceil();

    final gapSizeInBricks = (gapHeight / brickHeight).ceil();

    // If you want the component's size to match the stack exactly:
    size = Vector2(brickHeight, numBricks * brickHeight);

    // Guard: if too small to place a gap away from edges, build solid wall
    if (numBricks < gapSizeInBricks + 2) {
      for (int i = 0; i < numBricks; i++) {
        add(Brick(position: Vector2(0, i * brickHeight)));
      }
      return;
    }

    // Valid start indices so the whole gap stays inside (not touching top/bottom)
    // Allowed rows: 1 .. numBricks-2
    // Start indices: 1 .. (numBricks - gapSizeInBricks - 1)
    final lastValidStart = numBricks - gapSizeInBricks - 1;
    final availableStarts = List<int>.generate(
      (lastValidStart >= 1) ? (lastValidStart - 1 + 1) : 0,
          (i) => i + 1,
    );

    final maxNonOverlapping = (availableStarts.length / gapSizeInBricks).floor();
    final numGaps = maxNonOverlapping == 0 ? 0 : min(rng.nextInt(3) + 1, maxNonOverlapping);

    final gapStartIndices = <int>[];

    while (gapStartIndices.length < numGaps && availableStarts.isNotEmpty) {
      final candidate = availableStarts[rng.nextInt(availableStarts.length)];

      final overlaps = gapStartIndices.any((start) =>
      (candidate < start + gapSizeInBricks) && (start < candidate + gapSizeInBricks));

      if (!overlaps) {
        gapStartIndices.add(candidate);
        for (int i = 0; i < gapSizeInBricks; i++) {
          availableStarts.remove(candidate + i);
        }
      } else {
        availableStarts.remove(candidate);
      }
    }

    // Build bricks (skip gap rows)
    for (int i = 0; i < numBricks; i++) {
      final isGap = gapStartIndices.any((start) => i >= start && i < start + gapSizeInBricks);
      if (isGap) continue;

      add(Brick(position: Vector2(0, i * brickHeight)));
    }
  }


  void slideOut() {
    _state = WallState.slidingOut;
  }
}
