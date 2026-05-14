import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? token;
  static bool isGuest = false;

  // حفظ التوكن
  static Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", value);
    token = value;
  }

  // تحميل التوكن
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }
static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
    return token;
  }
  // تسجيل خروج
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    token = null;
    isGuest = false;
  }

  // هل المستخدم مسجل؟
  static bool get isLoggedIn => token != null;
}
