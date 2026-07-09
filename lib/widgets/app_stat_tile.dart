import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
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
        final badgePadding = compact ? 6.0 : AppSpacing.sm;
        final innerPadding = compact ? 4.0 : AppSpacing.sm - 2;
        final iconSize = compact ? 16.0 : 20.0;
        final valueStyle = AppTextStyles.statValue(
          context,
        ).copyWith(fontSize: compact ? 14 : 16);

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(badgePadding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.iconBadgeBackground(context),
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.statBadge(
                        Colors.deepPurple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.iconBadgeForeground(context),
                        ),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(innerPadding),
                      child: Icon(icon, color: Colors.white, size: iconSize),
                    ),
                  ),
                  SizedBox(height: compact ? 2 : AppSpacing.xs),
                  Text(
                    value,
                    style: valueStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: compact ? 1 : AppSpacing.xxs),
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
