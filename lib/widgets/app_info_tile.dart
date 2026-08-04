import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_section_card.dart';

class AppInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// 여러 타일을 하나의 카드 안에 구분선으로 묶을 때 사용한다.
  /// 이 경우 타일이 자체 카드 배경과 여백을 갖지 않는다.
  final bool grouped;

  const AppInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.grouped = false,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      contentPadding: AppSpacing.tileContent,
      leading: _InfoTileIcon(icon: icon),
      title: Text(title, style: AppTextStyles.tileTitle(context)),
      subtitle: Text(subtitle, style: AppTextStyles.tileSubtitle(context)),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            size: 24,
            color: AppColors.textMuted(context),
          ),
      minVerticalPadding: 12,
      onTap: onTap,
    );

    if (grouped) return tile;

    return AppSectionCard(
      margin: AppSpacing.tileMargin,
      padding: EdgeInsets.zero,
      radius: AppRadius.tile,
      child: tile,
    );
  }
}

class _InfoTileIcon extends StatelessWidget {
  final IconData icon;

  const _InfoTileIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Icon(icon, size: 22, color: AppColors.accentStrong(context)),
    );
  }
}
