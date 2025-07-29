import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flamegame/base_game.dart';

class Background extends PositionComponent with HasGameReference<BaseGame> {
  Background() : super(priority: -10); // lower = farther back

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    // You can customize the color here
    final paint = BasicPalette.blue.paint()..color = const Color(0xFFD4F2FF); // Light blue
    canvas.drawRect(size.toRect(), paint);
  }
}
