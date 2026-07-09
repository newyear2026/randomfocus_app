import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_section_card.dart';

class AppInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      margin: AppSpacing.tileMargin,
      padding: EdgeInsets.zero,
      radius: AppRadius.tile,
      child: ListTile(
        contentPadding: AppSpacing.tileContent,
        leading: _InfoTileIcon(icon: icon),
        title: Text(title, style: AppTextStyles.tileTitle),
        subtitle: Text(subtitle, style: AppTextStyles.tileSubtitle(context)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 28),
        minVerticalPadding: 12,
        onTap: onTap,
      ),
    );
  }
}

class _InfoTileIcon extends StatelessWidget {
  final IconData icon;

  const _InfoTileIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.iconBadgeBackground(context),
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppRadius.badge),
        boxShadow: AppShadows.iconBadge(
          Colors.deepPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.iconBadgeForeground(context),
          ),
          borderRadius: BorderRadius.circular(AppSpacing.md - 2),
        ),
        padding: const EdgeInsets.all(2),
        child: Icon(icon, size: 26, color: Colors.white),
      ),
    );
  }
}
