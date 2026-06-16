import 'dart:io';
import 'package:cominsign_new/screens/avatar_landmark_player.dart';
import 'package:cominsign_new/screens/avatar_sign_model.dart';
import 'package:cominsign_new/screens/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
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
        scaffoldBackgroundColor: const Color(0xFFF0FAF7),
      ),
      home: const Communication(), // تم توجيه البداية لشاشة الـ Communication
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
  void translateText() async {
    if (textController.text.isEmpty) return;

    setState(() {
      loading = true;
      signs = [];
    });

    try {
      final result = await Service.textToSigns(textController.text);
      setState(() {
        signs = result;
        loading = false;
      });
    } catch (e) {
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
      textController.text = result; // عرض النتيجة داخل حقل النص أيضاً لتظهر للمستخدم
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBF8F4), // light mint top
              Color(0xFFB2E8DC), // teal bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B6B55), size: 20),
                        onPressed: () {
                          // إغلاق الشاشة أو تصفير الداتا عند العودة
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Text(
                      'COMMUNISIGN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A3C6E),
                        letterSpacing: 1.5,
                      ),
                    ),
                    // زرار صغير لتنظيف الشاشة (Clear) في الـ App Bar من فوق كشكل أنظف للواجهة
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFF1B6B55)),
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

              // ── الأركان الحيوية (الأفاتار أو مشغل الفيديوهات والـ Loading) ──
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: loading
                        ? const CircularProgressIndicator(color: Color(0xFF1B6B55))
                      : (signs.isNotEmpty
    ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,

        child:AvatarScreen(
  signs: signs,

        ),
      )
    : _AvatarWidget()),// يعرض الأفاتار إن لم تكن هناك فيديوهات إشارة شغالّلة
                  ),
                ),
              ),

              // ── زرار الـ Real-Time الإضافي فوق الـ Bottom Bar مباشرة ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B55),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                  label: const Text("Start Real-Time Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),

              // ── Bottom Bar الذكي والمطور ──
              Container(
                margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // حقل إدخال النص المدمج في الـ Bar
                    Expanded(
                      child: TextField(
                        controller: textController,
                        style: const TextStyle(color: Color(0xFF1A3C6E), fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Type to translate...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => translateText(), // يترجم فوراً عند الضغط على Enter في الكيبورد
                      ),
                    ),
                    
                    // زرار تحويل النص إلى إشارة (Text → Signs)
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF1B6B55)),
                      onPressed: translateText,
                    ),
                    const SizedBox(width: 4),

                    // زرار التقاط صورة ثابتة للإشارة (Sign → Text Camera)
                    GestureDetector(
                      onTap: captureSign,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF555555), size: 20),
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
                          color: isListening ? const Color(0xFF4CAF50) : const Color(0xFFE8344A),
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

// ── كود الـ Custom Painters (الأفاتار) يظل ثابت كما هو تماماً ──
// 🟢 ضيف الكود ده في آخر الملف 🟢
class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 420,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: const ModelViewer(
        src: 'assets/avatar.glb', // تأكد إن ده مسار المجسم بتاعك
        alt: 'CommuniSign 3D Avatar',
        autoRotate: false, 
        cameraControls: false, 
        disableZoom: true, 
        shadowIntensity: 1,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
