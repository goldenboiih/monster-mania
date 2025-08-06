import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static bool _isMusicOn = true;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('music_on') ?? true;

    await FlameAudio.bgm.initialize();
    if (_isMusicOn) {
      await FlameAudio.bgm.play('energy_theme_jextor_bg.wav', volume: 0.7);
    }
  }

  static Future<void> toggleMusic() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = !_isMusicOn;
    prefs.setBool('music_on', _isMusicOn);

    if (_isMusicOn) {
      FlameAudio.bgm.resume();
    } else {
      FlameAudio.bgm.pause();
    }
  }

  static bool get isMusicOn => _isMusicOn;
}
