// ملاحظة: لازم زميلك يكون ضايف مكتبات camera و http و google_mlkit_hand_detection
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class SequenceCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SequenceCameraScreen({super.key, required this.cameras});

  @override
  State<SequenceCameraScreen> createState() => _SequenceCameraScreenState();
}

class _SequenceCameraScreenState extends State<SequenceCameraScreen> {
  CameraController? _controller;
  List<List<double>> _sequence = []; // دي اللي هنجمع فيها الـ 30 فريم
  String _prediction = "Scanning...";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();

    // بدأ معالجة الصور من الكاميرا لايف
    _controller!.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _processFrame(image);
      }
    });
    setState(() {});
  }

  void _processFrame(CameraImage image) async {
    // 1. هنا زميلك بيحول الصورة لـ Landmarks (أرقام)
    // هنفترض إن النقط المستخرجة من الفريم الواحد اسمها currentLandmarks
    List<double> currentLandmarks = await _extractLandmarks(image);

    _sequence.add(currentLandmarks);

    // 2. لما نوصل لـ 30 فريم، نبعتهم للسيرفر
    if (_sequence.length == 30) {
      _isProcessing = true;
      await _sendSequenceToServer(_sequence);
      _sequence.clear(); // نمسح السيكونس عشان نجمع 30 جداد
      _isProcessing = false;
    }
  }

  Future<void> _sendSequenceToServer(List<List<double>> sequence) async {
    try {
      var url = Uri.parse(
        "https://sign-language-api-production-2148.up.railway.app/predict/",
      );

      // إرسال الداتا كـ JSON بنفس الشكل اللي السيرفر طالبه في الصورة
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sequence": sequence, // دي المصفوفة الـ 30 فريم
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _prediction = data['class_name'];
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // دالة وهمية لاستخراج النقط (زميلك أكيد عارف يكتبها بمكتبة ML Kit)
  Future<List<double>> _extractLandmarks(CameraImage image) async {
    // زميلك هيكتب هنا كود تحويل الفريم لـ 246 نقطة أو حسب الموديل بتاعك
    return List.generate(246, (index) => 0.0);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized)
      return Container();
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Language Sequence")),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller!)),
          Text(
            "Prediction: $_prediction",
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
