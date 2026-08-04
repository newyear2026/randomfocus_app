import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? leading;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.leading,
    this.height = 60,
    this.width,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.buttonBorder;
    final fill = AppColors.primaryActionGradient(context);
    final isDisabled = onPressed == null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDisabled
              ? fill
                    .map((color) => color.withValues(alpha: 0.38))
                    .toList(growable: false)
              : fill,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: radius,
        boxShadow: AppShadows.button(AppColors.softShadow(context)),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.onAccent(context),
          disabledForegroundColor: AppColors.onAccent(
            context,
          ).withValues(alpha: 0.7),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: leading == null
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle ?? AppTextStyles.buttonLabel,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  leading!,
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle ?? AppTextStyles.buttonLabel,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final double height;

  const AppSecondaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.softSurfaceGradient(context),
        ),
        borderRadius: radius,
        border: Border.all(color: AppColors.accent(context).withValues(alpha: 0.4)),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentStrong(context),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: Text(label, style: AppTextStyles.buttonLabel),
      ),
    );
  }
}
