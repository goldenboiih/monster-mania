import 'dart:math';
import 'package:flame/components.dart';
import 'package:flamegame/flappy_game/flappy_game.dart';
import 'pipe.dart';

class PipePair extends PositionComponent with HasGameReference<FlappyGame>{
  final Sprite topCap;
  final Sprite bodySegment;
  final Vector2 screenSize;
  final double gapSize;
  final double segmentHeight;
  final double speed;

  PipePair({
    required this.topCap,
    required this.bodySegment,
    required this.screenSize,
    this.gapSize = 120,
    this.segmentHeight = 20,
    this.speed = 150,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final double maxPipeHeight = screenSize.y - gapSize - 100;
    final double minPipeHeight = 50;
    final double topPipeHeight =
        Random().nextDouble() * (maxPipeHeight - minPipeHeight) + minPipeHeight;

    final double bottomPipeHeight = screenSize.y - topPipeHeight - gapSize;

    final int topSegmentCount =
        ((topPipeHeight - topCap.srcSize.y) / segmentHeight).floor();
    final int bottomSegmentCount =
        ((bottomPipeHeight - topCap.srcSize.y) / segmentHeight).floor();

    final topPipe = Pipe(
      isFlipped: true,
      capSprite: topCap,
      bodySegmentSprite: bodySegment,
      segmentHeight: segmentHeight,
      segmentCount: topSegmentCount,
    )..position = Vector2(0, topPipeHeight);

    final bottomPipe = Pipe(
      isFlipped: false,
      capSprite: topCap,
      bodySegmentSprite: bodySegment,
      segmentHeight: segmentHeight,
      segmentCount: bottomSegmentCount,
    )..position = Vector2(0, topPipeHeight + gapSize);

    addAll([topPipe, bottomPipe]);

    size = Vector2(topCap.srcSize.x, screenSize.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= speed * dt;
    if (x + size.x < 0) {
      removeFromParent();
    }
  }
}
