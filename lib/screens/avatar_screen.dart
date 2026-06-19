import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'avatar_sign_model.dart';

class AvatarScreen extends StatefulWidget {
  final List<AvatarSign> signs;
  const AvatarScreen({super.key, required this.signs});
  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  late final WebViewController controller;
  int currentSign = 0;
  int currentFrame = 0;
  bool isJsReady = false;
  bool isAnimating = false;
  bool _pendingAnimation = false;

  @override
  void initState() {
    super.initState();
    debugPrint("AvatarScreen initState");
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((message) {
        debugPrint("JS: ${message.message}");
        if (message.message == "MODEL_LOADED") {
          isJsReady = true;
          debugPrint(
            "JS READY — pendingAnimation=$_pendingAnimation signs=${widget.signs.length}",
          );
          if (_pendingAnimation && widget.signs.isNotEmpty) {
            _pendingAnimation = false;
            startAnimation();
          }
        }
      })
      ..loadFlutterAsset('assets/avatar_player.html');
  }

  @override
  void didUpdateWidget(covariant AvatarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.signs.isEmpty) {
      controller.runJavaScript(
        "if (window.setIdleMode) { window.setIdleMode(); }",
      );
      return;
    }

    if (oldWidget.signs != widget.signs && widget.signs.isNotEmpty) {
      currentSign = 0;
      currentFrame = 0;
      debugPrint(
        "AvatarScreen received ${widget.signs.length} signs — isJsReady=$isJsReady",
      );

      if (isJsReady) {
        startAnimation();
      } else {
        _pendingAnimation = true;
        debugPrint("JS not ready yet — animation pending");
      }
    }
  }

  Future<void> startAnimation() async {
    if (isAnimating || widget.signs.isEmpty || !isJsReady) return;
    isAnimating = true;

    try {
      while (mounted && currentSign < widget.signs.length) {
        final sign = widget.signs[currentSign];

        // تصفير الفريمات مع كل كلمة جديدة
        currentFrame = 0;

        while (mounted && currentFrame < sign.landmarks.length) {
          final flat = List<double>.from(sign.landmarks[currentFrame]);

          // التأكد من إن الفريم جواه الـ 126 نقطة بتوع الإيدين كاملين
      if (flat.length >= 258) {
            final left = _format(flat.sublist(132, 195));
final right = _format(flat.sublist(195, 258));

            // تحويل البيانات لـ JSON وإرسالها للـ HTML
            final String jsonData = jsonEncode({
              "leftHand": left,
              "rightHand": right,
            });

            await controller.runJavaScript('''
              if (typeof window.animateFrame === 'function') {
                window.animateFrame($jsonData);
              }
            ''');
          }

          // سرعة نقل الفريمات (50 ملي ثانية)
          await Future.delayed(const Duration(milliseconds: 50));
          currentFrame++;
        }

        currentSign++;
      }

      // بعد ما يخلص حركات يرجع للوضع الثابت (Idle)
      if (mounted) {
        await controller.runJavaScript(
          "if (window.setIdleMode) { window.setIdleMode(); }",
        );
      }
    } catch (e) {
      debugPrint("Error in Animation Loop: $e");
    } finally {
      isAnimating = false;
      currentSign = 0;
      currentFrame = 0;
    }
  }

  List<List<double>> _format(List<double> data) {
    List<List<double>> out = [];
    for (int i = 0; i < data.length; i += 3) {
      out.add([data[i], data[i + 1], data[i + 2]]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
