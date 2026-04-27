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
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final padding = size.width * 0.06;

    final iconColor = isDark ? Colors.white : const Color(0xFF2A405D);
    final textColor = isDark ? Colors.white70 : const Color(0xFF2A405D);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified,
                        size: size.width * 0.25,
                        color: iconColor,
                      ),

                      SizedBox(height: size.height * 0.02),

                      SizedBox(
                        width: size.width * 0.08,
                        height: size.width * 0.08,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: iconColor,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      Text(
                        "Loading...",
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}