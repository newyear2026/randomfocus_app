import 'package:flutter/material.dart';
import '../widgets/slide_in_widget.dart';
import '../services/language_service.dart';

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
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageService.supportedLocales.map((locale) {
            final languageCode = locale.languageCode;
            final languageName = LanguageService.languageNames[languageCode] ?? languageCode;
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
            child: const Text('Cancel'),
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
      appBar: AppBar(
        title: const Text('Settings'),
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
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.notifications_outlined,
                size: 28,
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Manage your alerts',
                style: TextStyle(fontSize: 14),
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
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.language,
                size: 28,
              ),
              title: const Text(
                'Language',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                LanguageService.languageNames[_currentLanguage] ?? 'English',
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
            index: 3,
            child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.info_outline,
                size: 28,
              ),
              title: const Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'App information',
                style: TextStyle(fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_right, size: 28),
              minVerticalPadding: 12,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Random Pomodoro Timer'),
                    content: const Text(
                      'Random Pomodoro Timer\n\n'
                      'Version 1.0.0\n\n'
                      'An app to help you maintain focus with random timer sessions.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
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
            index: 4,
            child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.help_outline,
                size: 28,
              ),
              title: const Text(
                'Help',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'How to use the app',
                style: TextStyle(fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_right, size: 28),
              minVerticalPadding: 12,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('How to Use'),
                    content: const Text(
                      '1. Spin the wheel to choose your study time\n'
                      '2. Complete your focus session\n'
                      '3. Take a break\n'
                      '4. Repeat and stay motivated!\n\n'
                      'You have 2 attempts per day.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
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
    );
  }
}

