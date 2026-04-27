import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'hello_screen.dart';

class SplashLogoScreen extends StatefulWidget {
  const SplashLogoScreen({super.key});

  @override
  State<SplashLogoScreen> createState() => _SplashLogoScreenState();
}

class _SplashLogoScreenState extends State<SplashLogoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HelloScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _animation,
                      child: Text(
                        "COMMUNSIGN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.10,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? Colors.white
                              : const Color(0xff2A405D),
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    SizedBox(
                      width: size.width * 0.06,
                      height: size.width * 0.06,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
