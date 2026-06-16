import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AvatarScreen extends StatefulWidget {
  final List<dynamic> signs;

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
  bool isModelLoaded = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((message) {
        if (message.message == "MODEL_LOADED") {
          debugPrint("Model Loaded ✔");
          isModelLoaded = true;

          startAnimation(); // تشغيل مرة واحدة فقط
        }
      })
      ..loadFlutterAsset('assets/avatar_player.html');
  }

  Future<void> startAnimation() async {
    if (isAnimating) return; // يمنع التكرار
    isAnimating = true;

    debugPrint("START ANIMATION");

    while (mounted && isAnimating) {
      if (!isModelLoaded) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      if (widget.signs.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      final sign = widget.signs[currentSign];

      if (sign.frames.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      if (currentFrame >= sign.frames.length) {
        currentFrame = 0;
        currentSign++;

        if (currentSign >= widget.signs.length) {
          currentSign = 0;
        }

        continue;
      }

      final List<double> currentLandmarks = sign.frames[currentFrame];

      if (currentLandmarks.length >= 126) {
        var leftHand = currentLandmarks.sublist(0, 63);
        var rightHand = currentLandmarks.sublist(63, 126);

        var leftHandFormatted = _formatLandmarks(leftHand);
        var rightHandFormatted = _formatLandmarks(rightHand);

        try {
          await controller.runJavaScript('''
            if (typeof animateFrame === "function") {
              animateFrame(${jsonEncode({
            "leftHand": leftHandFormatted,
            "rightHand": rightHandFormatted,
          })});
            }
          ''');
        } catch (e) {
          debugPrint("JS Error: $e");
        }
      } else {
        debugPrint("Invalid frame data");
      }

      currentFrame++;

      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  List<List<double>> _formatLandmarks(List<double> flatList) {
    List<List<double>> formatted = [];

    for (int i = 0; i < flatList.length; i += 3) {
      formatted.add([
        flatList[i],
        flatList[i + 1],
        flatList[i + 2],
      ]);
    }

    return formatted;
  }

  @override
  void dispose() {
    isAnimating = false; // وقف اللوب عند الخروج
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: controller,
    );
  }
}