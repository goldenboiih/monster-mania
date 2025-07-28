import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Score extends TextComponent {
  double score = 0;
  final double speed = 60; // units per second (e.g. meters)

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
    score += speed * dt;
    text = '${score.floor()}';
  }
}
