import 'dart:io';
import 'package:cominsign_new/screens/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/avatar_sign_model.dart';
import 'package:cominsign_new/widgets/avatar_animation_player.dart';
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

        child: AvatarAnimationPlayer(
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
class _AvatarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 420,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(bottom: 0, child: SizedBox(width: 240, height: 260, child: CustomPaint(painter: _BodyPainter()))),
          Positioned(top: 0, child: SizedBox(width: 200, height: 220, child: CustomPaint(painter: _HeadPainter()))),
          Positioned(top: 130, right: 10, child: SizedBox(width: 90, height: 120, child: CustomPaint(painter: _HandPainter()))),
        ],
      ),
    );
  }
}

// [باقي كلاسات الـ Painters الـ ثلاثة: _HeadPainter, _BodyPainter, _HandPainter يتم وضعها هنا دون تغيير في كود الـ paint الخاص بها ليعمل الرسم بشكل سليم]
class _HeadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skin = const Color(0xFFF5C9A0);
    final darkSkin = const Color(0xFFE8A87C);
    final hair = const Color(0xFF1A0A00);
    final white = Colors.white;
    final pupil = const Color(0xFF1A1A2E);
    final lipColor = const Color(0xFFE07070);
    final teethColor = Colors.white;
    final earringColor = const Color(0xFFFFD700);
    final paint = Paint()..isAntiAlias = true;
    final cx = size.width / 2;

    final hairPath = Path();
    hairPath.moveTo(cx - 72, 60);
    hairPath.cubicTo(cx - 90, 100, cx - 85, 180, cx - 60, 220);
    hairPath.cubicTo(cx - 40, 215, cx - 20, 210, cx - 10, 205);
    hairPath.cubicTo(cx - 5, 190, cx - 15, 160, cx - 30, 120);
    hairPath.cubicTo(cx - 55, 90, cx - 65, 70, cx - 72, 60);
    canvas.drawPath(hairPath, paint);

    final hairPathR = Path();
    hairPathR.moveTo(cx + 72, 60);
    hairPathR.cubicTo(cx + 88, 100, cx + 82, 175, cx + 55, 215);
    hairPathR.cubicTo(cx + 35, 212, cx + 15, 208, cx + 8, 204);
    hairPathR.cubicTo(cx + 3, 188, cx + 12, 158, cx + 28, 118);
    hairPathR.cubicTo(cx + 52, 88, cx + 63, 68, cx + 72, 60);
    canvas.drawPath(hairPathR, paint);

    canvas.drawOval(Rect.fromCenter(center: Offset(cx, 95), width: 140, height: 155), paint);

    paint.color = skin;
    final neckRect = RRect.fromRectAndRadius(Rect.fromLTWH(cx - 20, 160, 40, 50), const Radius.circular(8));
    canvas.drawRRect(neckRect, paint);

    paint.color = darkSkin;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 69, 100), width: 16, height: 22), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 69, 100), width: 16, height: 22), paint);

    paint.color = earringColor;
    canvas.drawCircle(Offset(cx + 69, 108), 5, paint);
    canvas.drawCircle(Offset(cx - 69, 108), 5, paint);

    paint.color = hair;
    final topHair = Path();
    topHair.moveTo(cx - 70, 95);
    topHair.cubicTo(cx - 72, 30, cx - 20, 5, cx, 8);
    topHair.cubicTo(cx + 20, 5, cx + 72, 30, cx + 70, 95);
    topHair.cubicTo(cx + 50, 55, cx, 35, cx - 50, 55);
    topHair.close();
    canvas.drawPath(topHair, paint);

    paint.strokeWidth = 3.5;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    final leftBrow = Path();
    leftBrow.moveTo(cx - 52, 72);
    leftBrow.quadraticBezierTo(cx - 35, 65, cx - 18, 70);
    canvas.drawPath(leftBrow, paint);

    final rightBrow = Path();
    rightBrow.moveTo(cx + 18, 70);
    rightBrow.quadraticBezierTo(cx + 35, 65, cx + 52, 72);
    canvas.drawPath(rightBrow, paint);

    paint.style = PaintingStyle.fill;
    paint.color = white;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 32, 93), width: 36, height: 26), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 32, 93), width: 36, height: 26), paint);

    paint.color = pupil;
    canvas.drawCircle(Offset(cx - 30, 95), 9, paint);
    canvas.drawCircle(Offset(cx + 30, 95), 9, paint);

    paint.color = const Color(0xFF111111);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(Offset(cx - 32 + i * 7.0, 80), Offset(cx - 32 + i * 7.0 - 1, 74), paint);
      canvas.drawLine(Offset(cx + 32 + i * 7.0, 80), Offset(cx + 32 + i * 7.0 + 1, 74), paint);
    }
    
    paint.style = PaintingStyle.fill;
    paint.color = darkSkin;
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    final nosePath = Path();
    nosePath.moveTo(cx, 110);
    nosePath.cubicTo(cx - 6, 120, cx - 12, 126, cx - 8, 130);
    nosePath.cubicTo(cx - 4, 133, cx + 4, 133, cx + 8, 130);
    nosePath.cubicTo(cx + 12, 126, cx + 6, 120, cx, 110);
    canvas.drawPath(nosePath, paint);
    
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF6B2020);
    final mouthPath = Path();
    mouthPath.moveTo(cx - 28, 142);
    mouthPath.quadraticBezierTo(cx, 165, cx + 28, 142);
    mouthPath.quadraticBezierTo(cx + 20, 155, cx, 158);
    mouthPath.quadraticBezierTo(cx - 20, 155, cx - 28, 142);
    mouthPath.close();
    canvas.drawPath(mouthPath, paint);

    paint.color = white;
    final teethPath = Path();
    teethPath.moveTo(cx - 22, 145);
    teethPath.quadraticBezierTo(cx, 150, cx + 22, 145);
    teethPath.quadraticBezierTo(cx + 18, 152, cx, 153);
    teethPath.quadraticBezierTo(cx - 18, 152, cx - 22, 145);
    teethPath.close();
    canvas.drawPath(teethPath, paint);

    paint.color = lipColor;
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;
    final lowerLip = Path();
    lowerLip.moveTo(cx - 28, 145);
    lowerLip.quadraticBezierTo(cx, 170, cx + 28, 145);
    canvas.drawPath(lowerLip, paint);
    
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFFFB5A0).withOpacity(0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 52, 115), width: 28, height: 16), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 52, 115), width: 28, height: 16), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skin = const Color(0xFFF5C9A0);
    final white = Colors.white;
    final jeans = const Color(0xFF3B5268);
    final darkJeans = const Color(0xFF2A3D4F);
    final paint = Paint()..isAntiAlias = true;
    final cx = size.width / 2;

    paint.color = white;
    final torsoPath = Path();
    torsoPath.moveTo(cx - 70, 0);
    torsoPath.cubicTo(cx - 75, 60, cx - 65, 100, cx - 60, 110);
    torsoPath.lineTo(cx + 60, 110);
    torsoPath.cubicTo(cx + 65, 100, cx + 75, 60, cx + 70, 0);
    torsoPath.quadraticBezierTo(cx, 10, cx - 70, 0);
    canvas.drawPath(torsoPath, paint);

    paint.color = skin;
    final leftArm = Path();
    leftArm.moveTo(cx - 68, 10);
    leftArm.cubicTo(cx - 95, 50, cx - 100, 100, cx - 80, 140);
    leftArm.cubicTo(cx - 75, 145, cx - 65, 145, cx - 62, 140);
    leftArm.cubicTo(cx - 80, 100, cx - 78, 55, cx - 58, 15);
    leftArm.close();
    canvas.drawPath(leftArm, paint);

    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 76, 146), width: 28, height: 22), paint);

    paint.color = white;
    canvas.drawRect(Rect.fromLTWH(cx - 60, 0, 120, 112), paint);

    paint.color = const Color(0xFFEEEEEE);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    final neckLine = Path();
    neckLine.moveTo(cx - 30, 2);
    neckLine.quadraticBezierTo(cx, 20, cx + 30, 2);
    canvas.drawPath(neckLine, paint);
    
    paint.style = PaintingStyle.fill;
    paint.color = jeans;
    final jeansPath = Path();
    jeansPath.moveTo(cx - 62, 108);
    jeansPath.lineTo(cx + 62, 108);
    jeansPath.lineTo(cx + 65, 260);
    jeansPath.lineTo(cx + 10, 260);
    jeansPath.lineTo(cx, 180);
    jeansPath.lineTo(cx - 10, 260);
    jeansPath.lineTo(cx - 65, 260);
    jeansPath.close();
    canvas.drawPath(jeansPath, paint);

    paint.color = darkJeans;
    canvas.drawRect(Rect.fromLTWH(cx - 62, 108, 124, 14), paint);

    for (double x in [cx - 42, cx - 10, cx + 10, cx + 42]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, 104, 7, 16), const Radius.circular(2)), paint);
    }

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 50, 130), Offset(cx - 30, 130), paint);
    canvas.drawLine(Offset(cx - 50, 130), Offset(cx - 48, 155), paint);
    canvas.drawLine(Offset(cx - 30, 130), Offset(cx - 32, 155), paint);
    canvas.drawLine(Offset(cx + 50, 130), Offset(cx + 30, 130), paint);
    canvas.drawLine(Offset(cx + 50, 130), Offset(cx + 48, 155), paint);
    canvas.drawLine(Offset(cx + 30, 130), Offset(cx + 32, 155), paint);
    canvas.drawLine(Offset(cx, 125), Offset(cx, 180), paint);
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(_) => false;
}

