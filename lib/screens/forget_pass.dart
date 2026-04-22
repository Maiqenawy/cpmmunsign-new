
         import 'package:cominsign/lib/core/service/api-service.dart';
import 'package:cominsign/screens/reset_password.dart';
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send code"),
          backgroundColor: Colors.red,
        ),
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

    return Scaffold(
      appBar: AppBar(),

      body: GradientBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const Text(
                'COMMUNISIGN',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),

              SizedBox(height: screenHeight * 0.25),

              const Text(
                'Password Recovery',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2A405D),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              const Text(
                'Enter your email',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xff2A405D),
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 251, 251),
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

              SizedBox(height: screenHeight * 0.03),

              isLoading
                  ? const CircularProgressIndicator()
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
                                Color(0xFF135624)
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
    );
  }
}
