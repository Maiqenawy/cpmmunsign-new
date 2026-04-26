import 'dart:convert';
import 'package:cominsign_new/core/service/api-service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SignRealtime extends StatefulWidget {
  const SignRealtime({super.key});

  @override
  State<SignRealtime> createState() => _SignRealtimeState();
}

class _SignRealtimeState extends State<SignRealtime> {
  late final WebViewController controller;

  List<List<double>> frameBuffer = [];
  String sentence = "";
  String lastWord = "";

  List<String> predictions = [];
  bool isSending = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        "SignChannel",
        onMessageReceived: (message) {
          final List<dynamic> data = jsonDecode(message.message);

          // ✅ FIX: proper conversion to List<double>
          final List<double> keypoints = List<double>.from(
            data.map((e) => (e as num).toDouble()),
          );

          onNewFrame(keypoints);
        },
      )
      ..loadFlutterAsset("assets/mediapipe.html");
  }

  void onNewFrame(List<double> keypoints) async {
    frameBuffer.add(keypoints);

    if (frameBuffer.length > 30) {
      frameBuffer.removeAt(0);
    }

    if (frameBuffer.length == 30 && !isSending) {
      isSending = true;

      try {
        final word = await Service.sendFrames(frameBuffer);

        // 🔥 store predictions (sliding window)
        predictions.add(word);

        if (predictions.length > 7) {
          predictions.removeAt(0);
        }

        // ===============================
        // ✅ IMPROVED STABILITY LOGIC
        // majority voting instead of strict equality
        // ===============================
        final Map<String, int> freq = {};

        for (var w in predictions) {
          freq[w] = (freq[w] ?? 0) + 1;
        }

        String bestWord = freq.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        bool isStable = freq[bestWord]! >= 4; // threshold (adjustable)

        if (isStable && bestWord != lastWord) {
          setState(() {
            sentence += " $bestWord";
            lastWord = bestWord;
          });

          predictions.clear();
        }
      } catch (e) {
        print("ERROR: $e");
      }

      await Future.delayed(const Duration(milliseconds: 500));
      isSending = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Real-Time Sign")),

      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: WebViewWidget(controller: controller),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                sentence,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}