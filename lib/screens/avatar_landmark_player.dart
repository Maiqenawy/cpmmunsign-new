import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'avatar_sign_model.dart';

class AvatarLandmarkPlayer extends StatefulWidget {
  final List<AvatarSign> signs;

  const AvatarLandmarkPlayer({
    super.key,
    required this.signs,
  });

  @override
  State<AvatarLandmarkPlayer> createState() => _AvatarLandmarkPlayerState();
}

class _AvatarLandmarkPlayerState extends State<AvatarLandmarkPlayer> {
  Object? avatar;
  Scene? scene;

  int currentSign = 0;
  int currentFrame = 0;

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Cube(
      onSceneCreated: onSceneCreated,
    );
  }

  void onSceneCreated(Scene scene) {
    this.scene = scene;

    scene.camera.zoom = 10;

    avatar = Object(
      fileName: 'assets/avatar.glb',
    );

    scene.world.add(avatar!);

    startAnimation();
  }

  void startAnimation() {
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (avatar == null || widget.signs.isEmpty) return;

        final sign = widget.signs[currentSign];

        if (sign.landmarks.isEmpty) return;

        final frame = sign.landmarks[currentFrame];

        animateHands(frame);

        currentFrame++;

        if (currentFrame >= sign.framesCount) {
          currentFrame = 0;
          currentSign++;

          if (currentSign >= widget.signs.length) {
            currentSign = 0;
          }
        }
      },
    );
  }

  void animateHands(List<double> frame) {
    if (avatar == null) return;

    try {
      if (frame.length < 2) return;

      final x = frame[0];
      final y = frame[1];

      avatar!.rotation.y = x * 100;
      avatar!.rotation.x = y * 100;

      avatar!.updateTransform();
      scene?.update();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}