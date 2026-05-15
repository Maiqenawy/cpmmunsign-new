import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/widgets/gradient_background.dart';

class ChatWithUs extends StatefulWidget {
  const ChatWithUs({super.key});

  @override
  State<ChatWithUs> createState() => _ChatWithUsState();
}

class _ChatWithUsState extends State<ChatWithUs> {
  final TextEditingController controller = TextEditingController();

  final ScrollController scrollController = ScrollController();

  List<Map<String, String>> messages = [];

  bool isLoading = false;

  // 🎤 Voice
  late stt.SpeechToText speech;

  bool isListening = false;

  @override
  void initState() {
    super.initState();

    // 🎤 تهيئة الـ Speech
    speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    speech.stop();
    super.dispose();
  }

  // ================= AUTO SCROLL =================
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ================= SEND =================
  Future<void> sendMessage() async {
    String text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "sender": "user",
        "text": text,
      });

      isLoading = true;
    });

    controller.clear();

    scrollToBottom();

    try {
      String reply = await Service.chat(text);

      setState(() {
        messages.add({
          "sender": "bot",
          "text": reply,
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          "sender": "bot",
          "text": "Something went wrong",
        });
      });
    }

    setState(() {
      isLoading = false;
    });

    scrollToBottom();
  }

  // ================= VOICE =================
  Future<void> startListening() async {
    bool available = await speech.initialize();

    if (!available) return;

    setState(() {
      isListening = true;
    });

    speech.listen(
      onResult: (result) {
        setState(() {
          controller.text = result.recognizedWords;

          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        });
      },
    );
  }

  void stopListening() {
    speech.stop();

    setState(() {
      isListening = false;
    });
  }

  // ================= CAMERA OCR =================
  Future<void> pickImageAndReadText() async {
    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
      );

      if (image == null) return;

      final inputImage = InputImage.fromFilePath(image.path);

      final textRecognizer = TextRecognizer();

      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      controller.text = recognizedText.text;

      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );

      await textRecognizer.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to read text from image"),
        ),
      );
    }
  }

  // ================= MESSAGE ITEM =================
  Widget buildMessage(Map<String, String> msg) {
    bool isUser = msg["sender"] == "user";

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),

        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: isUser
              ? Colors.green
              : Theme.of(context).colorScheme.surface,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                Radius.circular(isUser ? 18 : 0),
            bottomRight:
                Radius.circular(isUser ? 0 : 18),
          ),
        ),

        child: Text(
          msg["text"] ?? "",

          style: TextStyle(
            color: isUser
                ? Colors.white
                : Theme.of(context)
                    .colorScheme
                    .onSurface,

            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ================= HEADER =================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),

                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: cs.primary,
                      ),

                      onPressed: () {
                        Navigator.pop(context);
                      },
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

                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // ================= CHAT =================
              Expanded(
                child: ListView.builder(
                  controller: scrollController,

                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),

                  itemCount: messages.length,

                  itemBuilder: (_, i) {
                    return buildMessage(messages[i]);
                  },
                ),
              ),

              // ================= LOADING =================
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: CircularProgressIndicator(),
                ),

              // ================= INPUT =================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  18,
                ),

                child: Row(
                  children: [
                    // ================= TEXT FIELD =================
                    Expanded(
                      child: TextField(
                        controller: controller,

                        minLines: 1,
                        maxLines: 5,

                        decoration: InputDecoration(
                          hintText: 'Ask anything...',

                          filled: true,
                          fillColor: cs.surface,

                          contentPadding:
                              const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(30),

                            borderSide: BorderSide.none,
                          ),

                          // 📷 OCR
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              color: cs.onSurface,
                            ),

                            onPressed: pickImageAndReadText,
                          ),
                        ),

                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // ================= MIC =================
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: cs.surface,

                      child: IconButton(
                        icon: Icon(
                          isListening
                              ? Icons.mic
                              : Icons.mic_none,

                          color: isListening
                              ? Colors.red
                              : cs.primary,
                        ),

                        onPressed: () {
                          isListening
                              ? stopListening()
                              : startListening();
                        },
                      ),
                    ),

                    const SizedBox(width: 6),

                    // ================= SEND =================
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: cs.primary,

                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),

                        onPressed: sendMessage,
                      ),
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