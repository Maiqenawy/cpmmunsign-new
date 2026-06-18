import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'avatar_sign_model.dart';

class AvatarScreen extends StatefulWidget {
  final List<AvatarSign> signs;
  const AvatarScreen({super.key, required this.signs});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  InAppWebViewController? webViewController;
  bool isJsReady = false;
  bool isAnimating = false;

  @override
  void didUpdateWidget(covariant AvatarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إعادة تشغيل الحركة إذا تغيرت البيانات
    if (widget.signs != oldWidget.signs && widget.signs.isNotEmpty && isJsReady) {
      startAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialFile: "assets/avatar_player.html",
      initialSettings: InAppWebViewSettings(
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        javaScriptEnabled: true,
      ),
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint("JS: ${consoleMessage.message}");
        if (consoleMessage.message == "MODEL_LOADED") {
          setState(() => isJsReady = true);
          if (widget.signs.isNotEmpty) startAnimation();
        }
      },
    );
  }

  Future<void> startAnimation() async {
    debugPrint("START ANIMATION");
    if (!isJsReady || webViewController == null || isAnimating) return;
    
    isAnimating = true;

    try {
      for (var sign in widget.signs) {
        for (var frame in sign.landmarks) {
          if (!mounted) break;
          
          final flat = List<double>.from(frame);
          final left = _format(flat.sublist(0, 63));
          final right = _format(flat.sublist(63, 126));
debugPrint("FRAME SENT");
          await webViewController!.evaluateJavascript(source: '''
            if (window.animateFrame) {
              window.animateFrame(${jsonEncode({"leftHand": left, "rightHand": right})});
            }
          ''');
          
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
    } finally {
      if (mounted) {
        await webViewController!.evaluateJavascript(source: "if (window.setIdleMode) { window.setIdleMode(); }");
        isAnimating = false;
      }
    }
  }

  List<List<double>> _format(List<double> data) {
    List<List<double>> out = [];
    for (int i = 0; i < data.length; i += 3) {
      out.add([data[i], data[i + 1], data[i + 2]]);
    }
    return out;
  }
}
