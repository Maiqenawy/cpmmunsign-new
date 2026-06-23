import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class SignRealtime extends StatefulWidget {
  const SignRealtime({super.key});

  @override
  State<SignRealtime> createState() => _SignRealtimeState();
}

class _SignRealtimeState extends State<SignRealtime> {
  WebViewController? _webViewController;

  final List<List<double>> sequence = [];

  String prediction = "Scanning...";
  List<Map<String, dynamic>> predictions = [];

  bool isProcessing = false;
  bool _initialized = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    initCameraWebView();
  }

  Future<void> initCameraWebView() async {
    if (_initialized) return;
    _initialized = true;

    if (!kIsWeb) {
      await Permission.camera.request();
    }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        "SignChannel",
        onMessageReceived: (JavaScriptMessage message) async {
          if (isProcessing) return;

          try {
            final List data = jsonDecode(message.message);
            final frame = data.map((e) => (e as num).toDouble()).toList();

            if (frame.length != 246) return;

            sequence.add(frame);

            if (sequence.length > 30) {
              sequence.removeAt(0);
            }

            if (sequence.length == 30) {
              isProcessing = true;

              final framesToSend = List<List<double>>.from(sequence);
              sequence.clear();

              await sendSequence(framesToSend);
            }
          } catch (e) {
            debugPrint("Data Error: $e");
          }
        },
      )
      ..loadRequest(Uri.parse(
          "https://maiqenawy.github.io/sign-language-web/mediapipe.html"));

    // 🤖 Android configuration for auto-granting permissions inside the WebView
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final platform = _webViewController!.platform;
      if (platform is AndroidWebViewController) {
        await platform.setMediaPlaybackRequiresUserGesture(false);
        await platform.setOnPlatformPermissionRequest(
          (request) => request.grant(),
        );
      }
    }

    if (mounted) setState(() {});

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  Future<void> sendSequence(List<List<double>> frames) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              "https://sign-language-api-production-2148.up.railway.app/predict",
            ),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "sequence": frames,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {

  final utf8Body =
      utf8.decode(response.bodyBytes);

  final data =
      jsonDecode(utf8Body);

  if (mounted) {
    setState(() {
      predictions =
          List<Map<String, dynamic>>.from(
              data["predictions"] ?? []);

      if (predictions.isNotEmpty) {
        prediction = predictions[0]["label"];
      } else {
        prediction = "Unknown";
      }
    });
  }
}
    } catch (e) {
      debugPrint("API ERROR = $e");
    } finally {
      isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Real-Time Sign"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          // 🌐 WebView Container
          Positioned.fill(
            child: kIsWeb
                ? Container(
                    color: Colors.black87,
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Real-Time Translation is optimized for mobile platforms.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : (_webViewController != null)
                    ? WebViewWidget(
                        key: const ValueKey("stable_webview"),
                        controller: _webViewController!,
                      )
                    : const Center(child: CircularProgressIndicator()),
          ),

          // 🔥 Splash Overlay
          if (_showSplash)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // 📊 UI Overlay for results
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Current Word",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    prediction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (predictions.isNotEmpty)
                    Column(
                      children: [
                        const Text(
                          "Suggestions",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        ...predictions.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    prediction = item["label"];
                                  });
                                },
                                child: Text(
                                  "${item["label"]} (${(item["confidence"] * 100).toStringAsFixed(1)}%)",
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}