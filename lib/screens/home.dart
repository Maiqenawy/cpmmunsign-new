import 'dart:async';
import 'package:cominsign_new/core/app_lang.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:cominsign_new/screens/chat_with_us.dart';
import 'package:cominsign_new/screens/learning.dart';
import 'package:cominsign_new/screens/newcontact_page.dart';
import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  late final Animation<double> _wave;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _wave = Tween<double>(
      begin: -0.03,
      end: 0.03,
    ).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _showTopLoginToast(BuildContext context) {
    TopLoginToast.show(
      context: context,
      message: AppLang.t('login_required') ??
          'Please login first to access this feature',
      onLogin: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double welcomeHeight = screenHeight * 0.18;
    final double welcomeWidth = screenWidth * 0.85;
    final double menuButtonHeight = screenHeight * 0.10;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ================= Header =================
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      AppLang.t('COMMUNSIGN'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/setting'),
                      child: const Icon(
                        Icons.settings,
                        size: 36,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= Welcome =================
              Transform.translate(
                offset: const Offset(-12, 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: welcomeWidth,
                      height: welcomeHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD0EDEA), Color(0xFFA8D6D0)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLang.t('welcome'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'images/download (2).png',
                            height: welcomeHeight * 0.22,
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      right: -35,
                      bottom: -10,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _wave.value,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'images/download (1).png',
                          height: welcomeHeight * 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= Buttons =================
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MenuButton(
                        imagePath: 'images/download (3).png',
                        text: AppLang.t('chat with us'),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2AA88F), Color(0xFF114238)],
                        ),
                        height: menuButtonHeight,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChatWithUs(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      MenuButton(
                        imagePath: 'images/download (4).png',
                        text: AppLang.t('learning'),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF687B95), Color(0xFFAFD0FB)],
                        ),
                        height: menuButtonHeight,
                        onTap: () {
                          if (UserSession.isGuest) {
                            _showTopLoginToast(context);
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Learning(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      MenuButton(
                        imagePath: 'images/download (5).png',
                        text: AppLang.t('communication'),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC2EAE2), Color(0xFF6E8480)],
                        ),
                        height: menuButtonHeight,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChatWithUs(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      MenuButton(
                        imagePath: 'images/download (6).png',
                        text: AppLang.t('emergency'),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF0000), Color(0xFF990000)],
                        ),
                        height: menuButtonHeight,
                        onTap: () {
                          if (UserSession.isGuest) {
                            _showTopLoginToast(context);
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewContactPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Menu Button =================
class MenuButton extends StatelessWidget {
  final String imagePath;
  final String text;
  final Gradient gradient;
  final VoidCallback onTap;
  final double height;

  const MenuButton({
    super.key,
    required this.imagePath,
    required this.text,
    required this.gradient,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 36, height: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Toast =================
class TopLoginToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show({
    required BuildContext context,
    required String message,
    required VoidCallback onLogin,
  }) {
    _timer?.cancel();
    _entry?.remove();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (ctx) {
        final top = MediaQuery.of(ctx).padding.top;
        return Positioned(
          top: top + 10,
          left: 10,
          right: 10,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: onLogin,
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);

    _timer = Timer(const Duration(seconds: 3), () {
      _entry?.remove();
      _entry = null;
    });
  }
}