import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cominsign_new/widgets/gradient_background.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  String currentAnimation = "idle";

  void changeAnimation(String newAnimation) {
    setState(() {
      currentAnimation = newAnimation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            Expanded(
              child: ModelViewer(
                src:
                    'assets/cartoon_male_characters_-_low-poly_3d_model.glb',
                alt: "A 3D model of an avatar",
                backgroundColor: Colors.transparent,
                autoPlay: true,
                ar: true,
                autoRotate: false,
                cameraControls: true,

                // ⭐ هنا الربط الصحيح
                animationName: currentAnimation,
              ),
            ),

            // 🔘 أزرار تجربة الأنيميشن
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () => changeAnimation("idle"),
                    child: const Text("Idle"),
                  ),
                  ElevatedButton(
                    onPressed: () => changeAnimation("wave"),
                    child: const Text("Wave"),
                  ),
                  ElevatedButton(
                    onPressed: () => changeAnimation("run"),
                    child: const Text("Run"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}