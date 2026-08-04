import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppFormSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AppFormSectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.groupLabel(context)),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(subtitle!, style: AppTextStyles.tileSubtitle(context)),
          ],
        ],
      ),
    );
  }
}
