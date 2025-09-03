import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamegame/overlays/medal.dart';
import 'package:flamegame/ui/music_toggle.dart';
import 'package:flamegame/ui/score.dart';

import 'audio_manager.dart';
import 'highscore_manager.dart';

enum GameState { intro, playing, crashing, gameOver }

abstract class BaseGame extends FlameGame {
  VoidCallback? onExitToMenu;
  String get gameId;
  late int previousHighScore;
  late int highScore;
  late double speed;
  int score = 0;
  late ScoreText scoreText;
  late GameState gameState;

  MedalThreshold get medalThreshold;

  void initializeGame();
  void restart();

  Future<void> onGameOver() async {
    if (score > previousHighScore) {
      highScore = score;
      await HighscoreManager.saveHighscore(gameId, highScore);
    } else
    {
      highScore = previousHighScore;
    }
    gameState = GameState.gameOver;
    overlays.add('GameOver');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager.init();
    scoreText = ScoreText();
    add(scoreText);
    add(MusicToggle());
  }

  @override
  void onDetach() {
    FlameAudio.bgm.pause();
    super.onDetach();
  }

}