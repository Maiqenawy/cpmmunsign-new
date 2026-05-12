import 'package:cominsign_new/core/user_session.dart';
import 'package:cominsign_new/screens/Level_screen.dart';
import 'package:cominsign_new/screens/chat_with_us.dart';
import 'package:cominsign_new/screens/communication.dart';
import 'package:cominsign_new/screens/emergency.dart';
import 'package:cominsign_new/screens/forget_pass.dart';
import 'package:cominsign_new/screens/hello_screen.dart';
import 'package:cominsign_new/screens/home.dart';
import 'package:cominsign_new/screens/learning.dart' hide LevelScreen;
import 'package:cominsign_new/screens/login_screen.dart';
import 'package:cominsign_new/screens/reset_password.dart';
import 'package:cominsign_new/screens/setting.dart';
import 'package:cominsign_new/screens/signUp.dart';
import 'package:cominsign_new/screens/splash_empty.dart';
import 'package:cominsign_new/screens/splash_logo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserSession.loadSession();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  final language = prefs.getString('language') ?? 'en';

  runApp(MyApp(isDarkMode: isDark, language: language));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final String language;

  const MyApp({
    super.key,
    required this.isDarkMode,
    required this.language,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkMode;
  late String selectedLanguage;

  late AppLinks _appLinks;
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    isDarkMode = widget.isDarkMode;
    selectedLanguage = widget.language;

    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((uri) {
      if (uri == null) return;

      final email = uri.queryParameters['email'];
      final token = uri.queryParameters['token'];

      if (uri.host == "reset-password" &&
          email != null &&
          token != null) {
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

  Future<void> updateLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    setState(() => selectedLanguage = langCode);
  }

  ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        onSurface: Colors.black,
        primary: Colors.blue,
      ),
    );
  }

  ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF121212),
        onSurface: Colors.white,
        primary: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = selectedLanguage == 'ar' || selectedLanguage == 'العربية';

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        return Directionality(
          textDirection:
              isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },

      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      initialRoute: '/',

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