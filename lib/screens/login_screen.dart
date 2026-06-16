import 'package:cominsign_new/core/service/api-service.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:flutter/material.dart';
import 'package:cominsign_new/screens/forget_pass.dart';
import 'package:cominsign_new/screens/home.dart';
import 'package:cominsign_new/screens/signUp.dart';
import 'package:cominsign_new/widgets/gradient_background.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;

  const LoginScreen({
    super.key,
    this.isDarkMode = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool isLoading = false;
  
  // متغيرات للتحكم في رسالة التحذير الخاصة بالـ Guest
  bool _showWarning = false;
  bool _isAgreed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // يتم استدعاؤها بعد الموافقة والضغط على Next
  Future<void> _navigateToHomeAsGuest() async {
    UserSession.isGuest = true;

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
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

      if (data == null) {
        _showSnack("Server error");
        return;
      }

      final token = data["token"] ?? data["accessToken"];
      final email = data["email"] ?? _emailController.text.trim();

      if (token == null) {
        _showSnack(data["message"] ?? "Login failed");
        return;
      }

      await UserSession.saveSession(
        tokenValue: token,
        emailValue: email,
      );

      UserSession.isGuest = false;

      if (!context.mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      _showSnack("Login failed: $e");
    } finally {
      if (context.mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    return Scaffold(
      // إضافة AppBar شفاف ليحتوي على زر الرجوع والـ Guest بشكل نظيف ومطابق للصورة
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            if (_showWarning) {
              setState(() => _showWarning = false);
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showWarning = true; // إظهار الكارد عند الضغط على Guest
                });
              },
              child: const Text(
                'Guest',
                style: TextStyle(
                  color: Color(0xFF34A853), // لون أخضر مطابق للصورة
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 40 : 24,
                vertical: 10,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : double.infinity,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // في حال الضغط على Guest يظهر كارد التحذير، وإلا يظهر العنوان العادي
                      if (_showWarning) _buildWarningCard() else _buildTitle(),

                      const SizedBox(height: 35),

                      // ================= EMAIL =================
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: const Color(0xFFFFF5F5), // لون خلفية مائل للوردي الخفيف جداً حسب الصورة
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Email is required";
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ================= PASSWORD =================
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: const Color(0xFFFFF5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Password is required";
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // ================= FORGOT PASSWORD =================
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgetPass()),
                            );
                          },
                          child: const Text(
                            "Forgot Password ?",
                            style: TextStyle(color: Colors.black54, fontSize: 15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= LOGIN BUTTON (أو زر مخفي لو التحذير ظاهر عشان يطابق الصورة) =================
                      if (!_showWarning)
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF34A853),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),

                      const SizedBox(height: 25),

                      // ================= URL TEXT =================
                      const Center(
                        child: Text(
                          "https://www.communisign.com",
                          style: TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ================= SIGN UP SECTION =================
                      const Center(
                        child: Text(
                          "New to Communisign?",
                          style: TextStyle(color: Color(0xFF2C3E50), fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SignUpScreen()),
                            );
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(color: Color(0xFF34A853), fontWeight: FontWeight.bold, fontSize: 24),
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

  // بناء العنوان العادي (COMMUNISIGN)
  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Text(
        'COMMUNISIGN',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // بناء كارد التحذير المطابق تماماً للصورة الثانية
  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5), // لون خلفية الكارد الوردي الخفيف
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Warning Message',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Spacer(),
              Icon(Icons.info, color: Color(0xFF0D47A1), size: 28), // علامة التعجب الزرقاء
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '"By continuing as a guest, you will only have access to the \'Communicate\' feature. The \'Learn\' module (which tracks your progress) and the \'Emergency SOS\' feature will be disabled."',
            style: TextStyle(fontSize: 16, height: 1.3, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isAgreed,
                activeColor: const Color(0xFF34A853),
                onChanged: (val) {
                  setState(() {
                    _isAgreed = val ?? false;
                  });
                },
              ),
              const Text(
                'I agree on the above',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const Spacer(),
              // زر Next للمتابعة كـ Guest (لا يعمل إلا لو تم اختيار الـ Checkbox)
              ElevatedButton(
                onPressed: _isAgreed ? _navigateToHomeAsGuest : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34A853),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}