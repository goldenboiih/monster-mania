import 'dart:ui';

import 'package:flame/game.dart';

enum GameState { playing, crashing, gameOver }

class BaseGame extends FlameGame {
  late int speed;
  late int score;

  void restart() {
  }

  VoidCallback? onExitToMenu;
}