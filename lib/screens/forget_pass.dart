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

    // مؤقت لحين ربط API
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          email: email,
          token: "123456",
        ),
      ),
    );

    try {
      await Service.forgotPassword(email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reset link sent to your email"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send email"),
          backgroundColor: Colors.red,
        ),
      );
    }
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

              /// COMMUNISIGN
              Container(
                width: screenWidth * 0.6,
                height: screenHeight * 0.05,
                alignment: Alignment.center,
                child: const Text(
                  'COMMUNISIGN',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.25),

              /// Password Recovery
              Container(
                width: screenWidth * 0.75,
                height: screenHeight * 0.06,
                alignment: Alignment.center,
                child: const Text(
                  'Password Recovery',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2A405D),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              /// Description
              const Text(
                'Enter your email',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xff2A405D),
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              /// Email Field
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

              /// Send Button
              SizedBox(
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
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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