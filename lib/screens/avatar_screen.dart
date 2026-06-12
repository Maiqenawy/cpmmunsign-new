import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AvatarScreen extends StatefulWidget {
  final List<dynamic> signs;

  const AvatarScreen({
    super.key,
    required this.signs,
  });

  @override
  State<AvatarScreen> createState() =>
      _AvatarScreenState();
}

class _AvatarScreenState
    extends State<AvatarScreen> {

  late final WebViewController controller;

  int currentSign = 0;
  int currentFrame = 0;

  @override
  void initState() {
    super.initState();

    controller =
        WebViewController()
          ..setJavaScriptMode(
            JavaScriptMode.unrestricted,
          )
          ..loadFlutterAsset(
            'assets/avatar_player.html',
          );

    Future.delayed(
      const Duration(seconds: 2),
      startAnimation,
    );
  }

  Future<void> startAnimation() async {

    while (mounted) {

      if (widget.signs.isEmpty) {
        await Future.delayed(
          const Duration(milliseconds: 100),
        );
        continue;
      }

      final sign =
          widget.signs[currentSign];

      final frame =
          sign.frames[currentFrame];

      await controller.runJavaScript(
        '''
        animateFrame(
          ${jsonEncode({
            "leftHand": frame.leftHand,
            "rightHand": frame.rightHand,
          })}
        );
        ''',
      );

      await Future.delayed(
        const Duration(milliseconds: 40),
      );

      currentFrame++;

      if (currentFrame >= sign.frames.length) {

        currentFrame = 0;

        currentSign++;

        if (currentSign >=
            widget.signs.length) {
          currentSign = 0;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
