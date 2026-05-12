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
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      log(e.toString());
      if (!mounted) return;

      String errorMessage = "Something went wrong. Please try again.";

      if (e is Exception) {
        final raw = e.toString();
        if (raw.contains('"errors"')) {
          errorMessage = "Please check your information and try again.";
        } else if (raw.contains('400')) {
          errorMessage = "Invalid data. Please check your inputs.";
        } else if (raw.contains('network') || raw.contains('connection')) {
          errorMessage = "No internet connection.";
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (mounted) setState(() => isLoading = false);
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

  // ─── TABLET: two-column grid ──────────────────────────────────────────────
  Widget _buildTabletLayout(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sign Up",
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _fieldBlock(
                          "Name",
                          AppTextField(
                            controller: nameController,
                            hint: "Enter your name",
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
                            hint: "Enter your email",
                            keyboardType: TextInputType.emailAddress,
                          ),
                          textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _fieldBlock(
                          "Address",
                          AppTextField(
                            controller: addressController,
                            hint: "Enter your address",
                          ),
                          textColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _fieldBlock(
                          "Password",
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
                              onPressed: () =>
                                  setState(() => showPassword = !showPassword),
                            ),
                          ),
                          textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _fieldBlock(
                          "Confirm Password",
                          AppTextField(
                            controller: confirmPasswordController,
                            hint: "Re-enter password",
                            obscure: !showConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: textColor,
                              ),
                              onPressed: () => setState(() =>
                                  showConfirmPassword = !showConfirmPassword),
                            ),
                          ),
                          textColor,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: _registerButton(),
                  ),
                  const SizedBox(height: 16),
                  _loginLink(textColor),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PHONE ────────────────────────────────────────────────────────────────
  Widget _buildPhoneLayout(Color textColor, Size size) {
    final gap = size.height < 700 ? 12.0 : 18.0;
    final titleSize = size.height < 700 ? 28.0 : 34.0;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sign Up",
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: gap),

            _label("Name", textColor),
            const SizedBox(height: 6),
            AppTextField(controller: nameController, hint: "Enter your name"),
            SizedBox(height: gap),

            _label("Email", textColor),
            const SizedBox(height: 6),
            AppTextField(
              controller: emailController,
              hint: "Enter your email",
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: gap),

            _label("Address", textColor),
            const SizedBox(height: 6),
            AppTextField(
                controller: addressController, hint: "Enter your address"),
            SizedBox(height: gap),

            _label("Password", textColor),
            const SizedBox(height: 6),
            AppTextField(
              controller: passwordController,
              hint: "Enter password",
              obscure: !showPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: textColor,
                ),
                onPressed: () => setState(() => showPassword = !showPassword),
              ),
            ),
            SizedBox(height: gap),

            _label("Confirm Password", textColor),
            const SizedBox(height: 6),
            AppTextField(
              controller: confirmPasswordController,
              hint: "Re-enter password",
              obscure: !showConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  showConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: textColor,
                ),
                onPressed: () => setState(
                    () => showConfirmPassword = !showConfirmPassword),
              ),
            ),
            SizedBox(height: gap * 1.8),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: _registerButton(),
            ),
            SizedBox(height: gap),
            _loginLink(textColor),
            SizedBox(height: gap),
          ],
        ),
      ),
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────

  Widget _fieldBlock(String label, Widget field, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, textColor),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _registerButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _onRegister,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Text(
              "Register",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _loginLink(Color textColor) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: TextStyle(color: textColor),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}