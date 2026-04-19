import 'dart:io';
import 'package:cominsign/lib/core/service/api-service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cominsign/widgets/video_item.dart';


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
    });

    final result =
        await Service.textToSigns(textController.text);

    setState(() {

      signs = result;

      loading = false;

    });

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

                    isListening
                        ? Icons.mic
                        : Icons.mic_none,

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
                    fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 20),

            Expanded(

              child: ListView.builder(

                itemCount: signs.length,

                itemBuilder: (context, index) {

                  return Card(

                    child: ListTile(

                      leading:
                          const Icon(Icons.sign_language),

                      final fullUrl = "https://cominisign.runasp.net${signs[index]}";

return Card(
  child: Padding(
    padding: const EdgeInsets.all(10),
    child: VideoItem(url: fullUrl),
  ),
);
                    ),

                  );

                },

              ),

            )

          ],

        ),

      ),

    );

  }

}
