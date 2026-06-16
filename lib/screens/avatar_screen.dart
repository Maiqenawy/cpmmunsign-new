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

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
     ..setOnConsoleMessage((message) {
    if (message.message == "MODEL_LOADED") {
      debugPrint("JS says Model is Loaded! Starting animation...");
      startAnimation(); // 🟢 نبدأ الأنيميشن فوراً لما الجافا سكريبت يأكد
    }
  })
  ..loadFlutterAsset('assets/avatar_player.html');

  Future<void> startAnimation() async {
     debugPrint(
    "START ANIMATION CALLED"
  );

  debugPrint(
    "SIGNS COUNT = ${widget.signs.length}"
  );
    while (mounted) {
      if (widget.signs.isEmpty) {
        await Future.delayed(
          const Duration(milliseconds: 100),
        );
        continue;
      }

      final sign = widget.signs[currentSign];
       debugPrint(
      "CURRENT SIGN = $currentSign"
    );

    debugPrint(
      "TOTAL FRAMES = ${sign.frames.length}"
    );
      
      // بافتراض أن الـ frame عبارة عن مصفوفة مسطحة List<double> تحتوي على كل الـ landmarks
      final List<double> currentLandmarks = sign.frames[currentFrame];

      // التحقق من أن بيانات الفريم مكتملة (21 نقطة لكل يد * 3 أبعاد = 126 قيمة)
      if (currentLandmarks.length >= 126) {
        // تقسيم الـ Landmarks لـ leftHand و rightHand
        var leftHand = currentLandmarks.sublist(0, 63);
        var rightHand = currentLandmarks.sublist(63, 126);

        // تحويل المصفوفة المسطحة إلى مصفوفة ثنائية الأبعاد يفهمها الـ JavaScript
        var leftHandFormatted = _formatLandmarks(leftHand);
        var rightHandFormatted = _formatLandmarks(rightHand);
debugPrint(
  "SENDING FRAME $currentFrame"
);

        // إرسال البيانات المجهزة للـ JavaScript داخل الـ WebView
        await controller.runJavaScript(
          '''
          animateFrame(
            ${jsonEncode({
              "leftHand": leftHandFormatted,
              "rightHand": rightHandFormatted,
            })}
          );
          ''',
        );
      } else {
        debugPrint("Warning: Frame data is incomplete or invalid!");
      }

      // مدة الانتظار بين الفريم والآخر (30 إلى 40 مللي ثانية تعطي سلاسة ممتازة)
      await Future.delayed(
        const Duration(milliseconds: 30),
      );

      currentFrame++;

      // الانتقال إلى الفريم التالي أو الإشارة التالية
      if (currentFrame >= sign.frames.length) {
        currentFrame = 0;
        currentSign++;

        if (currentSign >= widget.signs.length) {
          currentSign = 0; // إعادة الأنيميشن من البداية عند الانتهاء
        }
      }
    }
  }

  // دالة مساعدة لتحويل المصفوفة المسطحة لمصفوفة ثنائية الأبعاد (كل 3 قيم X, Y, Z في مصفوفة فرعية)
  List<List<double>> _formatLandmarks(List<double> flatList) {
    List<List<double>> formatted = [];
    for (int i = 0; i < flatList.length; i += 3) {
      formatted.add([flatList[i], flatList[i + 1], flatList[i + 2]]);
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: controller,
    );
  }
}
