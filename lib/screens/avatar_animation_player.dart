import 'dart:async';
import 'package:flutter/material.dart';
import '../models/avatar_sign_model.dart';

class AvatarAnimationPlayer extends StatefulWidget {
  final List<AvatarSign> signs;

  const AvatarAnimationPlayer({
    super.key,
    required this.signs,
  });

  @override
  State<AvatarAnimationPlayer> createState() =>
      _AvatarAnimationPlayerState();
}

class _AvatarAnimationPlayerState
    extends State<AvatarAnimationPlayer> {

  int currentSign = 0;
  int currentFrame = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    startAnimation();
  }

  void startAnimation() {
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (!mounted) return;

        final sign = widget.signs[currentSign];

        setState(() {
          currentFrame++;

          if (currentFrame >= sign.frames.length) {
            currentFrame = 0;

            currentSign++;

            if (currentSign >= widget.signs.length) {
              currentSign = 0;
            }
          }
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final sign = widget.signs[currentSign];
    final frame = sign.frames[currentFrame];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Text(
          sign.word,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: CustomPaint(
            painter: HandPainter(frame),
            child: Container(),
          ),
        ),
      ],
    );
  }
}

class HandPainter extends CustomPainter {

  final AvatarFrame frame;

  HandPainter(this.frame);

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;

    for (var point in frame.leftHand) {

      final x = point[0] * size.width;
      final y = point[1] * size.height;

      canvas.drawCircle(
        Offset(x, y),
        4,
        paint,
      );
    }

    for (var point in frame.rightHand) {

      final x = point[0] * size.width;
      final y = point[1] * size.height;

      canvas.drawCircle(
        Offset(x, y),
        4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
