import 'package:flutter/material.dart';
import 'package:cominsign/lib/core/service/api-service.dart';
import 'complete_level.dart';
import '../widgets/gradient_background.dart';

class LevelScreen extends StatefulWidget {
  final int levelId;

  const LevelScreen({Key? key, required this.levelId}) : super(key: key);

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {

  List words = [];
  bool loading = true;
  int coins = 0;

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

    if(word["isLearned"] == true) return;

    final res = await Service.updateProgress(
      word["learningWordId"],
    );

    setState(() {
      word["isLearned"] = true;
      coins = res["coins"];
    });

    final check =
        await Service.checkLevelCompletion(widget.levelId);

    if(check["completed"]){

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

    if(loading){
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final learnedCount =
        words.where((w)=>w["isLearned"]==true).length;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
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

      body: Column(
        children: [

          /// 💰 coins
          Padding(
            padding: const EdgeInsets.only(right:16,top:8),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children:[
                  Image.asset('images/download (8).png',
                      width:40,height:40),
                  Text('$coins',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5F7C),
                      )),
                ],
              ),
            ),
          ),

          /// 🤖 avatar
          SizedBox(
            height: 220,
            child: Image.asset(
              'images/download (9).png',
              height: 220,
            ),
          ),

          const SizedBox(height:6),

          /// progress
          Text(
            'Progress: $learnedCount / ${words.length}',
            style: const TextStyle(
                fontSize:14,color: Color(0xFF2C5F7C)),
          ),

          const SizedBox(height:6),

          Expanded(
            child: GradientBackground(
              child: Column(
                children: [

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: GridView.count(
                        physics:
                        const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 2,

                        children: words.map((w){

                          return PhraseCard(
                            text: w["text"],
                            isLearned: w["isLearned"],
                            onTap: ()=>onWordTap(w),
                          );

                        }).toList(),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
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
      onTap:onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLearned ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:15,
                color: isLearned
                    ? Colors.white
                    : const Color(0xFF2C5F7C),
              )),
        ),
      ),
    );
  }
}
