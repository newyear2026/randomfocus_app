import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/language_service.dart';
import '../services/app_localizations.dart';
import '../services/app_version_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_bottom_sheet_option_tile.dart';
import '../widgets/app_form_section_header.dart';
import '../widgets/app_info_tile.dart';
import '../widgets/app_screen.dart';
import '../widgets/app_section_card.dart';
import '../widgets/privacy_policy_sheet_content.dart';
import '../widgets/app_update_notice.dart';
import 'icon_preview_page.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale)? onLanguageChanged;
  final Function(ThemeMode)? onThemeModeChanged;
  final Future<AppVersion> Function() versionLoader;

  const SettingsPage({
    super.key,
    this.onLanguageChanged,
    this.onThemeModeChanged,
    this.versionLoader = AppVersionService.getCurrentVersion,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  String _currentLanguage = 'en';
  ThemeMode _currentThemeMode = ThemeMode.system;
  AppVersion? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    _loadCurrentThemeMode();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final version = await widget.versionLoader();
    if (mounted) {
      setState(() => _appVersion = version);
    }
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await LanguageService.getSavedLanguage();
    if (mounted) {
      setState(() {
        _currentLanguage = language;
      });
    }
  }

  Future<void> _loadCurrentThemeMode() async {
    final mode = await ThemeService.getSavedThemeMode();
    if (mounted) {
      setState(() {
        _currentThemeMode = mode;
      });
    }
  }

  String _themeLabel(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    final key = ThemeService.translationKeyFor(mode);
    return l10n?.translate(key) ?? _fallbackThemeLabel(mode);
  }

  String _fallbackThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
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

  Future<void> _showThemeSheet() async {
    final l10n = AppLocalizations.of(context);

    await showAppBottomSheet<void>(
      context: context,
      title: l10n?.selectTheme ?? 'Select theme',
      message: l10n?.theme ?? 'Theme',
      variant: AppDialogVariant.info,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ThemeService.supportedModes.map((mode) {
          final isSelected = _currentThemeMode == mode;

          return AppBottomSheetOptionTile(
            title: _themeLabel(context, mode),
            selected: isSelected,
            subtitle: isSelected
                ? (l10n?.selectedOption ?? 'Selected')
                : (l10n?.tapToSelect ?? 'Tap to choose'),
            onTap: () {
              Navigator.pop(context);
              _changeThemeMode(mode);
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

  void _changeThemeMode(ThemeMode mode) {
    if (mode == _currentThemeMode) return;

    final l10n = AppLocalizations.of(context);
    setState(() {
      _currentThemeMode = mode;
    });

    if (widget.onThemeModeChanged != null) {
      widget.onThemeModeChanged!(mode);
    } else {
      // 콜백이 없으면 최소한 선택 값은 남겨 다음 실행에 반영되도록 한다.
      ThemeService.saveThemeMode(mode);
    }

    showAppSnackBar(
      context,
      message: l10n?.themeUpdated ?? 'Theme updated.',
      variant: AppSnackBarVariant.success,
    );
  }

  Future<void> _showAboutSheet() async {
    final l10n = AppLocalizations.of(context);
    await showAppBottomSheet<void>(
      context: context,
      title: l10n?.about ?? 'About',
      message:
          '${l10n?.appTitle ?? 'RandomFocus'}\n${l10n?.translate('version') ?? 'Version'} ${_appVersion?.displayLabel ?? '...'}',
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

  /// 같은 그룹의 타일을 카드 하나에 구분선으로 묶는다.
  /// 항목마다 카드를 띄우면 시각적 소음이 커진다.
  Widget _buildGroup(BuildContext context, List<Widget> tiles) {
    final children = <Widget>[];
    for (var index = 0; index < tiles.length; index++) {
      if (index > 0) {
        children.add(Divider(color: AppColors.subtleBorder(context), height: 1));
      }
      children.add(tiles[index]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppSectionCard(
        padding: EdgeInsets.zero,
        radius: AppRadius.card,
        child: ClipRRect(
          borderRadius: AppRadius.cardBorder,
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScreen(
      // 앱바에 이미 화면 제목이 있으므로 본문에서 제목을 반복하지 않는다.
      titleText: l10n?.settings ?? 'Settings',
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          AppFormSectionHeader(title: l10n?.preferences ?? 'Preferences'),
          _buildGroup(context, [
            AppInfoTile(
              grouped: true,
              icon: Icons.language,
              title: l10n?.language ?? 'Language',
              subtitle:
                  LanguageService.languageNames[_currentLanguage] ?? 'English',
              onTap: _showLanguageSheet,
            ),
            AppInfoTile(
              grouped: true,
              icon: Icons.brightness_6_outlined,
              title: l10n?.theme ?? 'Theme',
              subtitle: _themeLabel(context, _currentThemeMode),
              onTap: _showThemeSheet,
            ),
          ]),
          AppFormSectionHeader(title: l10n?.information ?? 'Information'),
          _buildGroup(context, [
            AppInfoTile(
              grouped: true,
              icon: Icons.help_outline,
              title: l10n?.help ?? 'Help',
              subtitle: l10n?.howToUse ?? 'How to use the app',
              onTap: _showHelpSheet,
            ),
            AppInfoTile(
              grouped: true,
              icon: Icons.new_releases_outlined,
              title: l10n?.translate('whatsNew') ?? "What's new",
              subtitle:
                  l10n?.translate('viewLatestChanges') ??
                  'View the latest changes',
              onTap: _appVersion == null
                  ? null
                  : () => showAppUpdateNotice(context, _appVersion!),
            ),
            AppInfoTile(
              grouped: true,
              icon: Icons.privacy_tip_outlined,
              title: l10n?.privacyPolicy ?? 'Privacy Policy',
              subtitle: l10n?.viewPrivacyPolicy ?? 'View our privacy policy',
              onTap: _showPrivacyPolicySheet,
            ),
            AppInfoTile(
              grouped: true,
              icon: Icons.info_outline,
              title: l10n?.about ?? 'About',
              subtitle: _appVersion?.displayLabel ?? '...',
              onTap: _showAboutSheet,
            ),
          ]),
          // 아이콘 미리보기는 개발용 도구이므로 릴리스 빌드에서는 숨긴다.
          if (kDebugMode) ...[
            const AppFormSectionHeader(title: 'Developer'),
            _buildGroup(context, [
              AppInfoTile(
                grouped: true,
                icon: Icons.image_outlined,
                title: 'App icon preview',
                subtitle: 'Preview and export the wheel icon',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const IconPreviewPage(),
                    ),
                  );
                },
              ),
            ]),
          ],
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
