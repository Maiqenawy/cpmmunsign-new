import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? token;
  static String? email;
  static bool isGuest = false;

  // ================= SAVE SESSION =================
  static Future<void> saveSession({
    required String tokenValue,
    required String emailValue,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("token", tokenValue);
    await prefs.setString("email", emailValue);

    token = tokenValue;
    email = emailValue;
    isGuest = false;
  }

  // ================= LOAD SESSION =================
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");
    email = prefs.getString("email");

    // لو مفيش توكن → يبقى Guest
    isGuest = token == null;
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("email");

    token = null;
    email = null;
    isGuest = false;
  }

  // ================= CHECK LOGIN =================
  static bool get isLoggedIn => token != null;
}