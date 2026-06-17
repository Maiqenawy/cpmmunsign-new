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
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _playSuccessSound();
  }

  Future<void> _playSuccessSound() async {
    await player.play(
      AssetSource(
        'sounds/freesound_community-success-1-6297.mp3',
      ),
    );
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF111111),
                    Color(0xFF222222),
                    Color(0xFF000000),
                  ]
                : const [
                    Color(0xFFE0F7FA),
                    Color(0xFF80DEEA),
                    Color(0xFF26C6DA),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              /// 🎉 Confetti
              ...List.generate(
                25,
                (index) => FloatingConfetti(
                  controller: _controller,
                  index: index,
                ),
              ),

              /// ✅ Main Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 35),
                          SizedBox(width: 5),
                          Icon(Icons.star, color: Colors.amber, size: 50),
                          SizedBox(width: 5),
                          Icon(Icons.star, color: Colors.amber, size: 35),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "COMMUNISIGN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF114B5F),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 90,
                      ),
                      const SizedBox(height: 20),
                      
                      /// 🛠️ تم إصلاح الخطأ هنا بدمج الـ BoxDecoration
                      Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(.6),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              blurRadius: 15,
                              spreadRadius: 4,
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/download10.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "You earned ${widget.coinsEarned} coins!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF114B5F),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Yay! Level Up!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF114B5F),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Great job! Keep learning and unlock more signs.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 230,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.teal
                                : const Color(0xFF114B5F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔙 Back
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: isDark ? Colors.white : Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
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
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.blue,
    ];

    final color = colors[index % colors.length];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value + index * 0.04) % 1.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Positioned(
          left: startX * screenWidth + math.sin(progress * math.pi * 2) * 30,
          top: progress * screenHeight,
          child: Transform.rotate(
            angle: progress * math.pi * 4,
            child: Container(
              width: 18,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }
}