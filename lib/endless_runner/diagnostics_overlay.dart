// debug/diagnostics_overlay.dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, Color, TextStyle, Paint;
import '../endless_runner/runner.dart';
import '../endless_runner/obstacles/obstacle_fly_guy.dart';
import '../endless_runner/obstacles/obstacle_grumbluff.dart';
import '../endless_runner/obstacles/obstacle_spiky.dart';
import '../endless_runner/obstacles/obstacle_tag.dart';
import '../endless_runner/runner_game.dart';

class DiagnosticsOverlay extends PositionComponent
    with HasGameReference<EndlessRunnerGame> {
  DiagnosticsOverlay();

  final _bg = RectangleComponent(
    size: Vector2(260, 120),
    paint: Paint()..color = const Color(0xAA000000),
  );

  late final TextComponent _text;

  double _acc = 0;

  @override
  Future<void> onLoad() async {
    priority = 100000; // draw on top
    position = Vector2(8, 8);
    anchor = Anchor.topLeft;

    _text = TextComponent(
      text: '',
      position: Vector2(8, 8),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.1,
          fontFamily: 'monospace',
        ),
      ),
    );

    await add(_bg);
    await add(_text);

    // Optional: also show FPS (Flame has one built-in)
    add(FpsTextComponent(
      position: Vector2(8, _bg.size.y + 6),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _acc += dt;
    if (_acc >= 0.25) { // refresh ~4x/s
      _acc = 0;
      _refresh();
    }
  }

  void _refresh() {
    // Enumerate the whole component tree safely
    final all = game.descendants().toList(growable: false);

    final total = all.length;
    final runners = all.whereType<Runner>().length;
    final obstaclesTotal = all.whereType<ObstacleTag>().length;
    final grum = all.whereType<ObstacleGrumbluff>().length;
    final fly = all.whereType<ObstacleFlyGuy>().length;
    final spiky = all.whereType<ObstacleSpiky>().length;

    final txt = StringBuffer()
      ..writeln('Children: $total')
      ..writeln('Runner: $runners')
      ..writeln('Obstacles: $obstaclesTotal  (G:$grum  F:$fly  S:$spiky)')
      ..writeln('State: ${game.gameState}')
      ..writeln('Speed: ${game.speed.toStringAsFixed(0)} px/s')
      ..writeln('SpawnInterval: ${game.spawnInterval.toStringAsFixed(2)} s')
      ..writeln('Score: ${game.score}');

    _text.text = txt.toString();

    // Resize background to fit text snugly
    // Add some padding (16 horizontal, 12 vertical total)
    final width = max(220.0, _text.size.x + 16);
    final height = _text.size.y + 12;
    _bg.size.setValues(width, height);
  }
}
