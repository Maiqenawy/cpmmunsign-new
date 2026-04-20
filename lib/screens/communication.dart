import 'dart:io';
import 'package:cominsign/lib/core/service/api-service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cominsign/widgets/sequence_player.dart';

class Communication extends StatefulWidget {
  const Communication({super.key});

  @override
  State<Communication> createState() => _CommunicationState();
}

class _CommunicationState extends State<Communication> {

  final TextEditingController textController = TextEditingController();
  final SpeechToText speech = SpeechToText();
  final ImagePicker picker = ImagePicker();

  bool isListening = false;
  bool loading = false;

  List<String> signs = [];
  String predictedText = "";

  // ================= TEXT TO SIGN =================
  void translateText() async {

    if (textController.text.isEmpty) return;

    setState(() {
      loading = true;
      signs = []; // 🔥 reset قبل التحميل
    });

    try {
      final result = await Service.textToSigns(textController.text);

      setState(() {
        signs = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  // ================= SPEECH TO TEXT =================
  void startListening() async {

    bool available = await speech.initialize();

    if (available) {
      setState(() {
        isListening = true;
      });

      speech.listen(
        onResult: (result) {
          setState(() {
            textController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void stopListening() {
    speech.stop();

    setState(() {
      isListening = false;
    });
  }

  // ================= CAMERA SIGN TO TEXT =================
  Future captureSign() async {

    final XFile? image =
        await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() {
      loading = true;
    });

    final result =
        await Service.signToText(File(image.path));

    setState(() {
      predictedText = result;
      loading = false;
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Communication"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // TEXT INPUT
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: "Type message",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                  ),
                  onPressed: () {
                    if (isListening) {
                      stopListening();
                    } else {
                      startListening();
                    }
                  },
                ),
              ),
            ),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignRealtime(),
      ),
    );
  },
  child: const Text("Real-Time Sign"),
),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: translateText,
              child: const Text("Text → Signs"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: captureSign,
              child: const Text("Sign → Text (Camera)"),
            ),

            const SizedBox(height: 20),

            if (loading)
              const CircularProgressIndicator(),

            const SizedBox(height: 20),

            if (predictedText.isNotEmpty)
              Text(
                "AI Result: $predictedText",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),

            const SizedBox(height: 20),

            // 🔥 هنا بقى الفيديوهات sequential
            if (signs.isNotEmpty)
              Expanded(
                child: SequencePlayer(videos: signs),
              ),

          ],
        ),
      ),
    );
  }
}
