import 'package:flame/components.dart';
import 'package:flamegame/flappy_game/flappy_game.dart';
import 'package:flamegame/flappy_game/obstacles/pipe.dart';


class PipePair extends PositionComponent with HasGameReference<FlappyGame> {
  PipePair({
    required super.position,
    required this.gap,
    required this.pipeWidth,
    super.priority,
  });

  final double gap;
  final double pipeWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addAll([
      Pipe(
        isFlipped: false,
        position: Vector2(0, gap / 2),
        pipeWidth: pipeWidth,
      ),
      Pipe(
        isFlipped: true,
        position: Vector2(0, -(gap / 2)),
        pipeWidth: pipeWidth,
      ),
      // HiddenCoin(
      //   position: Vector2(30, 0),
      //   size: Vector2(40, game.gameMode.gameConfig.pipeHoleGap * 0.9),
      // ),
    ]);
  }
}