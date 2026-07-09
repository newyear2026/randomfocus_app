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
      icon: Icon(_iconForVariant(variant), color: _colorForVariant(variant)),
      title: Text(title, style: AppTextStyles.sectionTitle),
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
      icon: Icon(_iconForVariant(variant), color: _colorForVariant(variant)),
      title: Text(title, style: AppTextStyles.sectionTitle),
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
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _iconForVariant(variant),
                  color: _colorForVariant(variant),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
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
                                  foregroundColor: _colorForVariant(variant),
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

Color _colorForVariant(AppDialogVariant variant) {
  switch (variant) {
    case AppDialogVariant.info:
      return AppColors.brandPrimary;
    case AppDialogVariant.warning:
      return AppColors.warning;
    case AppDialogVariant.danger:
      return Colors.red;
  }
}
