import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class SignRealtime extends StatefulWidget {
  const SignRealtime({super.key});

  @override
  State<SignRealtime> createState() =>
      _SignRealtimeState();
}

class _SignRealtimeState
    extends State<SignRealtime> {

  late final WebViewController controller;

  // ================= 30 FRAMES =================
  List<List<double>> sequence = [];

  // ================= SENTENCE =================
  List<String> sentenceWords = [];

  String lastWord = "";

  // ================= UI =================
  String prediction = "Scanning...";

  bool isProcessing = false;

  @override
  void initState() {

    super.initState();

    controller = WebViewController()

      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )

      // ================= CHANNEL =================
      ..addJavaScriptChannel(

        "SignChannel",

        onMessageReceived: (message) async {

          try {

            List<dynamic> data =
                jsonDecode(message.message);

            List<double> frame =
                data.map((e) =>
                    e.toDouble()).toList();

            // لازم 246
            if (frame.length != 246) {

              print(
                "Invalid frame: ${frame.length}",
              );

              return;
            }

            // إضافة frame
            sequence.add(frame);

            print(
              "Frames: ${sequence.length}",
            );

            // ================= SEND =================
            if (sequence.length == 30 &&
                !isProcessing) {

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

      // ================= HTML =================
      ..loadFlutterAsset(
        "assets/mediapipe.html",
      );
  }

  // ================= SEND TO MODEL =================
  Future<void> sendSequence(
    List<List<double>> frames,
  ) async {

    try {

      final response = await http.post(

        Uri.parse(
          "https://sign-language-api-production-2148.up.railway.app/predict",
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "sequence": frames,
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        // ================= BEST WORD =================
        String bestWord =
            data["prediction"];

        // ================= AVOID REPEAT =================
        if (bestWord != lastWord) {

          sentenceWords.add(bestWord);

          lastWord = bestWord;
        }

        setState(() {

          prediction =

              "Prediction: ${data["prediction"]}\n\n"

              "${data["top3"][0]["word"]} "
              "(${(data["top3"][0]["conf"] * 100).toStringAsFixed(1)}%)\n"

              "${data["top3"][1]["word"]} "
              "(${(data["top3"][1]["conf"] * 100).toStringAsFixed(1)}%)\n"

              "${data["top3"][2]["word"]} "
              "(${(data["top3"][2]["conf"] * 100).toStringAsFixed(1)}%)";
        });

      } else {

        setState(() {

          prediction =
              "Server Error ${response.statusCode}";
        });
      }

    } catch (e) {

      setState(() {

        prediction =
            "Connection Error";
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

        title: const Text(
          "Real-Time Sign",
        ),

        actions: [

          // ================= DONE =================
          IconButton(

            onPressed: () {

              Navigator.pop(

                context,

                sentenceWords.join(" "),
              );
            },

            icon: const Icon(Icons.done),
          ),
        ],
      ),

      body: Stack(

        children: [

          // ================= CAMERA =================
          WebViewWidget(
            controller: controller,
          ),

          // ================= RESULTS =================
          Positioned(

            bottom: 30,

            left: 20,

            right: 20,

            child: Column(

              children: [

                // ================= CURRENT =================
                Container(

                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(

                    color: Colors.black
                        .withOpacity(0.7),

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: Text(

                    prediction,

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(

                      color: Colors.white,

                      fontSize: 22,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ================= FULL SENTENCE =================
                Container(

                  padding:
                      const EdgeInsets.all(14),

                  decoration: BoxDecoration(

                    color: Colors.green
                        .withOpacity(0.8),

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: Text(

                    sentenceWords.join(" "),

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(

                      color: Colors.white,

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
