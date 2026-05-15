import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // مهم جداً عشان kIsWeb
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
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    initCameraWebView();
  }

  Future<void> initCameraWebView() async {
    // 1. طلب صلاحية الكاميرا للموبايل فقط (الويب بيطلبها لوحده)
    if (!kIsWeb) {
      await Permission.camera.request();
    }

    // 2. إعداد الكنترولر الأساسي
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        "SignChannel",
        onMessageReceived: (JavaScriptMessage message) {
          if (isProcessing) return;
          try {
            final List data = jsonDecode(message.message);
            final frame = data.map((e) => (e as num).toDouble()).toList();
            
            if (frame.length == 246) {
              sequence.add(frame);
              if (sequence.length >= 30) {
                isProcessing = true;
                final framesToSend = List<List<double>>.from(sequence);
                sequence.clear();
                sendSequence(framesToSend);
              }
            }
          } catch (e) {
            debugPrint("Data Error: $e");
          }
        },
      )
      ..loadRequest(Uri.parse("https://maiqenawy.github.io/sign-language-web/mediapipe.html"));

    // 3. الجزء الحرج: إعدادات الأندرويد (لا يتم تنفيذها إلا على الأندرويد فقط)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (controller.platform is AndroidWebViewController) {
        final androidController = controller.platform as AndroidWebViewController;
        await androidController.setMediaPlaybackRequiresUserGesture(false);
        await androidController.setOnPlatformPermissionRequest((request) => request.grant());
      }
    }

    setState(() {
      _webViewController = controller;
    });
  }

  Future<void> sendSequence(List<List<double>> frames) async {
    try {
      final response = await http.post(
        Uri.parse("https://sign-language-api-production-2148.up.railway.app/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"sequence": frames}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            prediction = data["prediction"] ?? "Unknown";
          });
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
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
          _webViewController == null
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: _webViewController!),
          
          // طبقة لعرض النتيجة
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
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}