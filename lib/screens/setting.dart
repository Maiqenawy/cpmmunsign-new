import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cominsign_new/core/app_lang.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:cominsign_new/core/service/api-service.dart';
import '../widgets/gradient_background.dart';
import 'contacts_page.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final String selectedLanguage;
  final Function(bool) onThemeChanged;
  final Function(String) onLanguageChanged;
  final String Function(String) t;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.selectedLanguage,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.t,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String selectedLanguage;

  // ✅ اسم المستخدم
  String get userName =>
      UserSession.email?.split('@').first ?? "User";

  @override
  void initState() {
    super.initState();

    selectedLanguage =
        widget.selectedLanguage == 'العربية' ? 'ar' : 'en';

    if (!UserSession.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }
  }

  String t(String key) => AppLang.t(key);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get textColor => _isDark ? Colors.white : Colors.black;

  Color get iconBg =>
      _isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.06);

  Color get cardColor =>
      _isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.75);

  Color get dividerColor =>
      _isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.15);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 700;
    final padding = isTablet ? width * 0.14 : 24.0;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLang.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildUserProfile(),
                        const SizedBox(height: 28),
                        _buildDivider(),
                        const SizedBox(height: 28),
                        _buildPreferencesTitle(),
                        const SizedBox(height: 18),
                        _buildLanguageOption(),
                        const SizedBox(height: 16),
                        _buildDarkModeOption(),
                        const SizedBox(height: 16),
                        _buildContactsOption(),
                        const SizedBox(height: 18),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.settings, color: textColor, size: 30),
        const SizedBox(width: 10),
        Text(
          t('settings'),
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ✅ هنا التعديل الأساسي
  Widget _buildUserProfile() {
    return Row(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.grey[300],
          backgroundImage: const AssetImage('images/SETTING.png'),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            userName, // 🔥 اسم المستخدم بدل static
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: dividerColor);
  }

  Widget _buildPreferencesTitle() {
    return Text(
      t('preferences'),
      style: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLanguageOption() {
    return _buildRow(
      Icons.language,
      t('language'),
      Text(
        selectedLanguage == 'ar' ? 'العربية' : 'English',
        style: TextStyle(color: textColor),
      ),
      onTap: _showLanguageDialog,
    );
  }

  Widget _buildDarkModeOption() {
    return _buildRow(
      Icons.dark_mode,
      t('dark_mode'),
      Switch(
        value: widget.isDarkMode,
        onChanged: widget.onThemeChanged,
      ),
    );
  }

  Widget _buildContactsOption() {
    return _buildRow(
      Icons.contacts,
      "Emergency Contacts",
      Icon(Icons.arrow_forward_ios, color: textColor, size: 18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactsPage()),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {
          await UserSession.logout();

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        child: const Text(
          "Logout",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String title,
    Widget trailing, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconBg,
              child: Icon(icon, color: textColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageItem("English", "en"),
            _languageItem("العربية", "ar"),
          ],
        ),
      ),
    );
  }

  Widget _languageItem(String label, String langCode) {
    return ListTile(
      title: Text(label),
      onTap: () async {
        await AppLang.load(langCode);

        if (!mounted) return;

        setState(() => selectedLanguage = langCode);

        widget.onLanguageChanged(langCode);

        Navigator.pop(context);
      },
    );
  }
}