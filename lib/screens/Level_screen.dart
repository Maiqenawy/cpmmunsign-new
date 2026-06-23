import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/screens/avatar_screen.dart';
import 'package:flutter/material.dart';
import 'complete_level.dart';
import '../widgets/gradient_background.dart';

import 'package:model_viewer_plus/model_viewer_plus.dart';

class LevelScreen extends StatefulWidget {
  final int levelId;

  const LevelScreen({
    Key? key,
    required this.levelId,
  }) : super(key: key);

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  List words = [];
  bool loading = true;
  int coins = 0;
  List<AvatarSign> selectedSigns = [];
  String currentAnimation = "idle";

  @override
  void initState() {
    super.initState();
    selectedSigns = [];
    loadData();
  }

  Future loadData() async {
    final data = await Service.getWordsWithProgress(widget.levelId);
    setState(() {
      words = data;
      loading = false;
    });
  }

 Future onWordTap(Map word) async {
  try {
    final animation =
        await Service.wordToSign(word["learningWordId"]);

    if (animation != null) {
      setState(() {
        currentAnimation = animation;
      });
    }
  } catch (e) {
    debugPrint("Avatar Error = $e");
  }

  if (word["isLearned"] == true) return;

  final res =
      await Service.updateProgress(word["learningWordId"]);

  setState(() {
    word["isLearned"] = true;
    coins = res["coins"];
  });

  final check =
      await Service.checkLevelCompletion(widget.levelId);

  if (check["completed"]) {
    await Service.unlockNextLevel(widget.levelId);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelCompleteScreen(
          level: widget.levelId,
          coinsEarned: coins,
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xff2A405D);

    if (loading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1A24) : const Color(0xFFF0FAF7),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final learnedCount = words.where((w) => w["isLearned"] == true).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? const Color(0xFF0F1A24) : Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xff2A405D)),
        title: const Text(
          'COMMUNISIGN',
          style: TextStyle(
            color: Colors.white, // أبيض ثابت دائماً ومميز
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // قسم عرض النقود والـ Coins
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('images/download (8).png', width: 28, height: 28),
                        const SizedBox(width: 6),
                        Text(
                          '$coins',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // الأفاتار ثري دي
                SizedBox(
                  height: 250,
                  child: selectedSigns.isNotEmpty
                      ? AvatarScreen(signs: selectedSigns)
                      : const _AvatarWidget(),
                ),
                const SizedBox(height: 15),
                // شريط التقدم بالأرقام
                Text(
                  'Progress: $learnedCount / ${words.length}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 15),
                // شبكة الكلمات المعدلة لخط أوضح تماماً
                Expanded(
                  child: GridView.builder(
                    itemCount: words.length,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2, // زيادة النسبة قليلاً لإعطاء الكلمة مساحة مريحة للعين
                    ),
                    itemBuilder: (context, index) {
                      final w = words[index];
                      return PhraseCard(
                        text: w["text"],
                        isLearned: w["isLearned"],
                        onTap: () => onWordTap(w),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── كود الكرت المحدث بخط واضح عريض وقابل للتكيف مع الـ Dark Mode ──
class PhraseCard extends StatelessWidget {
  final String text;
  final bool isLearned;
  final VoidCallback onTap;

  const PhraseCard({
    super.key,
    required this.text,
    required this.isLearned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تحديد لون الكرت بناءً على حالة الكلمة والثيم الحالي
    Color cardColor;
    if (isLearned) {
      cardColor = isDark ? const Color(0xFF1B5E20) : Colors.green; // أخضر داكن في الدارك مود لراحة العين
    } else {
      cardColor = isDark ? const Color(0xFF263238) : Colors.white; // رمادي غامق للكلمة غير المكتملة في الدارك مود
    }

    // تحديد لون الخط ليكون بأعلى تباين ممكن ليكون واضحاً جداً
    Color textColor;
    if (isLearned) {
      textColor = Colors.white; 
    } else {
      textColor = isDark ? Colors.white : const Color(0xff2A405D);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16, // تكبير حجم الخط ليكون مقروءاً بوضوح
              fontWeight: FontWeight.bold, // جعل الخط سميكاً وبارزاً
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ── كود الأفاتار ثري دي ──
class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: const ModelViewer(
        src: 'assets/avatar.glb',
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
