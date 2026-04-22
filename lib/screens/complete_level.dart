import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

class LevelCompleteScreen extends StatefulWidget {
  final int level;
  final int coinsEarned;

  const LevelCompleteScreen({
    super.key,
    this.level = 1,
    required this.coinsEarned,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    player.setReleaseMode(ReleaseMode.stop);

    Future.delayed(const Duration(milliseconds: 300), () {
      player.play(
        AssetSource('sounds/freesound_community-success-1-6297.mp3'),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF1A1A1A),
                    Color(0xFF2C2C2C),
                    Color(0xFF111111),
                  ]
                : const [
                    Colors.white,
                    Colors.blueAccent,
                    Colors.cyanAccent,
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(
                20,
                (index) => FloatingConfetti(
                  controller: _controller,
                  index: index,
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    'COMMUNISIGN',
                    style: TextStyle(
                      color:
                          isDark ? Colors.white : const Color(0xFF2C5F7C),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('images/download (10).png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'You earned ${widget.coinsEarned} coins!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? Colors.white70 : const Color(0xFF2C5F7C),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Yay! Level up!',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.white : const Color(0xFF2C5F7C),
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1, end: 1),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.tealAccent.shade700
                              : const Color(0xFF2C5F7C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 70,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingConfetti extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const FloatingConfetti({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final startX = random.nextDouble();

    final colors = [
      Colors.pink,
      Colors.blue,
      Colors.yellow,
      Colors.green,
      Colors.orange,
    ];

    final color = colors[index % colors.length];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value + index * 0.05) % 1.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Positioned(
          left:
              startX * screenWidth + math.sin(progress * math.pi * 2) * 30,
          top: progress * screenHeight,
          child: Transform.rotate(
            angle: progress * math.pi * 4,
            child: Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }
}