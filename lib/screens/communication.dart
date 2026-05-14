import 'dart:io';
import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/screens/sign_realtime.dart';
import 'package:cominsign_new/widgets/sequence_player.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Communication extends StatefulWidget {
  const Communication({super.key});

  @override
  State<Communication> createState() => _CommunicationState();
}

class _CommunicationState extends State<Communication> {

  final TextEditingController textController =
      TextEditingController();

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
      signs = [];
    });

    try {

      final result =
          await Service.textToSigns(
        textController.text,
      );

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

  // ================= SPEECH =================
  void startListening() async {

    bool available =
        await speech.initialize();

    if (available) {

      setState(() => isListening = true);

      speech.listen(

        onResult: (result) {

          setState(() {

            textController.text =
                result.recognizedWords;
          });
        },
      );
    }
  }

  void stopListening() {

    speech.stop();

    setState(() => isListening = false);
  }

  // ================= IMAGE SIGN =================
  Future captureSign() async {

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.camera,
    );

    if (image == null) return;

    setState(() => loading = true);

    final result =
        await Service.signToText(
      File(image.path),
    );

    setState(() {

      predictedText = result;
      loading = false;
    });
  }

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

            // ================= TEXT FIELD =================
            TextField(

              controller: textController,

              decoration: InputDecoration(

                hintText: "Type message",

                border: const OutlineInputBorder(),

                suffixIcon: IconButton(

                  icon: Icon(

                    isListening
                        ? Icons.mic
                        : Icons.mic_none,
                  ),

                  onPressed: () {

                    isListening
                        ? stopListening()
                        : startListening();
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= REALTIME =================
            ElevatedButton(

              onPressed: () async {

                final result =
                    await Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const SignRealtime(),
                  ),
                );

                // ✅ الجملة الراجعة من الكاميرا
                if (result != null) {

                  setState(() {

                    predictedText =
                        result.toString();

                    textController.text =
                        predictedText;
                  });
                }
              },

              child: const Text(
                "Real-Time Sign",
              ),
            ),

            const SizedBox(height: 10),

            // ================= CLEAR =================
            ElevatedButton(

              onPressed: () {

                setState(() {

                  textController.clear();

                  signs = [];

                  predictedText = "";
                });
              },

              child: const Text("Clear"),
            ),

            const SizedBox(height: 10),

            // ================= TEXT TO SIGNS =================
            ElevatedButton(

              onPressed: translateText,

              child: const Text(
                "Text → Signs",
              ),
            ),

            const SizedBox(height: 10),

            // ================= IMAGE TO TEXT =================
            ElevatedButton(

              onPressed: captureSign,

              child: const Text(
                "Sign → Text (Camera)",
              ),
            ),

            const SizedBox(height: 20),

            if (loading)
              const CircularProgressIndicator(),

            const SizedBox(height: 20),

            // ================= RESULT =================
            if (predictedText.isNotEmpty)

              Text(

                predictedText,

                textAlign: TextAlign.center,

                style: const TextStyle(

                  fontSize: 20,

                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 20),

            // ================= VIDEOS =================
            if (signs.isNotEmpty)

              Expanded(

                child: SequencePlayer(
                  videos: signs,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
