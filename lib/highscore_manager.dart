import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class HighscoreManager {
  static const _prefix = 'highscore_';

  // Save highscore only if it's higher than the current
  static Future<void> saveHighscore(String gameId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$gameId';
    final current = prefs.getInt(key) ?? 0;

    if (score > current) {
      log('set highscore to $score');
      await prefs.setInt(key, score);
    }
    // await prefs.setInt(key, 0);
  }

  // Get highscore
  static Future<int> getHighscore(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix$gameId') ?? 0;
  }
}
