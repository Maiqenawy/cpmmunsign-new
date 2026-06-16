import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ضروري لتعريف kIsWeb
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';

// استيراد الشاشات والملفات الخاصة بمشروعك
import 'package:cominsign_new/core/user_session.dart';
import 'package:cominsign_new/screens/home.dart';
import 'package:cominsign_new/screens/login_screen.dart';
import 'package:cominsign_new/screens/reset_password.dart';
import 'package:cominsign_new/screens/splash_empty.dart';
import 'package:cominsign_new/screens/splash_logo.dart';
import 'package:cominsign_new/screens/signUp.dart';
import 'package:cominsign_new/screens/forget_pass.dart';
import 'package:cominsign_new/screens/chat_with_us.dart';
import 'package:cominsign_new/screens/communication.dart';
import 'package:cominsign_new/screens/emergency.dart';
import 'package:cominsign_new/screens/learning.dart';
import 'package:cominsign_new/screens/Level_screen.dart';
import 'package:cominsign_new/screens/setting.dart';
import 'package:cominsign_new/screens/hello_screen.dart';

// استيراد مكتبة WebView للأندرويد
import 'package:webview_flutter_android/webview_flutter_android.dart';

void main() async {
  // التأكد من تهيئة كل أدوات فلاتر قبل التشغيل
  WidgetsFlutterBinding.ensureInitialized();


  // ✅ حل مشكلة الويب: تشغيل الـ Debugging للأندرويد "فقط" إذا لم نكن على الويب
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    AndroidWebViewController.enableDebugging(true);
  }

  // تحميل الجلسة والتوكن
  await UserSession.loadSession();
  final token = UserSession.token;

  // تحميل الإعدادات المحفوظة (اللغة والوضع الليلي)
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  final language = prefs.getString('language') ?? 'en';

  runApp(MyApp(
    isDarkMode: isDark,
    language: language,
    startScreen: token != null ? const HomeScreen() : const LoginScreen(),
  ));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final String language;
  final Widget startScreen;

  const MyApp({
    super.key,
    required this.isDarkMode,
    required this.language,
    required this.startScreen,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkMode;
  late String selectedLanguage;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
    selectedLanguage = widget.language;
    _initDeepLinks();
  }

  // تهيئة روابط الـ Deep Links (مثل استعادة كلمة السر)
  void _initDeepLinks() {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((uri) {
      if (uri == null) return;

      final email = uri.queryParameters['email'];
      final token = uri.queryParameters['token'];

      if (uri.host == "reset-password" && email != null && token != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
              email: email,
              token: token,
            ),
          ),
        );
      }
    });
  }

  Future<void> updateTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() => isDarkMode = value);
  }

  Future<void> updateLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => selectedLanguage = lang);
  }

  ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
    );
  }

  ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = selectedLanguage == 'ar' || selectedLanguage == 'العربية';

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // الشاشة الابتدائية (Splash)
      initialRoute: '/',

      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },

      routes: {
        '/': (_) => const SplashEmptyScreen(),
        '/logo': (_) => const SplashLogoScreen(),
        '/login': (_) => LoginScreen(isDarkMode: isDarkMode),
        '/hello': (_) => const HelloScreen(),
        '/signUp': (_) => const SignUpScreen(),
        '/forget': (_) => const ForgetPass(),
        '/home': (_) => const HomeScreen(),
        '/chat': (_) => const ChatWithUs(),
        '/communication': (_) => const Communication(),
        '/emergency': (_) => const EmergencyPage(),
        '/learning': (_) => const Learning(),
        '/level': (_) => const LevelScreen(levelId: 1),
        '/setting': (_) => SettingsScreen(
              isDarkMode: isDarkMode,
              selectedLanguage: selectedLanguage,
              onThemeChanged: updateTheme,
              onLanguageChanged: updateLanguage,
              t: (key) => key,
            ),
      },
    );
  }
}