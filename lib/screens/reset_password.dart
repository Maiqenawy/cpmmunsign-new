import 'package:flutter/material.dart';
import 'package:cominsign/lib/core/service/api-service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;

  void resetPassword() async {
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await Service.resetPassword(
        email: widget.email,
        code: codeController.text,
        newPassword: passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid code or failed")),
      );
    }

    setState(() => isLoading = false);
  }

  // 🔥 RESEND CODE
  void resendCode() async {
    try {
      await Service.forgotPassword(widget.email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code resent")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to resend")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [

            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: "Enter Code"),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: resendCode,
              child: const Text("Resend Code"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),

            const SizedBox(height: 40),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: resetPassword,
                    child: const Text("Reset Password"),
                  ),
          ],
        ),
      ),
    );
  }
}ر
