import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:cominsign_new/screens/home.dart';
import 'package:cominsign_new/screens/login_screen.dart';
import 'package:cominsign_new/widgets/app_text_field.dart';
import '../widgets/gradient_background.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(email.trim());
  }

  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await Service.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        address: addressController.text.trim(),
      );

      UserSession.isGuest = false;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registered successfully"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      log(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 700;

    final horizontalPadding = isTablet ? width * 0.18 : 24.0;
    final titleSize = isTablet ? 42.0 : 34.0;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 520,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 35),

                      _label("Name", textColor),
                      const SizedBox(height: 8),

                      AppTextField(
                        controller: nameController,
                        hint: "Enter your name",
                      ),

                      const SizedBox(height: 20),

                      _label("Email", textColor),
                      const SizedBox(height: 8),

                      AppTextField(
                        controller: emailController,
                        hint: "Enter your email",
                        keyboardType:
                            TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      _label("Address", textColor),
                      const SizedBox(height: 8),

                      AppTextField(
                        controller: addressController,
                        hint: "Enter your address",
                      ),

                      const SizedBox(height: 20),

                      _label("Password", textColor),
                      const SizedBox(height: 8),

                      AppTextField(
                        controller: passwordController,
                        hint: "Enter password",
                        obscure: !showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: textColor,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword =
                                  !showPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      _label(
                        "Confirm Password",
                        textColor,
                      ),
                      const SizedBox(height: 8),

                      AppTextField(
                        controller:
                            confirmPasswordController,
                        hint: "Re-enter password",
                        obscure: !showConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: textColor,
                          ),
                          onPressed: () {
                            setState(() {
                              showConfirmPassword =
                                  !showConfirmPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : _onRegister,
                          style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green,
                                shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            14,
                                          ),
                                    ),
                              ),
                          child:
                              isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                          strokeWidth:
                                              2.5,
                                          color:
                                              Colors
                                                  .white,
                                        ),
                                  )
                                  : const Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          Colors
                                              .white,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: Wrap(
                          alignment:
                              WrapAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color:
                                      Colors.green,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
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

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}