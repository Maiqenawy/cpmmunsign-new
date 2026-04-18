import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'package:cominsign/lib/core/service/api-service.dart';
import 'package:cominsign/lib/core/user_session.dart';
import 'login_screen.dart';
import 'Level_screen.dart';


class Learning extends StatefulWidget {
  const Learning({super.key});

  @override
  State<Learning> createState() => _LearningState();
}

class _LearningState extends State<Learning> {
  List levels = [];
  List userLevels = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    // ✅ CHECK LOGIN
    if (!UserSession.isLoggedIn) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return;
    }

    loadData();
  }

  Future loadData() async {
    final l = await Service.getLevels();
    final u = await Service.getUserLevels();

    setState(() {
      levels = l;
      userLevels = u;
      loading = false;
    });
  }

  bool isLocked(int levelId) {
    return !userLevels.any(
      (u) => u["levelId"] == levelId && u["isUnlocked"],
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  'COMMUNISIGN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: levels.map((level) {

                      final locked = isLocked(level["levelId"]);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LevelCard(
                          levelName: level["name"],
                          coins: level["requiredCoins"],
                          isLocked: locked,
                          gradientColors: const [
                            Color(0xFF80CBC4),
                            Color(0xFF4DB6AC),
                          ],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LevelScreen(
                                  levelId: level["levelId"],
                                ),
                              ),
                            ).then((_) => loadData());
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////
/// ⭐ LEVEL CARD (FIXED - NO ERROR)
///////////////////////////////////////////////////////

class LevelCard extends StatelessWidget {
  final String levelName;
  final int coins;
  final bool isLocked;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.levelName,
    required this.coins,
    required this.isLocked,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLocked
                ? [Colors.grey, Colors.grey]
                : gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              levelName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Row(
              children: [
                if (isLocked)
                  const Icon(Icons.lock, color: Colors.white)
                else ...[
                  const Icon(Icons.monetization_on,
                      color: Colors.yellow),
                  const SizedBox(width: 5),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}