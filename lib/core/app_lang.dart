import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AppLang {
  static Map<String, String> _texts = {};
  static String currentLang = 'English';

  // ✅ أي صفحة تقدر تسمع وتعمل rebuild لما اللغة تتغير
  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  // ✅ تحميل اللغة
  static Future<void> load(String lang) async {
    currentLang = lang;
    final file = (lang == 'العربية')
        ? 'assets/lang/ar.json'
        : 'assets/lang/en.json';

    final data = await rootBundle.loadString(file);
    _texts = Map<String, String>.from(json.decode(data));

    // ✅ نعلن إن اللغة اتغيرت
    notifier.value++;
  }

  // ✅ الحصول على الترجمة
  static String t(String key) {
    return _texts[key] ?? key;
  }
}
