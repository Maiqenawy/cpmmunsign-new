import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class AvatarScreen extends StatefulWidget {
  final String animation; // اسم الملف اللي جاي من API

  const AvatarScreen({
    super.key,
    required this.animation,
  });

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  String? currentAnimation;

  @override
  void initState() {
    super.initState();
    currentAnimation = widget.animation;
  }

  @override
  void didUpdateWidget(covariant AvatarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // لو اتغيرت الكلمة → شغل أنيميشن جديد
    if (oldWidget.animation != widget.animation) {
      setState(() {
        currentAnimation = widget.animation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: currentAnimation == null || currentAnimation == "idle"
          ? const IdleAvatar()
          : ModelViewer(
            src: "assets/$currentAnimation.glb",
              autoPlay: true,
              cameraControls: false,
              disableZoom: true,
              backgroundColor: Colors.transparent,
            ),
    );
  }
}
