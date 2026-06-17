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
    // 1. معرفة هل التطبيق في الـ Dark Mode حالياً أم لا
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 2. تحديد لون الخطوط بناءً على الثيم
    final dynamicTextColor = isDark ? Colors.white : const Color(0xFF1E3A5F);

    if (loading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        body: Center(
          child: Text(
            errorMessage,
            style: TextStyle(fontSize: 18, color: dynamicTextColor),
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        // إجبار الأيقونات والنصوص تتبع الثيم الحالي
        iconTheme: IconThemeData(color: dynamicTextColor),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: dynamicTextColor,
              displayColor: dynamicTextColor,
            ),
      ),
      child: Scaffold(
        // 3. تغيير لون خلفية الـ Scaffold نفسه ليدعم الدارك مود بالكامل
        backgroundColor: isDark ? const Color(0xFF0F1A24) : Colors.transparent,
        extendBodyBehindAppBar: true, 
        // إذا كان دارك مود هنشيل الـ Gradient ونحط خلفية داكنة مريحة للعين، وفي اللايت مود يفضل الـ Gradient القديم
        body: GradientBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                final screenWidth = constraints.maxWidth;

                final imageAssetHeight = (screenHeight * 0.32).clamp(160.0, 260.0);

                return Column(
                  children: [
                    // شريط علوي متجاوب يحتوي على السهم والعنوان
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04, 
                        vertical: screenHeight * 0.015,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new, 
                              color: dynamicTextColor,
                              size: (screenHeight * 0.032).clamp(22.0, 28.0),
                            ),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                          Expanded(
                            child: Text(
                              "COMMUNISIGN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (screenHeight * 0.035).clamp(20.0, 26.0),
                                fontWeight: FontWeight.bold,
                                color: dynamicTextColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(width: (screenHeight * 0.055).clamp(40.0, 52.0)), 
                        ],
                      ),
                    ),

                    // قائمة المحتوى القابل للتمرير المتجاوبة
                    Expanded(
                      child: levels.isEmpty
                          ? Center(
                              child: Text(
                                "No Levels Found",
                                style: TextStyle(fontSize: 20, color: dynamicTextColor),
                              ),
                            )
                          : ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                              children: [
                                
                                // 📍 الصورة العلوية
                                Center(
                                  child: Image.asset(
                                    'images/download (7).png', 
                                    height: imageAssetHeight, 
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: imageAssetHeight * 0.85,
                                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white10 : Colors.black12,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "ضع ملف الصورة هنا في الكود\n(images/download (7).png)",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isDark ? Colors.white60 : Colors.grey[600], 
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                
                                SizedBox(height: screenHeight * 0.025), 

                                // عرض كروت المستويات
                                ...levels.map((level) {
                                  final int levelId = level["levelId"] ?? 0;
                                  final bool locked = isLocked(levelId);

                                  return Padding(
                                    padding: EdgeInsets.only(bottom: screenHeight * 0.025),
                                    child: LevelCard(
                                      levelName: level["name"] ?? "Level",
                                      coins: level["requiredCoins"] ?? 0,
                                      isLocked: locked,
                                      screenHeight: screenHeight,
                                      screenWidth: screenWidth,
                                      isDark: isDark, // تمرير الـ Dark mode هنا للكارد
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

                                SizedBox(height: screenHeight * 0.04),
                              ],
                            ),
                    ),
                  ],
                );
              },
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
  final double screenHeight;
  final double screenWidth;
  final bool isDark; 
  final VoidCallback onTap;

  const LevelCard({
    super.key,
    required this.levelName,
    required this.coins,
    required this.isLocked,
    required this.screenHeight,
    required this.screenWidth,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06, 
          vertical: screenHeight * 0.028,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // تعديل ألوان كروت الـ Unlocked والـ Locked لتناسب الـ Dark Mode
            colors: isLocked
                ? [
                    isDark ? Colors.grey.shade800 : Colors.grey.shade400,
                    isDark ? Colors.grey.shade900 : Colors.grey.shade600,
                  ]
                : [
                    const Color(0xFF8CE3D2), 
                    isDark ? const Color(0xFF2C3E50) : const Color(0xFF43656F), 
                  ],
          ),
          borderRadius: BorderRadius.circular(24), 
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                levelName,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            SizedBox(width: screenWidth * 0.02),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLocked)
                  const Icon(
                    Icons.lock, 
                    color: Colors.white70, 
                    size: 30,
                  )
                else ...[
                  const Icon(
                    Icons.monetization_on, 
                    color: Color(0xFFFFD700), 
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$coins",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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