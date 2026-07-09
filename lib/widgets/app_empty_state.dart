import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_action_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenHorizontal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.iconBadgeBackground(context),
                ),
                shape: BoxShape.circle,
                boxShadow: AppShadows.iconBadge(
                  Colors.deepPurple.withValues(alpha: 0.18),
                ),
              ),
              child: Icon(icon, size: 40, color: Colors.deepPurple.shade800),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.cardBorder,
                border: Border.all(
                  color: AppColors.subtleBorder(context),
                  width: 1.2,
                ),
                boxShadow: AppShadows.card(AppColors.softShadow(context)),
              ),
              child: Text(
                message,
                style: AppTextStyles.body(context),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                onPressed: onAction,
                label: actionLabel!,
                width: 220,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
