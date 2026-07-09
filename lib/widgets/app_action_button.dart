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

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryActionGradient(context),
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: radius,
        boxShadow: AppShadows.button(Colors.deepPurple.withValues(alpha: 0.35)),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
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
        border: Border.all(
          color: Colors.deepPurple.withValues(alpha: 0.25),
          width: 2,
        ),
        boxShadow: AppShadows.iconBadge(
          Colors.deepPurple.withValues(alpha: 0.12),
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.deepPurple.shade800,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
