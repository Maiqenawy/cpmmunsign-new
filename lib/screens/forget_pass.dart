import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/screens/reset_password.dart';
import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({super.key});

  @override
  State<ForgetPass> createState() => ForgetPassState();
}

class ForgetPassState extends State<ForgetPass> {
  final TextEditingController _emailController = TextEditingController();

  bool isLoading = false;

  // ================= Send Email Function =================
  void _sendEmail() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ إرسال الكود
      await Service.forgotPassword(email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Code sent to your email"),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ نروح لصفحة الريسيت
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email, token: ''),
        ),
      );
    } catch (e) {
      print("FORGOT PASSWORD ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
    setState(() => isLoading = false);
  }

  // ================= Email Validation =================
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // معرفة حالة الـ Dark Mode وتحديد الألوان ديناميكياً
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xff2A405D);

    // 🟢 تخصيص لون العنوان: أبيض في الدارك وأزرق غامق مريح في اللايت
    final titleColor = isDark ? Colors.white : const Color(0xFF1A3C6E);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? const Color(0xFF0F1A24) : Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xff2A405D),
        ),
      ),

      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),

                // العنوان الرئيسي المتفاعل مع نوع الثيم
                Text(
                  'COMMUNISIGN',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),

                SizedBox(height: screenHeight * 0.18),

                Text(
                  'Password Recovery',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                Text(
                  'Enter your email',
                  style: TextStyle(fontSize: 20, color: primaryTextColor),
                ),

                SizedBox(height: screenHeight * 0.02),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E2E3D)
                        : const Color.fromARGB(255, 255, 251, 251),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                isLoading
                    ? CircularProgressIndicator(
                        color: isDark ? const Color(0xFF2ABC4E) : null,
                      )
                    : SizedBox(
                        width: screenWidth * 0.45,
                        child: GestureDetector(
                          onTap: _sendEmail,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2ABC4E),
                                  Color(0xFF135624),
                                  Color(0xFF135624),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Send',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
