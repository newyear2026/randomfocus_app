import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class AppSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Gradient? gradient;
  final double radius;

  const AppSectionCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.margin = EdgeInsets.zero,
    this.gradient,
    this.radius = AppRadius.card,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.surface(context) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.subtleBorder(context)),
        boxShadow: AppShadows.card(AppColors.softShadow(context)),
      ),
      child: child,
    );
  }
}
