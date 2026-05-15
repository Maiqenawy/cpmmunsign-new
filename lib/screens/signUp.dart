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
      final response = await Service.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        address: addressController.text.trim(),
      );

      UserSession.isGuest = false;

      if (response is Map && response['token'] != null) {
        UserSession.token = response['token'];
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registered successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      log("REGISTER ERROR: $e");

      if (!mounted) return;

      final errorMessage = e
          .toString()
          .replaceAll("Exception:", "")
          .trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GradientBackground(
        child: SafeArea(
          child: isTablet
              ? _buildTabletLayout(textColor)
              : _buildPhoneLayout(textColor, size),
        ),
      ),
    );
  }

  // ================= TABLET =================

  Widget _buildTabletLayout(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 48,
        vertical: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _fieldBlock(
                          "Name",
                          AppTextField(
                            controller: nameController,
                            hint: "Name",
                            validator: (String? v) {
                              if (v == null ||
                                  v.trim().isEmpty) {
                                return "Required";
                              }
                              return null;
                            },
                          ),
                          textColor,
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: _fieldBlock(
                          "Email",
                          AppTextField(
                            controller: emailController,
                            hint: "Email",
                            validator: (String? v) {
                              if (!_isValidEmail(v ?? "")) {
                                return "Invalid email";
                              }
                              return null;
                            },
                          ),
                          textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _fieldBlock(
                    "Address",
                    AppTextField(
                      controller: addressController,
                      hint: "Address",
                      validator: (String? v) {
                        if (v == null ||
                            v.trim().isEmpty) {
                          return "Required";
                        }
                        return null;
                      },
                    ),
                    textColor,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _fieldBlock(
                          "Password",
                          _passwordField(
                            passwordController,
                            showPassword,
                            () {
                              setState(() {
                                showPassword =
                                    !showPassword;
                              });
                            },
                            textColor,
                          ),
                          textColor,
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: _fieldBlock(
                          "Confirm",
                          _passwordField(
                            confirmPasswordController,
                            showConfirmPassword,
                            () {
                              setState(() {
                                showConfirmPassword =
                                    !showConfirmPassword;
                              });
                            },
                            textColor,
                            isConfirm: true,
                          ),
                          textColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  _registerButton(),

                  const SizedBox(height: 16),

                  _loginLink(textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PHONE =================

  Widget _buildPhoneLayout(
    Color textColor,
    Size size,
  ) {
    final gap = size.height < 700 ? 12.0 : 18.0;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            SizedBox(height: gap),

            _fieldBlock(
              "Name",
              AppTextField(
                controller: nameController,
                hint: "Enter your name",
                validator: (String? v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              textColor,
            ),

            SizedBox(height: gap),

            _fieldBlock(
              "Email",
              AppTextField(
                controller: emailController,
                hint: "Enter email",
                validator: (String? v) {
                  if (!_isValidEmail(v ?? "")) {
                    return "Invalid email";
                  }
                  return null;
                },
              ),
              textColor,
            ),

            SizedBox(height: gap),

            _fieldBlock(
              "Address",
              AppTextField(
                controller: addressController,
                hint: "Enter address",
                validator: (String? v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Address is required";
                  }
                  return null;
                },
              ),
              textColor,
            ),

            SizedBox(height: gap),

            _fieldBlock(
              "Password",
              _passwordField(
                passwordController,
                showPassword,
                () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
                textColor,
              ),
              textColor,
            ),

            SizedBox(height: gap),

            _fieldBlock(
              "Confirm Password",
              _passwordField(
                confirmPasswordController,
                showConfirmPassword,
                () {
                  setState(() {
                    showConfirmPassword =
                        !showConfirmPassword;
                  });
                },
                textColor,
                isConfirm: true,
              ),
              textColor,
            ),

            SizedBox(height: gap * 2),

            _registerButton(),

            const SizedBox(height: 16),

            _loginLink(textColor),
          ],
        ),
      ),
    );
  }

  // ================= FIELD BLOCK =================

  Widget _fieldBlock(
    String label,
    Widget field,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        field,
      ],
    );
  }

  // ================= PASSWORD FIELD =================

  Widget _passwordField(
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggle,
    Color textColor, {
    bool isConfirm = false,
  }) {
    return AppTextField(
      controller: ctrl,
      hint: "******",
      obscure: !obscure,
      validator: (String? v) {
        if ((v?.length ?? 0) < 6) {
          return "Min 6 characters";
        }

        if (isConfirm &&
            v != passwordController.text.trim()) {
          return "Passwords don't match";
        }

        return null;
      },
      suffixIcon: IconButton(
        icon: Icon(
          obscure
              ? Icons.visibility
              : Icons.visibility_off,
          color: textColor,
        ),
        onPressed: toggle,
      ),
    );
  }

  // ================= REGISTER BUTTON =================

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Register",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // ================= LOGIN LINK =================

  Widget _loginLink(Color textColor) {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        },
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: textColor),
            children: const [
              TextSpan(
                text: "Already have an account? ",
              ),
              TextSpan(
                text: "Login",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}