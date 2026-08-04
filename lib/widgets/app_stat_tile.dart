import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const AppStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 96;
        final badgeSize = compact ? 30.0 : 36.0;
        final iconSize = compact ? 16.0 : 19.0;
        final valueStyle = AppTextStyles.statValue(
          context,
        ).copyWith(fontSize: compact ? 15 : 17);

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: badgeSize,
                    height: badgeSize,
                    decoration: BoxDecoration(
                      color: AppColors.accent(context).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.accentStrong(context),
                      size: iconSize,
                    ),
                  ),
                  SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.xs),
                  Text(
                    value,
                    style: valueStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: AppTextStyles.statLabel(context),
                    textAlign: TextAlign.center,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
