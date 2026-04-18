import 'package:cominsign/widgets/gradient_background.dart';
import 'package:flutter/material.dart';

class ChatWithUs extends StatelessWidget {
  const ChatWithUs({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final gradientColors = isDark
        ? const [Color(0xFF0F1B1A), Color(0xFF071210)]
        : const [Color(0xFFEFF9F8), Color(0xFFCFEDEA)];

    return Scaffold(
      body: GradientBackground(
      child: Container(

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: cs.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      'COMMUNISIGN',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'images/download (9).png',
                  height: h * 0.50,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Type to translate',
                            hintStyle: TextStyle(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: cs.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.camera_alt_outlined, color: cs.onSurface),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: cs.error,
                        child: IconButton(
                          icon: Icon(Icons.mic, color: cs.onError),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}