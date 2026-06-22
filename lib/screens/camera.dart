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
  List predictions = [];

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

    // 🔐 Permission
    if (!kIsWeb) {
      await Permission.camera.request();
    }

    // 🌐 WebView setup
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        "SignChannel",
        onMessageReceived: (JavaScriptMessage message) async {
          debugPrint("MESSAGE RECEIVED");
          debugPrint(
    "MESSAGE FROM JS = ${message.message}"
  );
          if (isProcessing) return;

          try {
            final List data = jsonDecode(message.message);
            final frame =
                data.map((e) => (e as num).toDouble()).toList();
          
debugPrint(
  "FRAME SIZE = ${frame.length}"
);

if (frame.length == 246) {

  debugPrint(
    "FRAME ACCEPTED"
    
  );
final nonZero =
    frame.where((e) => e != 0).length;

debugPrint(
  "NON ZERO VALUES = $nonZero"
);
  sequence.add(frame);
  debugPrint(
  "FRAME ADDED AT ${DateTime.now()}"
);
debugPrint(
  "SEQUENCE SIZE = ${sequence.length}"
);
  if (sequence.length > 30) {
    sequence.removeAt(0);
  }

  if (sequence.length == 30) {

    debugPrint(
      "30 FRAMES READY"
    );
     debugPrint("CALLING API...");

    isProcessing = true;

    final framesToSend =
        List<List<double>>.from(sequence);

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

    // 🤖 Android specific
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
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

    // ⏳ Splash delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }
Future<void> sendSequence(
  List<List<double>> frames,
) async {

  try {

    debugPrint(
      "SENDING ${frames.length} FRAMES"
    );

    final response = await http
        .post(
          Uri.parse(
            "https://sign-language-api-production-2148.up.railway.app/predict",
          ),
          headers: {
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "sequence": frames,
          }),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    debugPrint(
      "STATUS = ${response.statusCode}"
    );

    debugPrint(
      "BODY = ${response.body}"
    );

    if (response.statusCode == 200) {

  final data =
      jsonDecode(response.body);

  if (mounted) {

   setState(() {

  predictions = data["predictions"] ?? [];

  if (predictions.isNotEmpty) {
   prediction = predictions[0]["label"];
  } else {
    prediction = "Unknown";
  }

});
  }
}
  } catch (e) {

    debugPrint(
      "API ERROR = $e"
    );

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

          // 🌐 WebView (stable)
          Positioned.fill(
            child: (_webViewController != null)
                ? WebViewWidget(
                    key: const ValueKey("stable_webview"),
                    controller: _webViewController!,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // 🔥 Splash overlay (does NOT destroy WebView)
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

          // 📊 Prediction UI
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

    Text(
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

    if (predictions.isNotEmpty)
      Column(
        children: [
          const Text(
            "Suggestions",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
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
                      prediction = item["word"];
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
      ),
  ],
)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
