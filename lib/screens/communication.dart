import 'dart:io';
import 'package:cominsign_new/screens/avatar_landmark_player.dart';
import 'package:cominsign_new/screens/avatar_sign_model.dart';
import 'package:cominsign_new/screens/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// model_viewer_plus removed — AvatarScreen (WebView) handles all states
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cominsign_new/screens/avatar_screen.dart';

// تأكدي من صحة المسارات ومطابقتها لمشروعك
import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/widgets/sequence_player.dart';

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
      themeMode: ThemeMode.system, // يتبع ثيم الجهاز تلقائياً
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
  final TextEditingController textController = TextEditingController();
  final SpeechToText speech = SpeechToText();
  final ImagePicker picker = ImagePicker();

  bool isListening = false;
  bool loading = false;
  List<AvatarSign> signs = [];
  String predictedText = "";

  // ================= TEXT TO SIGN =================
  // ================= TEXT TO SIGN =================
  void translateText() async {
    if (textController.text.isEmpty) return;

    setState(() {
      loading = true;
      signs = [];
    });

    try {
      final result = await Service.textToSigns(textController.text);
      debugPrint("====== TEST SERVER ======");
      debugPrint("SIGNS COUNT = ${result.length}");

      if (result.isEmpty) {
        debugPrint(
          "🚨 السيرفر رجع لستة فاضية! الكلمة مش موجودة عنده أو الـ API فيه مشكلة",
        );
      }

      for (var s in result) {
        debugPrint("Word: ${s.word}");
        debugPrint("Frames count: ${s.landmarks.length}");
        if (s.landmarks.isNotEmpty) {
          debugPrint("First Frame Landmarks: ${s.landmarks.first}");
        } else {
          debugPrint("🚨 الكلمة رجعت بس من غير فريمات حركة (فاضية)!");
        }
      }
      debugPrint("=========================");

      setState(() {
        signs = result;
        loading = false;
      });
    } catch (e) {
      debugPrint("🚨 ERROR IN API CALL: $e");
      setState(() => loading = false);
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
  Future captureSign() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() => loading = true);
    final result = await Service.signToText(File(image.path));

    setState(() {
      predictedText = result;
      textController.text = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. معرفة حالة الـ Dark Mode وتحديد الألوان ديناميكياً
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1A3C6E);
    final iconColor = isDark
        ? const Color(0xFF4DB6AC)
        : const Color(0xFF1B6B55);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF14222D), // خلفية داكنة علوية
                    const Color(0xFF0F1A24), // خلفية داكنة سفلية
                  ]
                : [
                    const Color(0xFFEBF8F4), // مِنت فاتح
                    const Color(0xFFB2E8DC), // تيل فاتح
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: iconColor,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                        icon: Icon(Icons.refresh, color: iconColor),
                        onPressed: () {
                          setState(() {
                            textController.clear();
                            signs = [];
                            predictedText = "";
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── Avatar (always alive — plays idle / thinking / signs) ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    children: [
                      // The WebView avatar — never removed from tree
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AvatarScreen(
                          signs: signs,
                          isLoading: loading,
                        ),
                      ),

                      // Semi-transparent overlay while waiting for API
                      // Avatar keeps playing "thinking" animation underneath
                      if (loading)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.black.withOpacity(0.38),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                  SizedBox(height: 14),
                                  Text(
                                    'Translating to sign language...',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            
              // ── زرار الـ Real-Time الإضافي فوق الـ Bottom Bar مباشرة ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF00796B)
                        : const Color(0xFF1B6B55),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.videocam),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignRealtime()),
                    );

                    if (result != null) {
                      setState(() {
                        predictedText = result.toString();
                        textController.text = predictedText;
                      });
                    }
                  },
                  label: const Text(
                    "Start Real-Time Tracking",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // ── Bottom Bar الذكي والمطور ──
              Container(
                margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2E3D)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // حقل إدخال النص المدمج في الـ Bar
                    Expanded(
                      child: TextField(
                        controller: textController,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A3C6E),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type to translate...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => translateText(),
                      ),
                    ),

                    // زرار تحويل النص إلى إشارة (Text → Signs)
                    IconButton(
                      icon: Icon(Icons.send, color: iconColor),
                      onPressed: translateText,
                    ),
                    const SizedBox(width: 4),

                    // زرار التقاط صورة ثابتة للإشارة (Sign → Text Camera)
                    GestureDetector(
                      onTap: captureSign,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A3B4C)
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF555555),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // زرار المايك الصوتي (Speech to Text)
                    GestureDetector(
                      onTap: () {
                        isListening ? stopListening() : startListening();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isListening
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE8344A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// _AvatarWidget removed — AvatarScreen now handles all visual states
// (idle breathing, thinking pose while loading, and sign animation)
