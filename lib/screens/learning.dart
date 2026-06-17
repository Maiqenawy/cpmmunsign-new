import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'Level_screen.dart';

class Learning extends StatefulWidget {
  const Learning({super.key});

  @override
  State<Learning> createState() => _LearningState();
}

class _LearningState extends State<Learning> {
  List<Map<String, dynamic>> levels = [];
  List<Map<String, dynamic>> userLevels = [];

  bool loading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();

    if (!UserSession.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginWarning();
      });

      setState(() {
        loading = false;
      });

      return;
    }

    loadData();
  }

  void _showLoginWarning() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Required"),
        content: const Text(
          "You are using the app as a guest.\nSome features may be limited.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> loadData() async {
    try {
      final l = await Service.getLevels();
      final u = await Service.getUserLevels();

      if (!mounted) return;

      setState(() {
        levels = List<Map<String, dynamic>>.from(l);
        userLevels = List<Map<String, dynamic>>.from(u);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = "Failed to load data";
      });
    }
  }

  bool isLocked(int levelId) {
    return !userLevels.any(
      (u) => u["levelId"] == levelId && (u["isUnlocked"] == true),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            errorMessage,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF1E3A5F),
              displayColor: const Color(0xFF1E3A5F),
            ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true, 
        // 🛠️ تم احتواء الشاشة كاملة داخل ويدجت الخلفية الثابتة الخاصة بكِ
        body: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                // شريط علوي يحتوي على السهم والعنوان ليطابق الصورة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A5F), size: 26),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "COMMUNISIGN",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A5F),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // لموازنة السهم والحفاظ على السنترة
                    ],
                  ),
                ),

                // قائمة المحتوى القابل للتمرير
                Expanded(
                  child: levels.isEmpty
                      ? const Center(
                          child: Text(
                            "No Levels Found",
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            
                            // 📍 هنا الصورة التي تظهر فوق الكروت
                            Center(
                              child: Image.asset(
                                'images/download (7).png', 
                                height: 260, 
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 220,
                                    margin: const EdgeInsets.symmetric(vertical: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "ضع ملف الصورة هنا في الكود\n(images/download (7).png)",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 20), // مسافة بين الصورة وأول كارت

                            // عرض كروت المستويات مجلوبة من الـ API
                            ...levels.map((level) {
                              final int levelId = level["levelId"] ?? 0;
                              final bool locked = isLocked(levelId);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: LevelCard(
                                  levelName: level["name"] ?? "Level",
                                  coins: level["requiredCoins"] ?? 0,
                                  isLocked: locked,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LevelScreen(
                                          levelId: levelId,
                                        ),
                                      ),
                                    ).then((_) => loadData());
                                  },
                                ),
                              );
                            }),

                            const SizedBox(height: 30),
                          ],
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

///////////////////////////////////////////////////////
/// LEVEL CARD
///////////////////////////////////////////////////////

class LevelCard extends StatelessWidget {
  final String levelName;
  final int coins;
  final bool isLocked;
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.levelName,
    required this.coins,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLocked
                ? [Colors.grey.shade400, Colors.grey.shade600]
                : const [
                    Color(0xFF8CE3D2), 
                    Color(0xFF43656F), 
                  ],
          ),
          borderRadius: BorderRadius.circular(24), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              levelName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32, 
                fontWeight: FontWeight.bold,
              ),
            ),
            
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLocked)
                  const Icon(Icons.lock, color: Colors.white, size: 36)
                else ...[
                  const Icon(
                    Icons.monetization_on, 
                    color: Color(0xFFFFD700), 
                    size: 38,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$coins",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
