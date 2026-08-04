import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppSnackBarVariant { info, success, warning, error }

class AppSnackBarAction {
  final String label;
  final VoidCallback onPressed;

  const AppSnackBarAction({required this.label, required this.onPressed});
}

void showAppSnackBar(
  BuildContext context, {
  required String message,
  AppSnackBarVariant variant = AppSnackBarVariant.info,
  Duration duration = const Duration(seconds: 3),
  AppSnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: action == null
          ? null
          : SnackBarAction(label: action.label, onPressed: action.onPressed),
      backgroundColor: _backgroundColorForVariant(context, variant),
    ),
  );
}

Color _backgroundColorForVariant(
  BuildContext context,
  AppSnackBarVariant variant,
) {
  switch (variant) {
    case AppSnackBarVariant.info:
      return AppColors.textPrimary(context);
    case AppSnackBarVariant.success:
      return AppColors.statusSuccess(context);
    case AppSnackBarVariant.warning:
      return AppColors.statusWarning(context);
    case AppSnackBarVariant.error:
      return AppColors.statusDanger(context);
  }
}
