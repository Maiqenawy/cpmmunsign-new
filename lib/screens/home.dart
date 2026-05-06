
import 'dart:async';
import 'package:cominsign/screens/newcontact_page.dart';
import 'package:flutter/material.dart';

import 'package:cominsign/core/app_lang.dart';
import 'package:cominsign/lib/core/user_session.dart';
import 'package:cominsign/screens/chat_with_us.dart';
import 'package:cominsign/screens/emergency.dart';
import 'package:cominsign/screens/learning.dart';

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

  // ================= Top Overlay Toast (no overflow) =================
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

    final double welcomeHeight = screenHeight * 0.20;
    final double welcomeWidth = screenWidth * 0.85;
    final double menuButtonHeight = screenHeight * 0.12;
    final double buttonSpacing = screenHeight * 0.015;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ================= Header =================
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      AppLang.t('COMMUNSIGN'),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: GestureDetector(
                        onTap: () {
                          // ✅ فتح Settings من routes علشان تشتغل مع main (دارك/لغة)
                          Navigator.pushNamed(context, '/setting');
                        },
                        child: const Icon(
                          Icons.settings,
                          size: 40,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ================= Welcome Banner =================
              Transform.translate(
                offset: const Offset(-12, 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: welcomeWidth,
                      height: welcomeHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD0EDEA), Color(0xFFA8D6D0)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.10),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLang.t('welcome'),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            'images/download (2).png',
                            height: welcomeHeight * 0.2,
                          ),
                        ],
                      ),
                    ),

                    // ✅ الصورة الكبيرة على يمين البانر + Wave animation
                    Positioned(
                      right: -40,
                      bottom: -15,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _wave.value,
                            alignment: Alignment.bottomCenter,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'images/download (1).png',
                          height: welcomeHeight * 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // ================= Menu Buttons =================
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Column(
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

                      SizedBox(height: buttonSpacing),

                      // ===== Learning (Guest ممنوع) =====
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

                      SizedBox(height: buttonSpacing),

                      MenuButton(
                        imagePath: 'images/download (5).png',
                        text: AppLang.t('communication'),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC2EAE2), Color(0xFF6E8480)],
                        ),
                        height: menuButtonHeight,
                        onTap: () {
                          // ملاحظة: عندك هنا رايح ChatWithUs مش Communication
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                             builder: (_) => const Communication(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: buttonSpacing),

                      // ===== Emergency (Guest ممنوع) =====
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.10),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 40, height: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
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

/// ================= Overlay Top Toast Helper =================
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
    _entry = null;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (ctx) {
        final topPadding = MediaQuery.of(ctx).padding.top;
        return Positioned(
          top: topPadding + 12,
          left: 12,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: _TopToastCard(
              message: message,
              onClose: () {
                _timer?.cancel();
                _entry?.remove();
                _entry = null;
              },
              onLogin: () {
                _timer?.cancel();
                _entry?.remove();
                _entry = null;
                onLogin();
              },
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);

    _timer = Timer(const Duration(seconds: 4), () {
      _entry?.remove();
      _entry = null;
    });
  }
}

class _TopToastCard extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  final VoidCallback onLogin;

  const _TopToastCard({
    required this.message,
    required this.onClose,
    required this.onLogin,
  });

  @override
  State<_TopToastCard> createState() => _TopToastCardState();
}

class _TopToastCardState extends State<_TopToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -0.25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                offset: Offset(0, 6),
                color: Color.fromRGBO(0, 0, 0, 0.18),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: widget.onLogin,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
