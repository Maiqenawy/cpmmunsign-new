import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'login_screen.dart';

class HelloScreen extends StatefulWidget {
  const HelloScreen({super.key});

  @override
  State<HelloScreen> createState() => _HelloScreenState();
}

class _HelloScreenState extends State<HelloScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted || _navigated) return;
        _navigated = true;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. فحص هل النظام الحالي هو الـ Dark Mode أم لا
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 2. تعيين لون خلفية مناسب للـ Scaffold في حالة الـ Dark Mode
      backgroundColor: isDark ? const Color(0xFF0F1A24) : Colors.transparent,
      body: GradientBackground(
        child: Center(
          child: SlideTransition(
            position: _animation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/love.png',
                  height: 32,
                  // يمكنك إضافة colorBlendMode أو تصفية الأيقونة إذا كانت بحاجة لتفتيح في الـ Dark Mode
                ),
                const SizedBox(width: 10),
                Text(
                  "Made with love and AI",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    // 3. تحويل لون النص ديناميكياً ليصبح أبيض في الدارك مود
                    color: isDark ? Colors.white : const Color(0xff2A405D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}