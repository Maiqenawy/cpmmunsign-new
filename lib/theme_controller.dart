import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _key = 'themeMode'; // system | light | dark

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key) ?? 'system';

    _mode = switch (v) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    notifyListeners();
  }

  Future<void> setMode(ThemeMode newMode) async {
    _mode = newMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final v = switch (newMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString(_key, v);
  }

  Future<void> toggleDark(bool isDark) async {
    await setMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
