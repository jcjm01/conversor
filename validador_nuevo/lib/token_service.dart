import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _key = 'token_count';

  static Future<int> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  static Future<void> setTokens(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, count);
  }

  static Future<void> addTokens(int amount) async {
    final current = await getTokens();
    await setTokens(current + amount);
  }

  static Future<bool> useToken() async {
    final current = await getTokens();
    if (current > 0) {
      await setTokens(current - 1);
      return true;
    } else {
      return false;
    }
  }

  static Future<void> resetTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
