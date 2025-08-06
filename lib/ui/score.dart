import 'package:flame/components.dart';
import 'package:flamegame/base_game.dart';
import 'package:flutter/material.dart';

class Score extends TextComponent with HasGameReference<BaseGame> {

  Score()
      : super(
    position: Vector2(16, 16),
    anchor: Anchor.topLeft,
    priority: 100,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontFamily: 'Flappy',
      ),
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);
    text = '${game.score.floor()}';
  }
}
