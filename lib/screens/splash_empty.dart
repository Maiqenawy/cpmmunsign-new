import 'package:cominsign/screens/splash_logo.dart';
import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

class SplashEmptyScreen extends StatefulWidget {
  const SplashEmptyScreen({super.key});

  @override
  State<SplashEmptyScreen> createState() => _SplashEmptyScreenState();
}

class _SplashEmptyScreenState extends State<SplashEmptyScreen> {
  @override
  void initState() {
    super.initState();

    // الانتقال التلقائي بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashLogoScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GradientBackground(
        child: SizedBox.shrink(), // الصفحة فاضية
      ),
    );
  }
}
