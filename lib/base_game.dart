import 'dart:ui';

import 'package:flame/game.dart';

class BaseGame extends FlameGame {
  late int speed;
  late int score;

  void restart() {
  }

  VoidCallback? onExitToMenu;
}