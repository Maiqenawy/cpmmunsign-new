import 'package:cominsign/lib/core/service/api-service.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {

  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  void resetPassword() async {

    if (passwordController.text != confirmController.text) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );

      return;
    }

    try {

      await Service.resetPassword(
        email: widget.email,
        token: widget.token,
        newPassword: passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset failed")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Reset Password"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(

          children: [

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: resetPassword,
              child: const Text("Reset Password"),
            )

          ],
        ),
      ),
    );
  }
}
