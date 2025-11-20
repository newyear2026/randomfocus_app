import 'package:flutter/material.dart';
import '../widgets/slide_in_widget.dart';
import '../services/language_service.dart';
import '../services/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;

  const SettingsPage({super.key, this.onLanguageChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await LanguageService.getSavedLanguage();
    if (mounted) {
      setState(() {
        _currentLanguage = language;
      });
    }
  }

  Future<void> _showLanguageDialog() async {
    final selectedLanguage = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.selectLanguage ?? 'Select Language',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageService.supportedLocales.map((locale) {
            final languageCode = locale.languageCode;
            final languageName =
                LanguageService.languageNames[languageCode] ?? languageCode;
            final isSelected = _currentLanguage == languageCode;

            return ListTile(
              title: Text(languageName),
              leading: Radio<String>(
                value: languageCode,
                groupValue: _currentLanguage,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              ),
              selected: isSelected,
              onTap: () {
                Navigator.pop(context, languageCode);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
        ],
      ),
    );

    if (selectedLanguage != null && selectedLanguage != _currentLanguage) {
      final locale = Locale(selectedLanguage);
      await LanguageService.saveLanguage(selectedLanguage);

      if (mounted) {
        setState(() {
          _currentLanguage = selectedLanguage;
        });

        // 언어 변경 콜백 호출
        if (widget.onLanguageChanged != null) {
          widget.onLanguageChanged!(locale);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.purple.shade50,
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade500,
                    Colors.purple.shade400,
                  ],
                ),
              ),
            ),
            title: Text(
              AppLocalizations.of(context)?.settings ?? 'Settings',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // 모바일 터치 최적화: 최소 높이 56dp, 더 큰 패딩
              // 스크롤 애니메이션 적용
              SlideInWidget(
                index: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: const Icon(Icons.notifications_outlined, size: 28),
                    title: Text(
                      AppLocalizations.of(context)?.notifications ??
                          'Notifications',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)?.manageAlerts ??
                          'Manage your alerts',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // TODO: Implement notification logic
                      },
                    ),
                    minVerticalPadding: 12,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SlideInWidget(
                index: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: const Icon(Icons.language, size: 28),
                    title: Text(
                      AppLocalizations.of(context)?.language ?? 'Language',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      LanguageService.languageNames[_currentLanguage] ??
                          'English',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 28),
                    minVerticalPadding: 12,
                    onTap: _showLanguageDialog,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SlideInWidget(
                index: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: const Icon(Icons.info_outline, size: 28),
                    title: Text(
                      AppLocalizations.of(context)?.about ?? 'About',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)?.appInformation ??
                          'App information',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 28),
                    minVerticalPadding: 12,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)?.appTitle ??
                                'Random Pomodoro Timer',
                          ),
                          content: Text(
                            '${AppLocalizations.of(context)?.appTitle ?? 'Random Pomodoro Timer'}\n\n'
                            '${AppLocalizations.of(context)?.appVersion ?? 'Version 1.0.0'}\n\n'
                            '${AppLocalizations.of(context)?.appDescription ?? 'An app to help you maintain focus with random timer sessions.'}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                AppLocalizations.of(context)?.close ?? 'Close',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SlideInWidget(
                index: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: const Icon(Icons.help_outline, size: 28),
                    title: Text(
                      AppLocalizations.of(context)?.help ?? 'Help',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)?.howToUse ??
                          'How to use the app',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 28),
                    minVerticalPadding: 12,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)?.howToUse ??
                                'How to Use',
                          ),
                          content: Text(
                            AppLocalizations.of(context)?.howToUseContent ??
                                '1. Spin the wheel to choose your study time\n'
                                    '2. Complete your focus session\n'
                                    '3. Take a break\n'
                                    '4. Repeat and stay motivated!\n\n'
                                    'You have 2 attempts per day.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                AppLocalizations.of(context)?.gotIt ?? 'Got it',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
