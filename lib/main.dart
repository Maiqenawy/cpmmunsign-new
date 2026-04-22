import 'package:cominsign/lib/core/user_session.dart';
import 'package:cominsign/screens/Level_screen.dart';
import 'package:cominsign/screens/chat_with_us.dart';
import 'package:cominsign/screens/communication.dart';
import 'package:cominsign/screens/emergency.dart';
import 'package:cominsign/screens/forget_pass.dart';
import 'package:cominsign/screens/hello_screen.dart';
import 'package:cominsign/screens/home.dart';
import 'package:cominsign/screens/learning.dart';
import 'package:cominsign/screens/login_screen.dart';
import 'package:cominsign/screens/reset_password.dart';
import 'package:cominsign/screens/setting.dart';
import 'package:cominsign/screens/signUp.dart';
import 'package:cominsign/screens/splash_empty.dart';
import 'package:cominsign/screens/splash_logo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await UserSession.loadToken();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;

  const language = 'English';
  await AppLang.load('English');

  runApp(MyApp(isDarkMode: isDark, language: language));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final String language;

  const MyApp({super.key, required this.isDarkMode, required this.language});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late bool isDarkMode;
  late String selectedLanguage;

  late AppLinks _appLinks;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    isDarkMode = widget.isDarkMode;
    selectedLanguage = widget.language;

    /// Deep Link Setup
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((uri) {

      if (uri != null) {

        String? email = uri.queryParameters['email'];
        String? token = uri.queryParameters['token'];

        if (uri.host == "reset-password") {

          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(
                email: email!,
                token: token!,
              ),
            ),
          );

        }
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

  @override
  Widget build(BuildContext context) {

    final isArabic = selectedLanguage == 'العربية';

    return MaterialApp(

      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,

      builder: (context, child) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),

      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      initialRoute: '/',

      routes: {

        '/': (_) => const SplashEmptyScreen(),

        '/logo': (_) => const SplashLogoScreen(),

        '/login': (_) => const LoginScreen(),

        '/hello': (_) => const HelloScreen(),

        '/signUp': (_) => const SignUpScreen(),

        '/forget': (_) => const ForgetPass(),

        '/home': (_) => const HomeScreen(),

        '/chat': (_) => const ChatWithUs(),

        '/communication': (_) => const Communication(),

        '/emergency': (_) => const EmergencyPage(),

        '/learning': (_) => const Learning(),

        '/level': (_) => const LevelScreen(levelId: 1,),

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
