import 'package:cominsign_new/core/app_lang.dart';
import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:cominsign_new/screens/forget_pass.dart';
import 'package:cominsign_new/screens/home.dart';
import 'package:cominsign_new/screens/signUp.dart';
import 'package:cominsign_new/widgets/app_text_field.dart';
import 'package:cominsign_new/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;

  const LoginScreen({super.key, this.isDarkMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _login() async {
    if (isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final data = await Service.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print("🔥 LOGIN RESPONSE: $data");

      if (data == null) {
        throw Exception("Empty response from server");
      }

      final token = data["token"] ?? data["accessToken"];
      final email = data["email"] ?? _emailController.text.trim();

      if (token == null) {
        throw Exception("Token not found in response");
      }

      await UserSession.saveSession(
        tokenValue: token,
        emailValue: email,
      );

      UserSession.isGuest = false;

      String? fcmToken =
          await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        await Service.updateDeviceToken(fcmToken);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      print("❌ LOGIN ERROR: $e");

      _showSnack("Login failed: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 40 : 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : double.infinity,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      const SizedBox(height: 60),

                      const Center(
                        child: Text(
                          "COMMUNISIGN",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      /// EMAIL
                      Text("Email",
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      AppTextField(
                        controller: _emailController,
                        hint: "Enter email",
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      /// PASSWORD
                      Text("Password",
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      AppTextField(
                        controller: _passwordController,
                        hint: "••••••••",
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// LOGIN BUTTON
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// FORGOT PASSWORD
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgetPass(),
                            ),
                          );
                        },
                        child: Text("Forgot Password",
                            style: TextStyle(color: textColor)),
                      ),

                      /// SIGN UP
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}