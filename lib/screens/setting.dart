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

  String get userName =>
      UserSession.email?.split('@').first ?? t("user");

  @override
  void initState() {
    super.initState();

  selectedLanguage =
    AppLang.currentLocale.languageCode;

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

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get textColor =>
      _isDark ? Colors.white : Colors.black;

  Color get subtitleColor =>
      _isDark ? Colors.white60 : Colors.black45;

  Color get iconBg =>
      _isDark
          ? Colors.white.withOpacity(0.12)
          : Colors.black.withOpacity(0.05);

  Color get cardColor =>
      _isDark
          ? Colors.white.withOpacity(0.07)
          : Colors.white.withOpacity(0.85);

  Color get dividerColor =>
      _isDark
          ? Colors.white.withOpacity(0.12)
          : Colors.black.withOpacity(0.08);

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
                  physics: const BouncingScrollPhysics(),

                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 24,
                  ),

                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 520),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

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

                        const SizedBox(height: 12),

                        _buildDarkModeOption(),

                        const SizedBox(height: 12),

                        _buildContactsOption(),

                        const SizedBox(height: 32),

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
        Container(
          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(
            Icons.settings_rounded,
            color: textColor,
            size: 26,
          ),
        ),

        const SizedBox(width: 12),

        Text(
          t('settings'),

          style: TextStyle(
            color: textColor,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

      decoration: BoxDecoration(
        color: cardColor,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2AA88F),
                  Color(0xFF114238),
                ],
              ),
            ),

            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  const AssetImage('images/SETTING.png'),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  userName,

                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  UserSession.email ?? '',

                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 13,
                  ),

                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child:
              Container(height: 1, color: dividerColor),
        ),

        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12),

          child: Container(
            width: 6,
            height: 6,

            decoration: BoxDecoration(
              color: dividerColor,
              shape: BoxShape.circle,
            ),
          ),
        ),

        Expanded(
          child:
              Container(height: 1, color: dividerColor),
        ),
      ],
    );
  }

  Widget _buildPreferencesTitle() {
    return Text(
      t('preferences'),

      style: TextStyle(
        color: subtitleColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildLanguageOption() {
    return _buildRow(
      Icons.language_rounded,

      t('language'),

      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),

        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(8),
        ),

        child: Text(
          selectedLanguage == 'ar'
              ? t("arabic")
              : t("english"),

          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      onTap: _showLanguageDialog,
    );
  }

  Widget _buildDarkModeOption() {
    return _buildRow(
      Icons.dark_mode_rounded,

      t('dark_mode'),

      Switch.adaptive(
        value: widget.isDarkMode,
        onChanged: widget.onThemeChanged,
        activeColor: const Color(0xFF2AA88F),
      ),
    );
  }

  Widget _buildContactsOption() {
    return _buildRow(
      Icons.contacts_rounded,

      t("emergency_contacts"),

      Icon(
        Icons.chevron_right_rounded,
        color: subtitleColor,
        size: 22,
      ),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ContactsPage(),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,

      child: ElevatedButton.icon(
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.white,
          size: 20,
        ),

        label: Text(
          t("logout"),

          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.shade700,
          shadowColor: Colors.red.withOpacity(0.4),
          elevation: 6,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
onPressed: () async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Logout"),
      content: const Text(
        "Are you sure you want to log out?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text("Logout"),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  await UserSession.logout();

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
    (route) => false,
  );
},
       
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String title,
    Widget trailing, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,

        splashColor: Colors.white.withOpacity(0.08),

        highlightColor:
            Colors.white.withOpacity(0.04),

        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          decoration: BoxDecoration(
            color: cardColor,

            borderRadius: BorderRadius.circular(16),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,

                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: Icon(
                  icon,
                  color: textColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,

                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        title: Text(t('language')),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            _languageItem(
              t("english"),
              "en",
            ),

            _languageItem(
              t("arabic"),
              "ar",
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageItem(
    String label,
    String langCode,
  ) {
    final isSelected =
        selectedLanguage == langCode;

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      title: Text(
        label,

        style: TextStyle(
          fontWeight: isSelected
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),

      trailing: isSelected
          ? const Icon(
              Icons.check_rounded,
              color: Color(0xFF2AA88F),
            )
          : null,

      onTap: () async {
        await AppLang.load(langCode);

        if (!mounted) return;

        setState(() {
          selectedLanguage = langCode;
        });

        widget.onLanguageChanged(langCode);

        Navigator.pop(context);
      },
    );
  }
}
