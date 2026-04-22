import 'package:flutter/material.dart';
import 'package:cominsign/core/app_lang.dart';
import '../widgets/gradient_background.dart';
import 'package:cominsign/lib/core/user_session.dart';
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
  late bool isDarkMode;
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();

    // ✅ PROTECT PAGE
    if (!UserSession.isLoggedIn) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return;
    }

    isDarkMode = widget.isDarkMode;
    selectedLanguage = widget.selectedLanguage;
  }

  String t(String key) => widget.t(key);

  Color get textColor => isDarkMode ? Colors.white : Colors.black;

  Color get iconBg => isDarkMode
      ? const Color.fromRGBO(255, 255, 255, 0.20)
      : const Color.fromRGBO(0, 0, 0, 0.08);

  Color get dividerColor => isDarkMode
      ? const Color.fromRGBO(255, 255, 255, 0.30)
      : const Color.fromRGBO(0, 0, 0, 0.30);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppLang.notifier,
      builder: (_, __, ___) {
        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildUserProfile(),
                    const SizedBox(height: 40),
                    _buildDivider(),
                    const SizedBox(height: 40),
                    _buildPreferencesTitle(),
                    const SizedBox(height: 30),
                    _buildLanguageOption(),
                    const SizedBox(height: 30),
                    _buildDarkModeOption(),
                    const SizedBox(height: 30),

                    // ✅ CONTACTS
                    _buildContactsOption(),

                    const SizedBox(height: 40),

                    // ✅ LOGOUT
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

  // ================= HEADER =================
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.settings, color: textColor, size: 32),
        const SizedBox(width: 12),
        Text(
          t('settings'),
          style: TextStyle(
            color: textColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ================= PROFILE =================
  Widget _buildUserProfile() {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[300],
          backgroundImage: const AssetImage('images/SETTING.png'),
          child: const Icon(Icons.person, size: 40),
        ),
        const SizedBox(width: 20),
        Text(
          t('user'),
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ================= DIVIDER =================
  Widget _buildDivider() {
    return Container(height: 1, color: dividerColor);
  }

  // ================= TITLE =================
  Widget _buildPreferencesTitle() {
    return Text(
      t('preferences'),
      style: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ================= LANGUAGE =================
  Widget _buildLanguageOption() {
    return _buildSettingRow(
      icon: Icons.language,
      title: t('language'),
      trailing: GestureDetector(
        onTap: _showLanguageDialog,
        child: Text(
          selectedLanguage,
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
    );
  }

  // ================= DARK MODE =================
  Widget _buildDarkModeOption() {
    return _buildSettingRow(
      icon: Icons.dark_mode,
      title: t('dark_mode'),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          setState(() => isDarkMode = value);
          widget.onThemeChanged(value);
        },
      ),
    );
  }

  // ================= CONTACTS =================
  Widget _buildContactsOption() {
    return _buildSettingRow(
      icon: Icons.contacts,
      title: "Emergency Contacts",
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
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

  // ================= LOGOUT =================
  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          await UserSession.logout();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        child: const Text(
          "Logout",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  // ================= ROW =================
  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconBg,
            child: Icon(icon, color: textColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // ================= LANGUAGE DIALOG =================
 void _showLanguageDialog() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t('language')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _languageItem('English', 'en'),
          _languageItem('العربية', 'ar'),
        ],
      ),
    ),
  );
} 

Widget _languageItem(String lang) {
  return ListTile(
    title: Text(lang),
    onTap: () async {
      await AppLang.load(lang); // 🔥 دي أهم نقطة

      setState(() => selectedLanguage = lang);
      widget.onLanguageChanged(lang);

      Navigator.pop(context);
    },
  );
}
}
