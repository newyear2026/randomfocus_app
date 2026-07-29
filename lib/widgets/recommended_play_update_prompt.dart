import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import '../services/play_update_service.dart';
import 'app_dialogs.dart';

/// Google Play에서 새 버전을 확인했을 때 권장 업데이트 안내를 표시한다.
///
/// true는 안내가 표시되었음을 뜻하며, 호출자는 다른 시작 안내와 겹치지
/// 않도록 후속 안내를 생략할 수 있다.
Future<bool> showRecommendedPlayUpdatePrompt(
  BuildContext context, {
  Future<bool> Function()? checkForUpdate,
  Future<bool> Function()? canShowPrompt,
  Future<void> Function()? markPromptShown,
  Future<void> Function()? startUpdate,
}) async {
  final canShow = await (canShowPrompt ?? PlayUpdateService.canShowPrompt)();
  if (!canShow) return false;

  final updateAvailable =
      await (checkForUpdate ??
          PlayUpdateService.isRecommendedUpdateAvailable)();
  if (!updateAvailable || !context.mounted) return false;

  final l10n = AppLocalizations.of(context);
  await showAppBottomSheet<void>(
    context: context,
    title: l10n?.translate('updateAvailable') ?? 'Update available',
    message:
        l10n?.translate('updateAvailableMessage') ??
        'A new version of RandomFocus is ready. Update now to enjoy the latest improvements.',
    variant: AppDialogVariant.info,
    actions: [
      AppDialogAction(
        label: l10n?.translate('later') ?? 'Later',
        onPressed: () => Navigator.pop(context),
      ),
      AppDialogAction(
        label: l10n?.translate('updateNow') ?? 'Update now',
        isPrimary: true,
        onPressed: () async {
          Navigator.pop(context);
          await (startUpdate ?? PlayUpdateService.startRecommendedUpdate)();
        },
      ),
    ],
  );

  await (markPromptShown ?? PlayUpdateService.markPromptShown)();
  return true;
}
