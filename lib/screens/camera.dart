import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(cameras: cameras),
    );
  }
}

class TopItem {
  final String label;
  final int percentage;
  final Color color;

  TopItem({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;

  List<List<double>> frameBuffer = [];
  bool isSending = false;
  String lastPrediction = "";

  List<TopItem> topItems = [
    TopItem(label: "waiting...", percentage: 0, color: Colors.grey),
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();

    // 🔥 مؤقت للتجربة (استبدله بـ MediaPipe لاحقًا)
    _startFakeFrames();
  }

  // ================= CAMERA INIT =================
  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;

    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    setState(() => _isInitialized = true);
  }

  // ================= FAKE FRAMES =================
  void _startFakeFrames() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));

      List<double> fakeFrame =
          List.generate(246, (i) => (i * 0.001));

      _addFrame(fakeFrame);

      return true;
    });
  }

  // ================= ADD FRAME =================
  void _addFrame(List<double> frame) {
    frameBuffer.add(frame);

    if (frameBuffer.length > 30) {
      frameBuffer.removeAt(0);
    }

    if (frameBuffer.length == 30 && !isSending) {
      isSending = true;

      _sendToModel(frameBuffer).then((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        isSending = false;
      });
    }
  }

  // ================= CLEAN DATA =================
  List<List<double>> _cleanFrames(List<List<double>> frames) {
    return frames.map((frame) {
      return frame.map((e) {
        if (e.isNaN || e.isInfinite) return 0.0;
        return e;
      }).toList();
    }).toList();
  }

  // ================= SEND TO MODEL =================
  Future<void> _sendToModel(List<List<double>> frames) async {
    try {
      final cleanFrames = _cleanFrames(frames);

      final body = jsonEncode({
        "sequence": cleanFrames,
      });

      // 🔥 DEBUG مهم جدًا
      print("========== REQUEST ==========");
      print("Frames: ${cleanFrames.length}");
      print("Frame size: ${cleanFrames[0].length}");
      print(body);
      print("============================");

      final response = await http.post(
        Uri.parse(
          "https://sign-language-api-production-2148.up.railway.app/predict",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String word = data.toString(); // عدّل حسب API الحقيقي

        if (word != lastPrediction) {
          setState(() {
            topItems.insert(
              0,
              TopItem(
                label: word,
                percentage: 90,
                color: Colors.green,
              ),
            );

            lastPrediction = word;
          });
        }
      } else {
        print("❌ API ERROR: ${response.body}");
      }
    } catch (e) {
      print("❌ ERROR: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE8E8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _isInitialized
                      ? CameraPreview(_controller!)
                      : const Center(child: CircularProgressIndicator()),

                  Positioned(
                    right: 10,
                    top: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: topItems.map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.label,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}