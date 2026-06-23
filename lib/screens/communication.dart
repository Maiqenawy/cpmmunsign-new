import 'dart:io';
import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/screens/camera.dart';
import 'package:cominsign_new/widgets/avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cominsign_new/core/avatar/avatar_controller.dart';
import 'avatar_screen.dart';

void main() {
  runApp(const CommuniSignApp());
}

class CommuniSignApp extends StatelessWidget {
  const CommuniSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommuniSign',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0FAF7),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1A24),
      ),
      themeMode: ThemeMode.system,
      home: const Communication(),
    );
  }
}

class Communication extends StatefulWidget {
  const Communication({super.key});

  @override
  State<Communication> createState() => _CommunicationState();
}

class _CommunicationState extends State<Communication> {
  final AvatarController avatarController = AvatarController();
  final TextEditingController textController = TextEditingController();
  final SpeechToText speech = SpeechToText();
  final ImagePicker picker = ImagePicker();

  bool isListening = false;
  bool loading = false;
String currentAnimation = "Idle.glb";
  String predictedText = "";

  // ================= TEXT TO SIGN (تم إصلاحها هنا) =================
  Future<void> translateText() async {
    if (textController.text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      // الـ API يعيد الآن List<String> مباشرة بأسماء الـ animations
      final List<String> animations = await Service.textToSigns(textController.text);

      debugPrint("SIGNS COUNT = ${animations.length}");
      for (var animationName in animations) {
        debugPrint("Animation Name: $animationName");
      }

      setState(() {
        loading = false;
      });

      // 🔥 تشغيل الأفاتار مباشرة باستخدام القائمة القادمة
    for (final animation in animations) {

  setState(() {
    currentAnimation = animation;
  });

  await Future.delayed(
    const Duration(seconds: 4),
  );
}

setState(() {
  currentAnimation = "Idle.glb";
});
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() {
        loading = false;
      });
    }
  }

  // ================= SPEECH =================
  void startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);

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
    setState(() => isListening = false);
  }

  // ================= IMAGE SIGN =================
  Future<void> captureSign() async {
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() => loading = true);

    try {
      final result = await Service.signToText(File(image.path));

      setState(() {
        predictedText = result;
        textController.text = result;
        loading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor =
        isDark ? Colors.white : const Color(0xFF1A3C6E);

    final iconColor =
        isDark ? const Color(0xFF4DB6AC) : const Color(0xFF1B6B55);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF14222D),
                    const Color(0xFF0F1A24)
                  ]
                : [
                    const Color(0xFFEBF8F4),
                    const Color(0xFFB2E8DC)
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              // ── App Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: iconColor, size: 20),
                        onPressed: () =>
                            Navigator.pop(context),
                      ),
                    ),

                    Text(
                      'COMMUNISIGN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                        letterSpacing: 1.5,
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.refresh,
                            color: iconColor),
                        onPressed: () {
                          setState(() {
                            textController.clear();
                            predictedText = "";
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── Avatar Area ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2E3D)
                          : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [

                        // 🔥 WebView Avatar
                      AvatarScreen(
  animation: currentAnimation,
),

                        // Loading overlay
                        if (loading)
                          Positioned.fill(
                            child: Container(
                              color:
                                  Colors.black.withOpacity(0.4),
                              child: const Center(
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Real-time Button ──
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF00796B)
                        : const Color(0xFF1B6B55),
                    foregroundColor: Colors.white,
                    minimumSize:
                        const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.videocam),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SignRealtime(),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        predictedText =
                            result.toString();
                        textController.text =
                            predictedText;
                      });
                    }
                  },
                  label: const Text(
                    "Start Real-Time Tracking",
                    style: TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // ── Bottom Bar ──
              Container(
                margin: const EdgeInsets.only(
                    bottom: 12, left: 12, right: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2E3D)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'Type to translate...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) =>
                            translateText(),
                      ),
                    ),

                    IconButton(
                      icon: Icon(Icons.send,
                          color: iconColor),
                      onPressed: translateText,
                    ),

                    GestureDetector(
                      onTap: captureSign,
                      child: const Icon(
                        Icons.camera_alt_outlined,
                      ),
                    ),

                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: () {
                        isListening
                            ? stopListening()
                            : startListening();
                      },
                      child: Icon(
                        isListening
                            ? Icons.mic
                            : Icons.mic_none,
                        color: isListening
                            ? Colors.green
                            : Colors.red,
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
