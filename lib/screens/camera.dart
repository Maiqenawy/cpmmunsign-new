import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class SignRealtime extends StatefulWidget {
  const SignRealtime({super.key});

  @override
  State<SignRealtime> createState() => _SignRealtimeState();
}

class _SignRealtimeState extends State<SignRealtime> {

  late final WebViewController controller;

  // ================= 30 FRAMES =================
  List<List<double>> sequence = [];

  // ================= UI =================
  String prediction = "Scanning...";
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()

      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      // ================= CHANNEL =================
      ..addJavaScriptChannel(
        "SignChannel",

        onMessageReceived: (message) async {

          try {

            // استقبال frame من الـ HTML
            List<dynamic> data =
                jsonDecode(message.message);

            // تحويل لـ double
            List<double> frame =
                data.map((e) => e.toDouble()).toList();

            // لازم 246
            if (frame.length != 246) {
              print("Invalid frame: ${frame.length}");
              return;
            }

            // إضافة frame
            sequence.add(frame);

            print("Frames: ${sequence.length}");

            // ================= SEND 30 FRAMES =================
            if (sequence.length == 30 && !isProcessing) {

              isProcessing = true;

              await sendSequence(sequence);

              sequence.clear();

              isProcessing = false;
            }

          } catch (e) {

            print("Frame Error: $e");
          }
        },
      )

      // ================= LOAD HTML =================
      ..loadFlutterAsset(
        "assets/mediapipe.html",
      );
  }

  // ================= SEND TO AI MODEL =================
  Future<void> sendSequence(
    List<List<double>> frames,
  ) async {

    try {

      final response = await http.post(

        Uri.parse(
          "https://sign-language-api-production-2148.up.railway.app/predict",
        ),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          // ✅ الشكل الصح للمودل
          "sequence": frames,

        }),
      );

      print(response.body);

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        setState(() {

          prediction =
              data["class_name"] ??
              data["prediction"] ??
              "No Result";
        });

      } else {

        setState(() {

          prediction =
              "Server Error ${response.statusCode}";
        });
      }

    } catch (e) {

      setState(() {

        prediction = "Connection Error";
      });

      print(e);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Real-Time Sign"),
      ),

      body: Stack(

        children: [

          // ================= CAMERA =================
          WebViewWidget(
            controller: controller,
          ),

          // ================= RESULT =================
          Positioned(

            bottom: 40,
            left: 20,
            right: 20,

            child: Container(

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.black.withOpacity(0.7),

                borderRadius: BorderRadius.circular(16),
              ),

              child: Text(

                prediction,

                textAlign: TextAlign.center,

                style: const TextStyle(

                  color: Colors.white,

                  fontSize: 28,

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
