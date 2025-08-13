import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/ui/music_toggle.dart';
import 'package:flamegame/ui/score.dart';

import 'audio_manager.dart';

enum GameState { intro, playing, crashing, gameOver }

class BaseGame extends FlameGame {
  late int previousHighScore;
  int highScore = 0;
  late double speed;
  late int score;
  late TextComponent scoreText;
  void restart() {
  }

  VoidCallback? onExitToMenu;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager.init();
    scoreText = Score();
    add(scoreText);
    add(MusicToggle());
  }

  @override
  void onDetach() {
    FlameAudio.bgm.pause();
    super.onDetach();
  }

}