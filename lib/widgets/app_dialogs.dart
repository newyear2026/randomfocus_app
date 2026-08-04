import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppDialogVariant { info, warning, danger }

class AppDialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });
}

Future<void> showAppInfoDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String actionLabel,
  AppDialogVariant variant = AppDialogVariant.info,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        _iconForVariant(variant),
        color: _colorForVariant(context, variant),
      ),
      title: Text(title, style: AppTextStyles.sectionTitle(context)),
      content: Text(content, style: AppTextStyles.body(context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String cancelLabel,
  required String confirmLabel,
  AppDialogVariant variant = AppDialogVariant.warning,
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        _iconForVariant(variant),
        color: _colorForVariant(context, variant),
      ),
      title: Text(title, style: AppTextStyles.sectionTitle(context)),
      content: Text(content, style: AppTextStyles.body(context)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return result ?? false;
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  String? message,
  Widget? child,
  List<AppDialogAction> actions = const [],
  AppDialogVariant variant = AppDialogVariant.info,
}) {
  // 기본 시트는 화면의 9/16까지만 커지기 때문에 선택지가 서너 개만 되어도
  // 내용이 잘린다. 항상 스크롤 가능한 시트로 열고 높이만 제한해서, 짧은
  // 내용은 내용 높이에 맞추고 긴 내용은 넘치는 대신 스크롤되게 한다.
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _iconForVariant(variant),
                  color: _colorForVariant(context, variant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: AppTextStyles.sectionTitle(context)),
                ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message, style: AppTextStyles.body(context)),
            ],
            if (child != null) ...[const SizedBox(height: 16), child],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions
                    .map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextButton(
                          onPressed: action.onPressed,
                          style: action.isPrimary
                              ? TextButton.styleFrom(
                                  foregroundColor: _colorForVariant(
                                    context,
                                    variant,
                                  ),
                                )
                              : null,
                          child: Text(action.label),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

IconData _iconForVariant(AppDialogVariant variant) {
  switch (variant) {
    case AppDialogVariant.info:
      return Icons.info_outline;
    case AppDialogVariant.warning:
      return Icons.warning_amber_rounded;
    case AppDialogVariant.danger:
      return Icons.error_outline;
  }
}

Color _colorForVariant(BuildContext context, AppDialogVariant variant) {
  switch (variant) {
    case AppDialogVariant.info:
      return AppColors.accent(context);
    case AppDialogVariant.warning:
      return AppColors.statusWarning(context);
    case AppDialogVariant.danger:
      return AppColors.statusDanger(context);
  }
}
