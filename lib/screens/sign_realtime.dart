import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/service/api_service.dart';

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

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        "frame",
        onMessageReceived: (message) {
          List<dynamic> data = jsonDecode(message.message);
          List<double> keypoints =
              data.map((e) => e.toDouble()).toList();

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

    if (frameBuffer.length == 30) {
      try {
        final word = await Service.sendFrames(frameBuffer);

        if (word != lastWord) {
          setState(() {
            sentence += " $word";
            lastWord = word;
          });
        }

      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign → Text (Real-Time)")),

      body: Column(
        children: [

          Expanded(
            flex: 2,
            child: WebViewWidget(controller: controller),
          ),

          Expanded(
            child: Container(
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
