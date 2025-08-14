import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class HighscoreManager {
  static const _prefix = 'highscore_';

  static Future<void> saveHighscore(String gameId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$gameId';
    await prefs.setInt(key, score);
  }

  // Get highscore
  static Future<int> getHighscore(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix$gameId') ?? 0;
  }
}
