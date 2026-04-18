import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: isDarkMode ? _darkGradient() : _lightGradient(),
      ),
      child: child,
    );
  }

  // 🌞 LIGHT MODE
  Gradient _lightGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFFFFF),  // أبيض
        Color.fromARGB(255, 252, 252, 252),  // أخضر فاتح جداً
        Color(0xFFA4E5DD),  // أخضر فاتح
      ],
    );
  }

  // 🌙 DARK MODE
  Gradient _darkGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF2A405D),  // رمادي غامق
        Color(0xFF2A405D),  // أسود فاتح
        Color(0xFF607673),  // أسود
      ],
    );
  }
}