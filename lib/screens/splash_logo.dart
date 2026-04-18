import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'hello_screen.dart';

class SplashLogoScreen extends StatefulWidget {
  const SplashLogoScreen({super.key});

  @override
  State<SplashLogoScreen> createState() => _SplashLogoScreenState();
}

class _SplashLogoScreenState extends State<SplashLogoScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    // الانتقال التلقائي بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HelloScreen()),
      );
    });

    // إعداد الحركة للنص
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 1), // البداية من أسفل
      end: Offset.zero,           // النهاية في المركز
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(); // بدء الحركة
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      body: GradientBackground(
         
        child: Center(
          child: SlideTransition(
            position: _animation,
            child: const Text(
              "COMMUNSIGN",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
               color: Color(0xff2A405D),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
