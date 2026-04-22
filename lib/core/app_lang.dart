import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLang {
  static Map<String, String> _texts = {};
  static Locale currentLocale = const Locale('en');

  static final ValueNotifier<Locale> notifier =
      ValueNotifier(const Locale('en'));

  // تحميل اللغة
  static Future<void> load(String langCode) async {
    currentLocale = Locale(langCode);

    final file = (langCode == 'ar')
        ? 'assets/lang/ar.json'
        : 'assets/lang/en.json';

    final data = await rootBundle.loadString(file);
    _texts = Map<String, String>.from(json.decode(data));

    // حفظ اللغة
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("lang", langCode);

    notifier.value = currentLocale;
  }

  // تحميل اللغة المحفوظة
  static Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString("lang") ?? 'en';
    await load(lang);
  }

  static String t(String key) {
    return _texts[key] ?? key;
  }
}
