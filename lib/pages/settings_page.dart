import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/slide_in_widget.dart';
import '../services/language_service.dart';
import '../services/app_localizations.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_bottom_sheet_option_tile.dart';
import '../widgets/app_form_section_header.dart';
import '../widgets/app_screen.dart';
import '../widgets/app_selection_tile.dart';
import '../widgets/app_switch_tile.dart';
import '../widgets/privacy_policy_sheet_content.dart';
import 'icon_preview_page.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;

  const SettingsPage({super.key, this.onLanguageChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  String _currentLanguage = 'en';
  bool _notificationsEnabled = true;

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

  Future<void> _showLanguageSheet() async {
    final l10n = AppLocalizations.of(context);

    await showAppBottomSheet<void>(
      context: context,
      title: l10n?.selectLanguage ?? 'Select Language',
      message: l10n?.language ?? 'Language',
      variant: AppDialogVariant.info,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: LanguageService.supportedLocales.map((locale) {
          final languageCode = locale.languageCode;
          final languageName =
              LanguageService.languageNames[languageCode] ?? languageCode;
          final isSelected = _currentLanguage == languageCode;

          return AppBottomSheetOptionTile(
            title: languageName,
            selected: isSelected,
            subtitle: isSelected
                ? (l10n?.selectedOption ?? 'Selected')
                : (l10n?.tapToSelect ?? 'Tap to choose'),
            onTap: () async {
              Navigator.pop(context);
              await _changeLanguage(languageCode);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _changeLanguage(String selectedLanguage) async {
    if (selectedLanguage == _currentLanguage) return;

    final l10n = AppLocalizations.of(context);
    final locale = Locale(selectedLanguage);
    await LanguageService.saveLanguage(selectedLanguage);

    if (mounted) {
      setState(() {
        _currentLanguage = selectedLanguage;
      });

      if (widget.onLanguageChanged != null) {
        widget.onLanguageChanged!(locale);
      }

      showAppSnackBar(
        context,
        message: l10n?.languageUpdated ?? 'Language updated.',
        variant: AppSnackBarVariant.success,
      );
    }
  }

  Future<void> _showAboutSheet() async {
    final l10n = AppLocalizations.of(context);
    await showAppBottomSheet<void>(
      context: context,
      title: l10n?.about ?? 'About',
      message:
          '${l10n?.appTitle ?? 'RandomFocus'}\n${l10n?.appVersion ?? 'Version 1.0.0'}',
      variant: AppDialogVariant.info,
      child: Text(
        l10n?.appDescription ??
            'An app to help you maintain focus with random timer sessions.',
      ),
    );
  }

  Future<void> _showHelpSheet() async {
    final l10n = AppLocalizations.of(context);
    await showAppBottomSheet<void>(
      context: context,
      title: l10n?.help ?? 'Help',
      message: l10n?.howToUse ?? 'How to Use',
      variant: AppDialogVariant.info,
      child: Text(
        l10n?.howToUseContent ??
            '1. Spin the wheel to choose your study time\n'
                '2. Complete your focus session\n'
                '3. Take a break\n'
                '4. Repeat and stay motivated!\n\n'
                'You have 2 attempts per day.',
      ),
    );
  }

  Future<void> _showPrivacyPolicySheet() async {
    const privacyPolicyUrl = 'https://your-website.com/privacy-policy';
    final l10n = AppLocalizations.of(context);

    await showAppBottomSheet<void>(
      context: context,
      title: l10n?.privacyPolicy ?? 'Privacy Policy',
      message: l10n?.privacyPolicySheetSummary ?? 'Review the policy link.',
      variant: AppDialogVariant.info,
      child: PrivacyPolicySheetContent(
        body:
            l10n?.privacyPolicySheetBody ??
            'Review the policy link before opening it in your browser.',
        urlLabel: l10n?.policyUrlLabel ?? 'Policy URL',
        url: privacyPolicyUrl,
      ),
      actions: [
        AppDialogAction(
          label: l10n?.openInBrowser ?? 'Open in browser',
          isPrimary: true,
          onPressed: () async {
            Navigator.pop(context);
            await _launchPrivacyPolicyUrl(privacyPolicyUrl);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScreen(
      titleText: l10n?.settings ?? 'Settings',
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          AppFormSectionHeader(
            title: l10n?.settings ?? 'Settings',
            subtitle: 'Preferences and support',
          ),
          SlideInWidget(
            index: 0,
            child: AppSwitchTile(
              icon: Icons.notifications_outlined,
              title: l10n?.notifications ?? 'Notifications',
              subtitle: l10n?.manageAlerts ?? 'Manage your alerts',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          SlideInWidget(
            index: 1,
            child: AppSelectionTile(
              icon: Icons.language,
              title: l10n?.language ?? 'Language',
              subtitle:
                  LanguageService.languageNames[_currentLanguage] ?? 'English',
              onTap: _showLanguageSheet,
            ),
          ),
          const SizedBox(height: 8),
          const AppFormSectionHeader(
            title: 'Information',
            subtitle: 'Help, legal, and app metadata',
          ),
          const SizedBox(height: 8),
          SlideInWidget(
            index: 2,
            child: AppSelectionTile(
              icon: Icons.info_outline,
              title: l10n?.about ?? 'About',
              subtitle: l10n?.appInformation ?? 'App information',
              onTap: _showAboutSheet,
            ),
          ),
          const SizedBox(height: 8),
          SlideInWidget(
            index: 3,
            child: AppSelectionTile(
              icon: Icons.help_outline,
              title: l10n?.help ?? 'Help',
              subtitle: l10n?.howToUse ?? 'How to use the app',
              onTap: _showHelpSheet,
            ),
          ),
          const SizedBox(height: 8),
          SlideInWidget(
            index: 4,
            child: AppSelectionTile(
              icon: Icons.privacy_tip_outlined,
              title: l10n?.privacyPolicy ?? 'Privacy Policy',
              subtitle: l10n?.viewPrivacyPolicy ?? 'View our privacy policy',
              onTap: _showPrivacyPolicySheet,
            ),
          ),
          const SizedBox(height: 8),
          SlideInWidget(
            index: 5,
            child: AppSelectionTile(
              icon: Icons.image_outlined,
              title: '앱 아이콘 미리보기',
              subtitle: '룰렛 휠 아이콘 미리보기 및 저장',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const IconPreviewPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPrivacyPolicyUrl(String privacyPolicyUrl) async {
    final uri = Uri.parse(privacyPolicyUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    showAppSnackBar(
      context,
      message: l10n?.couldNotOpenUrl ?? 'Could not open privacy policy URL',
      variant: AppSnackBarVariant.error,
    );
  }
}
