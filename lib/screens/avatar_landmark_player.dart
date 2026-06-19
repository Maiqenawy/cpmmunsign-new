import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 💡 ضروري لقراءة ملفات الـ Assets كـ Bytes
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
  InAppWebViewController? webViewController;
  bool isJsReady = false;
  bool isModelPrepared = false;

  int currentSign = 0;
  int currentFrame = 0;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // 💡 هذه الدالة تقرأ ملف الـ HTML وتدمج جواه الـ GLB كـ Base64
  Future<void> _loadHtmlWithEmbeddedModel() async {
    if (webViewController == null) return;

    try {
      // 1. قراءة ملف الـ HTML الأصلي كـ نص
      String htmlContent = await rootBundle.loadString('assets/avatar_player.html');

      // 2. قراءة ملف الـ GLB وتحويله إلى سيل من الـ Bytes ثم إلى Base64
      final ByteData glbData = await rootBundle.load('assets/avatar.glb');
      final List<int> glbBytes = glbData.buffer.asUint8List(glbData.offsetInBytes, glbData.lengthInBytes);
      String glbBase64 = base64Encode(glbBytes);

      // 3. حقن الـ Base64 داخل الـ HTML ليكون جاهزاً للاستخدام فوراً في Babylon
      htmlContent = htmlContent.replaceFirst(
        'window.GLB_BASE64_DATA = null;',
        'window.GLB_BASE64_DATA = "data:model/gltf-binary;base64,$glbBase64";',
      );

      // 4. تحميل الـ HTML المحقون داخل الـ WebView بأمان كامل كـ Data URL
      await webViewController?.loadData(
        data: htmlContent,
        mimeType: "text/html",
        encoding: "utf-8",
      );

      setState(() {
        isModelPrepared = true;
      });
    } catch (e) {
      debugPrint("Error Embedding Model: $e");
    }
  }

  void startAnimation() {
    timer?.cancel();
    timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) {
        if (webViewController == null || !isJsReady || widget.signs.isEmpty) return;

        final sign = widget.signs[currentSign];
        if (sign.landmarks.isEmpty) return;

        final frame = sign.landmarks[currentFrame];
        final String jsonFrame = jsonEncode(frame);
        
        webViewController?.evaluateJavascript(
          source: "window.animateFrame($jsonFrame);"
        );

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

  @override
  Widget build(BuildContext context) {
    if (widget.signs.isEmpty) {
      return const Center(child: Text("لا توجد بيانات للإشارة"));
    }

    return Scaffold(
      body: InAppWebView(
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          supportZoom: false,
          hardwareAcceleration: true, 
          preferredContentMode: UserPreferredContentMode.MOBILE,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
          // أول ما الـ WebView يجهز، نقوم بحقن وتحميل الملف فوراً
          _loadHtmlWithEmbeddedModel();
        },
        onLoadStop: (controller, url) async {
          if (!isModelPrepared) return;
          
          int attempts = 0;
          while (attempts < 30) {
            final isLoaded = await controller.evaluateJavascript(
              source: "window.MODEL_LOADED === true;"
            );
            if (isLoaded == true) {
              setState(() {
                isJsReady = true;
              });
              startAnimation();
              break;
            }
            await Future.delayed(const Duration(milliseconds: 200));
            attempts++;
          }
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint("JS CONSOLE: ${consoleMessage.message}");
        },
      ),
    );
  }
}