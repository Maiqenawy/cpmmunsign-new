import 'package:cominsign_new/screens/splash_logo.dart';
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

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SplashLogoScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: const SizedBox.expand(),
      ),
    );
  }
}