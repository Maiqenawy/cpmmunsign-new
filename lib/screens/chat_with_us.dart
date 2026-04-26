import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cominsign/widgets/gradient_background.dart';
import 'package:cominsign/lib/core/service/api-service.dart';

// 🎤 Voice
import 'package:speech_to_text/speech_to_text.dart' as stt;

// 📷 Camera OCR
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ChatWithUs extends StatefulWidget {
  const ChatWithUs({super.key});

  @override
  State<ChatWithUs> createState() => _ChatWithUsState();
}

class _ChatWithUsState extends State<ChatWithUs> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, String>> messages = [];

  bool isLoading = false;

  // 🎤 Voice
  late stt.SpeechToText _speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // ================= SEND =================
  void sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      isLoading = true;
    });

    controller.clear();

    try {
      String reply = await Service.chat(text);

      setState(() {
        messages.add({"sender": "bot", "text": reply});
      });
    } catch (e) {
      setState(() {
        messages.add({
          "sender": "bot",
          "text": "Something went wrong"
        });
      });
    }

    setState(() => isLoading = false);
  }

  // ================= VOICE =================
  void startListening() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() => isListening = true);

      _speech.listen(onResult: (result) {
        setState(() {
          controller.text = result.recognizedWords;
        });
      });
    }
  }

  void stopListening() {
    _speech.stop();
    setState(() => isListening = false);
  }

  // ================= CAMERA OCR =================
  Future<void> pickImageAndReadText() async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer();

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    controller.text = recognizedText.text;

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [

              // 🔥 Header
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: cs.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'COMMUNISIGN',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                ],
              ),

              // 💬 Messages
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];

                    return Align(
                      alignment: msg["sender"] == "user"
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg["sender"] == "user"
                              ? Colors.green
                              : cs.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg["text"]!),
                      ),
                    );
                  },
                ),
              ),

              if (isLoading) const CircularProgressIndicator(),

              // ✍️ Input
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Ask anything...',
                          filled: true,
                          fillColor: cs.surface,
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.camera_alt_outlined,
                                color: cs.onSurface),
                            onPressed: pickImageAndReadText,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 🎤 Voice
                    IconButton(
                      icon: Icon(
                        isListening
                            ? Icons.mic
                            : Icons.mic_none,
                        color: cs.primary,
                      ),
                      onPressed: () {
                        isListening
                            ? stopListening()
                            : startListening();
                      },
                    ),

                    // ➤ Send
                    IconButton(
                      icon: Icon(Icons.send, color: cs.primary),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
