import 'package:cominsign_new/core/service/api-service.dart';
import 'package:flutter/material.dart';
import 'complete_level.dart';
import '../widgets/gradient_background.dart';
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
      final sign = await Service.wordToSign(word["learningWordId"]);

      debugPrint("WORD = ${sign.word}");
      //debugPrint("FRAMES = ${sign.frames}");
      debugPrint("LANDMARKS = ${sign.landmarks.length}");

      setState(() {
        selectedSigns = [sign];
      });
    } catch (e) {
      debugPrint("Avatar Error = $e");
    }

    String wordText = word["text"].toString().toLowerCase().trim();

    setState(() {
      currentAnimation = wordText;
    });

    if (word["isLearned"] == true) return;

    final res = await Service.updateProgress(word["learningWordId"]);

    setState(() {
      word["isLearned"] = true;
      coins = res["coins"];
    });

    final check = await Service.checkLevelCompletion(widget.levelId);

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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final learnedCount =
        words.where((w) => w["isLearned"] == true).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('COMMUNISIGN'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    Image.asset('images/download (8).png', width: 40),
                    Text('$coins'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: AvatarScreen(signs: selectedSigns),
              ),

              Text('Progress: $learnedCount / ${words.length}'),

              Expanded(
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
            ],
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
          color: isLearned ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }
}
