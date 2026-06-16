import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'avatar_sign_model.dart';

class AvatarScreen extends StatefulWidget {
  final List<AvatarSign> signs;

  const AvatarScreen({
    super.key,
    required this.signs,
  });

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  late final WebViewController controller;

  int currentSign = 0;
  int currentFrame = 0;

  bool isAnimating = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setOnConsoleMessage((message) {
       if (message.message == "MODEL_LOADED") {
  debugPrint("MODEL LOADED");

  if (widget.signs.isNotEmpty) {
    startAnimation();
  }
}
      })
      ..loadFlutterAsset(
        'assets/avatar_player.html',
      );
  }

  @override
  void didUpdateWidget(
    AvatarScreen oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.signs != widget.signs &&
        widget.signs.isNotEmpty) {
      currentSign = 0;
      currentFrame = 0;

      startAnimation();
    }
  }

  Future<void> startAnimation() async {
    if (isAnimating) return;

    if (widget.signs.isEmpty) return;

    isAnimating = true;

    try {
      while (
          mounted &&
          currentSign < widget.signs.length) {
        final sign =
            widget.signs[currentSign];

        debugPrint(
          "CURRENT SIGN = $currentSign",
        );

        while (
            mounted &&
            currentFrame <
                sign.landmarks.length) {
          final List<double>
              currentLandmarks =
              List<double>.from(
            sign.landmarks[currentFrame],
          );

          if (currentLandmarks.length >= 126) {
            final leftHand =
                currentLandmarks.sublist(
              0,
              63,
            );

            final rightHand =
                currentLandmarks.sublist(
              63,
              126,
            );

            final leftHandFormatted =
                _formatLandmarks(
              leftHand,
            );

            final rightHandFormatted =
                _formatLandmarks(
              rightHand,
            );

            await controller.runJavaScript(
              '''
window.animateFrame(
${jsonEncode({
                "leftHand":
                    leftHandFormatted,
                "rightHand":
                    rightHandFormatted,
              })}
);
''',
            );
          }

          await Future.delayed(
            const Duration(
              milliseconds: 30,
            ),
          );

          currentFrame++;
        }

        currentFrame = 0;
        currentSign++;
      }

      currentSign = 0;
      currentFrame = 0;
    } catch (e) {
      debugPrint(
        "Animation Error = $e",
      );
    } finally {
      isAnimating = false;
    }
  }

  List<List<double>> _formatLandmarks(
    List<double> flatList,
  ) {
    List<List<double>> formatted = [];

    for (
      int i = 0;
      i < flatList.length;
      i += 3
    ) {
      formatted.add([
        flatList[i],
        flatList[i + 1],
        flatList[i + 2],
      ]);
    }

    return formatted;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return WebViewWidget(
      controller: controller,
    );
  }
}