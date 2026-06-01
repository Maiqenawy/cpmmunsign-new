import 'dart:async';
import 'package:cominsign_new/screens/avatar_sign_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
class AvatarLandmarkPlayer extends StatefulWidget {

  final List<AvatarSign> signs;

  const AvatarLandmarkPlayer({
    super.key,
    required this.signs,
  });

  @override
  State<AvatarLandmarkPlayer> createState()
      => _AvatarLandmarkPlayerState();
}

class _AvatarLandmarkPlayerState
    extends State<AvatarLandmarkPlayer> {

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
      fileName: 'assets/avatar/avatar.glb',
    );

    scene.world.add(avatar!);

    startAnimation();
  }

  void startAnimation() {

    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {

        if (avatar == null) return;

        final sign =
            widget.signs[currentSign];

        final frame =
            sign.frames[currentFrame];

        animateHands(frame);

        currentFrame++;

        if (currentFrame >= sign.frames.length) {

          currentFrame = 0;

          currentSign++;

          if (currentSign >= widget.signs.length) {

            currentSign = 0;
          }
        }
      },
    );
  }

  void animateHands(AvatarFrame frame) {

    if (avatar == null) return;

    try {

      final leftX =
          frame.leftHand[0][0];

      final leftY =
          frame.leftHand[0][1];

      final rightX =
          frame.rightHand[0][0];

      final rightY =
          frame.rightHand[0][1];

      avatar!.rotation.y =
          rightX * 100;

      avatar!.rotation.x =
          leftY * 100;

      avatar!.updateTransform();

      scene?.update();
    }
    catch (e) {

      print(e);
    }
  }

  @override
  void dispose() {

    timer?.cancel();

    super.dispose();
  }
}
