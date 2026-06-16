import 'package:cominsign_new/core/service/api-service.dart';
import 'package:flutter/material.dart';
import 'complete_level.dart';
import '../widgets/gradient_background.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'avatar_screen.dart';
import 'avatar_sign_model.dart';

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

  // ⭐ الأنيميشن الحالي
  String currentAnimation = "idle";

  @override
  void initState() {
    super.initState();
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

    final sign =
        await Service.wordToSign(
          word["learningWordId"],
        );
      debugPrint(
  "WORD = ${sign.word}",
);

//debugPrint(
 // "FRAMES = ${sign.frames}",
//);

debugPrint(
  "LANDMARKS = ${sign.landmarks.length}",
);

    setState(() {

      selectedSigns = [sign];

    });

  } catch (e) {

    debugPrint(
      "Avatar Error = $e",
    );

  }

    print("الكلمة التي تم الضغط عليها هي: ${word["text"]}");

    // ✅ اسم الأنيميشن
    String wordText = word["text"]
        .toString()
        .toLowerCase()
        .trim();

    // ✅ تغيير الحركة
    setState(() {
      currentAnimation = wordText;
    });

    // ✅ إذا كانت الكلمة متعلمة بالفعل
    if (word["isLearned"] == true) return;

    // ✅ تحديث التقدم
    final res =
        await Service.updateProgress(word["learningWordId"]);

    setState(() {
      word["isLearned"] = true;
      coins = res["coins"];
    });

    // ✅ فحص إنهاء المستوى
    final check =
        await Service.checkLevelCompletion(widget.levelId);

    if (check["completed"]) {
      await Service.unlockNextLevel(widget.levelId);

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
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final learnedCount =
        words.where((w) => w["isLearned"] == true).length;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF2C5F7C),
              displayColor: const Color(0xFF2C5F7C),
            ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'COMMUNISIGN',
            style: TextStyle(
              color: Color(0xFF2C5F7C),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// 💰 Coins
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/download (8).png',
                          width: 40,
                          height: 40,
                        ),

                        Text(
                          '$coins',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C5F7C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 🤖 3D Avatar
               SizedBox(
  height: 250,
  child: AvatarScreen(
    signs: selectedSigns,
  ),
),

                const SizedBox(height: 8),

                /// 📊 Progress
                Text(
                  'Progress: $learnedCount / ${words.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C5F7C),
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔳 الكلمات
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      itemCount: words.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: isLearned
              ? Colors.green
              : Colors.white,

          borderRadius: BorderRadius.circular(12),
        ),

        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 15,

              color: isLearned
                  ? Colors.white
                  : const Color(0xFF2C5F7C),
            ),
          ),
        ),
      ),
    );
  }
}
