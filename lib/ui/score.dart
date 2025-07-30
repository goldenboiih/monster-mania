import 'package:flame/components.dart';
import 'package:flamegame/base_game.dart';
import 'package:flutter/material.dart';

class Score extends TextComponent with HasGameReference<BaseGame> {
  double score = 0;

  Score()
      : super(
    text: '0',
    position: Vector2(10, 10),
    anchor: Anchor.topLeft,
    priority: 100,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontFamily: 'Arial',
      ),
    ),
  );

  @override
  void update(double dt) {
    super.update(dt);
    text = '${game.score.floor()}';
  }
}
