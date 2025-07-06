import 'package:shared_preferences/shared_preferences.dart';

class GameStatsService {
  static const _totalGamesKey = 'total_games';
  static const _winsKey = 'total_wins';
  static const _lossesKey = 'total_losses';
  static const List<String> _winKeys = ['win1', 'win2', 'win3', 'win4'];

  /// زيادة عدد الألعاب وللإنتصارات حسب رقم المحاولة (1-4)
  Future<void> incrementGame({required bool isWin, int? tryNumber}) async {
    final prefs = await SharedPreferences.getInstance();

    // 🔢 Total games
    int games = prefs.getInt(_totalGamesKey) ?? 0;
    await prefs.setInt(_totalGamesKey, games + 1);

    if (isWin) {
      // ✅ Total Wins
      int wins = prefs.getInt(_winsKey) ?? 0;
      await prefs.setInt(_winsKey, wins + 1);

      // 🥇 win1 ~ 🏅 win4
      if (tryNumber != null && tryNumber >= 1 && tryNumber <= 4) {
        final key = 'win$tryNumber';
        int winsInTry = prefs.getInt(key) ?? 0;
        await prefs.setInt(key, winsInTry + 1);
      }
    } else {
      // ❌ Losses
      int losses = prefs.getInt(_lossesKey) ?? 0;
      await prefs.setInt(_lossesKey, losses + 1);
    }
  }

  /// 🔄 الحصول على كل الإحصائيات
  Future<Map<String, int>> getStats() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'totalGames': prefs.getInt(_totalGamesKey) ?? 0,
      'wins': prefs.getInt(_winsKey) ?? 0,
      'losses': prefs.getInt(_lossesKey) ?? 0,
      'win1': prefs.getInt(_winKeys[0]) ?? 0,
      'win2': prefs.getInt(_winKeys[1]) ?? 0,
      'win3': prefs.getInt(_winKeys[2]) ?? 0,
      'win4': prefs.getInt(_winKeys[3]) ?? 0,
    };
  }

  /// 🔁 إعادة تعيين جميع الإحصائيات (اختياري)
  Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_totalGamesKey);
    await prefs.remove(_winsKey);
    await prefs.remove(_lossesKey);
    for (var key in _winKeys) {
      await prefs.remove(key);
    }
  }
}
