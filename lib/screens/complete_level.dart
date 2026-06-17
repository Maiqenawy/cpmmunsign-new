import 'package:cominsign_new/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';

// 🛠️ تأكدي من عمل import لملف الـ GradientBackground إذا كان في ملف خارجي، مثل:
// import 'package:your_app/widgets/gradient_background.dart';

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
      // تم استخدام الـ GradientBackground كخلفية أساسية تحت المحتوى والاحتفالات
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // حساب الأبعاد ديناميكياً بناءً على حجم الشاشة الحالي لضمان الـ Responsiveness
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;

              // جعل قطر الصورة مرن ومتناسب مع حجم الشاشة (بين 130 و 190 بكسل)
              final imageSize = (screenHeight * 0.22).clamp(130.0, 190.0);

              return Stack(
                children: [
                  /// 🎉 Confetti (تأثير قصاصات الورق الاحتفالية)
                  ...List.generate(
                    25,
                    (index) => FloatingConfetti(
                      controller: _controller,
                      index: index,
                    ),
                  ),

                  /// ✅ المحتوى الرئيسي للشاشة
                  Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // النجوم العلوية
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: screenHeight * 0.04),
                              const SizedBox(width: 5),
                              Icon(Icons.star, color: Colors.amber, size: screenHeight * 0.06),
                              const SizedBox(width: 5),
                              Icon(Icons.star, color: Colors.amber, size: screenHeight * 0.04),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // اسم التطبيق
                          Text(
                            "COMMUNISIGN",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (screenHeight * 0.035).clamp(24.0, 32.0),
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF114B5F),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),

                          // أيقونة الكأس
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: (screenHeight * 0.1).clamp(60.0, 90.0),
                          ),
                          SizedBox(height: screenHeight * 0.025),

                          /// 🖼️ مكان الصورة الدائرية (بدون الشادو الأصفر)
                          Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                // شادو رمادي خفيف وناعم لإعطاء عمق طبيعي للصورة الدائرية
                                BoxShadow(
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage(
                                  'images/download (10).png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // نص العملات المكتسبة
                          Text(
                            "You earned ${widget.coinsEarned} coins!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (screenHeight * 0.028).clamp(18.0, 24.0),
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF114B5F),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),

                          // نص التهنئة
                          Text(
                            "Yay! Level Up!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (screenHeight * 0.04).clamp(26.0, 34.0),
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF114B5F),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // الوصف والتشجيع
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                            child: Text(
                              "Great job! Keep learning and unlock more signs.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (screenHeight * 0.022).clamp(14.0, 18.0),
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),

                          // زر المتابعة المتجاوب
                          SizedBox(
                            width: (screenWidth * 0.6).clamp(180.0, 260.0),
                            height: (screenHeight * 0.065).clamp(45.0, 55.0),
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
                                elevation: 6,
                              ),
                              child: const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// 🔙 زر العودة العلوي
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
              );
            },
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