import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';


class LevelCompleteScreen extends StatefulWidget {
  final int level;
  final int coinsEarned;

  const LevelCompleteScreen({
    Key? key,
    this.level = 1,
    required this.coinsEarned,
  }) : super(key: key);

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

    /// 🔊 تشغيل الصوت مرة واحدة مع الأنيميشن
    player.setReleaseMode(ReleaseMode.stop);

    Future.delayed(const Duration(milliseconds: 300), () {
      player.play(AssetSource('sounds/freesound_community-success-1-6297.mp3'));
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
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blueAccent,
              Colors.cyanAccent,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              /// 🎉 Confetti
              ...List.generate(20, (index) {
                return FloatingConfetti(
                  controller: _controller,
                  index: index,
                );
              }),

              /// 📱 المحتوى
              Column(
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    'COMMUNISIGN',
                    style: TextStyle(
                      color: Color(0xFF2C5F7C),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const Spacer(),

                  /// 🏅 الدائرة (الليفل)
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${widget.level}',
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 💰 الكوينز
                  Text(
                    'You earned ${widget.coinsEarned} coins!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C5F7C),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Yay! Level up!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C5F7C),
                    ),
                  ),

                  const Spacer(),

                  /// 🔘 زرار Continue
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5F7C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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

/// 🎉 الكونفيتي
class FloatingConfetti extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const FloatingConfetti({
    Key? key,
    required this.controller,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final startX = random.nextDouble();
    final size = 20 + random.nextDouble() * 30;
    final colors = [
      Colors.pink,
      Colors.blue,
      Colors.yellow,
      Colors.green,
      Colors.orange
    ];
    final color = colors[index % colors.length];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value + index * 0.05) % 1.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Positioned(
          left: startX * screenWidth +
              math.sin(progress * math.pi * 2) * 30,
          top: progress * screenHeight,
          child: Transform.rotate(
            angle: progress * math.pi * 4,
            child: Container(
              width: size,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        );
      },
    );
  }
}