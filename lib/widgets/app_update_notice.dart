import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import '../services/app_version_service.dart';
import 'app_dialogs.dart';
import 'recommended_play_update_prompt.dart';

class AppUpdateNotice extends StatefulWidget {
  const AppUpdateNotice({
    super.key,
    required this.child,
    this.versionLoader = AppVersionService.getCurrentVersion,
    this.showRecommendedUpdatePrompt = showRecommendedPlayUpdatePrompt,
  });

  final Widget child;
  final Future<AppVersion> Function() versionLoader;
  final Future<bool> Function(BuildContext) showRecommendedUpdatePrompt;

  @override
  State<AppUpdateNotice> createState() => _AppUpdateNoticeState();
}

class _AppUpdateNoticeState extends State<AppUpdateNotice> {
  @override
  void initState() {
    super.initState();
    _showNoticeForNewVersion();
  }

  Future<void> _showNoticeForNewVersion() async {
    if (!mounted) return;
    final showedPlayUpdatePrompt = await widget.showRecommendedUpdatePrompt(
      context,
    );
    if (!mounted || showedPlayUpdatePrompt) return;

    final version = await widget.versionLoader();
    final shouldShow = await AppVersionService.shouldShowUpdateNotice(version);
    if (!mounted || !shouldShow) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showAppUpdateNotice(context, version);
      await AppVersionService.markUpdateNoticeSeen(version);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> showAppUpdateNotice(BuildContext context, AppVersion version) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<void>(
    context: context,
    title: l10n?.translate('appUpdated') ?? 'RandomFocus has been updated',
    message:
        '${l10n?.translate('version') ?? 'Version'} ${version.displayLabel}',
    variant: AppDialogVariant.info,
    isScrollControlled: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n?.translate('whatsNew') ?? "What's new"),
        const SizedBox(height: 8),
        _ReleaseNote(text: l10n?.translate('releaseNoteTimer') ?? ''),
        _ReleaseNote(text: l10n?.translate('releaseNoteNotice') ?? ''),
        _ReleaseNote(text: l10n?.translate('releaseNoteVersion') ?? ''),
        _ReleaseNote(text: l10n?.translate('releaseNotePlayUpdate') ?? ''),
      ],
    ),
    actions: [
      AppDialogAction(
        label: l10n?.gotIt ?? 'Got it',
        isPrimary: true,
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

class _ReleaseNote extends StatelessWidget {
  const _ReleaseNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•'),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
