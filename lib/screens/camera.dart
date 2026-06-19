import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'sentence_screen.dart';

class SignRealtime extends StatefulWidget {
  const SignRealtime({super.key});

  @override
  State<SignRealtime> createState() => _SignRealtimeState();
}

class _SignRealtimeState extends State<SignRealtime> {
  WebViewController? _webViewController;

  final List<List<double>> sequence = [];
  String prediction = "Scanning...";
  List predictions = [];
  String sentence = "";
 

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

    // 🔐 إذن الكاميرا للهواتف الذكية
    if (!kIsWeb) {
      await Permission.camera.request();
    }

    // 🌐 إعداد الـ WebView والـ JavaScript Channel
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        "SignChannel",
        onMessageReceived: (JavaScriptMessage message) async {
          if (isProcessing) return;

          try {
            final dynamic decoded = jsonDecode(message.message);
            if (decoded is! List) return;

            // تحويل آمن لمنع الكراش في حال وجود قيم null
            final List<double> frame = decoded
                .map((e) => e != null ? (e as num).toDouble() : 0.0)
                .toList();

            if (frame.length == 246) {
              sequence.add(frame);
              
              if (sequence.length > 30) {
                sequence.removeAt(0);
              }

              if (sequence.length == 30 && !isProcessing) {
                isProcessing = true;

                // أخذ نسخة منفصلة تماماً من البيانات لمنع الـ Race Condition
                final framesToSend = List<List<double>>.from(sequence);
                sequence.clear();

                await sendSequence(framesToSend);
              }
            }
          } catch (e) {
            debugPrint("Data Error: $e");
          }
        },
      )
      ..loadRequest(Uri.parse(
          "https://maiqenawy.github.io/sign-language-web/mediapipe.html"));

    // 🤖 إعدادات الأندرويد لطلب إذن الكاميرا داخل الويب بشكل تلقائي
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final platform = _webViewController!.platform;
      if (platform is AndroidWebViewController) {
        await platform.setMediaPlaybackRequiresUserGesture(false);
        await platform.setOnPlatformPermissionRequest(
          (request) => request.grant(),
        );
      }
    }

    if (mounted) {
      setState(() {});
    }

    // ⏳ إخفاء شاشة الـ Splash بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  // ✅ تم إصلاح وهيكلة دالة إرسال الإطارات الـ 30 إلى الـ API وإغلاق الأقواس بشكل سليم
  Future<void> sendSequence(List<List<double>> frames) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              "https://sign-language-api-production-2148.up.railway.app/predict",
            ),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"sequence": frames}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("STATUS = ${response.statusCode}");
      debugPrint("BODY = ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            predictions = data["predictions"] ?? [];
            if (predictions.isNotEmpty) {
              prediction = predictions[0]["word"] ?? "Unknown";
            } else {
              prediction = "Unknown";
            }
          });
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      // ✅ فتح القفل للسماح بإرسال السيكونس التالي بعد انتهاء المعالجة
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
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
          // 🌐 شاشة الويب التي تعرض الكاميرا والـ MediaPipe
          Positioned.fill(
            child: (_webViewController != null)
                ? WebViewWidget(
                    key: const ValueKey("stable_webview"),
                    controller: _webViewController!,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // 🔥 شاشة الـ Splash المؤقتة (تختفي تلقائياً)
          if (_showSplash)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sign_language,
                        color: Colors.deepPurple,
                        size: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Loading AI Camera...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 📊 واجهة عرض الكلمة المكتشفة والاقتراحات
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
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
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
                  if (predictions.isNotEmpty) ...[
                    const Text(
                      "Suggestions",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // تم تحويل الخريطة إلى عناصر Widgets مفرودة بشكل صحيح داخل الـ Column
                    ...predictions.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                prediction = item["word"] ?? "Unknown";
                              });
                            },
                            child: Text(
                              "${item["word"]} (${item["confidence"]}%)",
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  const SizedBox(height: 10),
              ElevatedButton.icon(
  icon: const Icon(Icons.add),
  label: const Text("Add Word"),
  onPressed: () {
    if (prediction != "Unknown" &&
        prediction != "Scanning...") {

      setState(() {
        if (sentence.isEmpty) {
          sentence = prediction;
        } else {
          sentence += " $prediction";
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$prediction added"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  },
),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.article),
                    label: const Text("View Sentence"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SentenceScreen(
                            sentence: sentence,
                            onClear: () {
                              setState(() {
                                sentence = "";
                                lastAddedWord = "";
                              });
                            },
                          ),
                        ),
                      );
                    },
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
