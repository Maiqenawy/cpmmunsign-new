import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class AvatarWidget extends StatelessWidget {
  final String currentGesture;

  const AvatarWidget({
    super.key,
    required this.currentGesture,
  });

  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      src: 'assets/models/$currentGesture.glb',
      cameraControls: true,
    );
  }
}