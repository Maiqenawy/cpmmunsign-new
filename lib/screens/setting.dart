
import 'package:cominsign_new/core/app_lang.dart';
import 'package:cominsign_new/core/user_session.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    selectedLanguage = widget.selectedLanguage;

    // ✅ FIX: safe navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!UserSession.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

String t(String key) => AppLang.t(key);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get textColor => _isDark ? Colors.white : Colors.black;

  Color get iconBg => _isDark
      ? const Color.fromRGBO(255, 255, 255, 0.20)
      : const Color.fromRGBO(0, 0, 0, 0.08);

  Color get dividerColor => _isDark
      ? const Color.fromRGBO(255, 255, 255, 0.30)
      : const Color.fromRGBO(0, 0, 0, 0.30);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLang.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildUserProfile(),
                    const SizedBox(height: 30),
                    _buildDivider(),
                    const SizedBox(height: 30),
                    _buildPreferencesTitle(),
                    const SizedBox(height: 20),
                    _buildLanguageOption(),
                    const SizedBox(height: 20),
                    _buildDarkModeOption(),
                    const SizedBox(height: 20),
                    _buildContactsOption(),
                    const SizedBox(height: 30),
                    _buildLogoutButton(),
                  ],
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
        Icon(Icons.settings, color: textColor, size: 32),
        const SizedBox(width: 12),
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

  Widget _buildUserProfile() {
    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.grey[300],
          backgroundImage: const AssetImage('images/SETTING.png'),
        ),
        const SizedBox(width: 16),
        Text(
          t('user'),
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() => Container(height: 1, color: dividerColor);

  Widget _buildPreferencesTitle() {
    return Text(
      t('preferences'),
      style: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLanguageOption() {
    return _buildRow(
      Icons.language,
      t('language'),
      GestureDetector(
        onTap: _showLanguageDialog,
        child: Text(selectedLanguage, style: TextStyle(color: textColor)),
      ),
    );
  }

  Widget _buildDarkModeOption() {
    return _buildRow(
      Icons.dark_mode,
      t('dark_mode'),
      Switch(
        value: _isDark,
        onChanged: widget.onThemeChanged,
      ),
    );
  }

  Widget _buildContactsOption() {
    return _buildRow(
      Icons.contacts,
      "Emergency Contacts",
      const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: () {
        if (!UserSession.isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactsPage()),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        ),
        onPressed: () async {
          await UserSession.logout();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (r) => false,
          );
        },
        child: const Text("Logout"),
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, Widget trailing,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconBg,
              child: Icon(icon, color: textColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: TextStyle(color: textColor, fontSize: 18)),
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
            ListTile(
              title: const Text("English"),
              onTap: () async {
                await AppLang.load("English");
                if (!mounted) return;
                setState(() => selectedLanguage = "English");
                widget.onLanguageChanged("English");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("العربية"),
              onTap: () async {
                await AppLang.load("العربية");
                if (!mounted) return;
                setState(() => selectedLanguage = "العربية");
                widget.onLanguageChanged("العربية");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
