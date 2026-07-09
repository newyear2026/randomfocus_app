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
      backgroundColor: _backgroundColorForVariant(variant),
    ),
  );
}

Color _backgroundColorForVariant(AppSnackBarVariant variant) {
  switch (variant) {
    case AppSnackBarVariant.info:
      return AppColors.textPrimary;
    case AppSnackBarVariant.success:
      return AppColors.success;
    case AppSnackBarVariant.warning:
      return AppColors.warning;
    case AppSnackBarVariant.error:
      return Colors.red;
  }
}
