import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/ui/music_toggle.dart';
import 'package:flamegame/ui/score.dart';

import 'audio_manager.dart';

enum GameState { playing, crashing, gameOver }

class BaseGame extends FlameGame {
  late int previousHighScore;
  late int highScore;
  late int speed;
  late int score;

  void restart() {
  }

  VoidCallback? onExitToMenu;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager.init();
    add(Score());
    add(MusicToggle());
  }

  @override
  void onDetach() {
    FlameAudio.bgm.pause();
    super.onDetach();
  }

}