class _HandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skin = const Color(0xFFF5C9A0);
    final paint = Paint()..color = skin..isAntiAlias = true;

    final palmPath = Path();
    palmPath.moveTo(30, 70);
    palmPath.cubicTo(10, 65, 5, 40, 20, 30);
    palmPath.cubicTo(25, 10, 45, 15, 50, 30);
    palmPath.cubicTo(55, 15, 70, 12, 72, 30);
    palmPath.cubicTo(78, 18, 88, 22, 85, 38);
    palmPath.cubicTo(90, 45, 85, 60, 75, 65);
    palmPath.cubicTo(65, 80, 40, 80, 30, 70);
    canvas.drawPath(palmPath, paint);

    final thumbPath = Path();
    thumbPath.moveTo(25, 55);
    thumbPath.cubicTo(10, 55, 5, 75, 18, 82);
    thumbPath.cubicTo(25, 88, 38, 82, 38, 70);
    canvas.drawPath(thumbPath, paint);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(18, 5, 18, 40), const Radius.circular(9)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(38, 2, 18, 42), const Radius.circular(9)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(58, 5, 16, 38), const Radius.circular(8)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(76, 14, 14, 28), const Radius.circular(7)), paint);

    paint.color = const Color(0xFFE8A87C);
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    for (double x in [27.0, 47.0, 66.0]) {
      canvas.drawLine(Offset(x, 36), Offset(x, 44), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
