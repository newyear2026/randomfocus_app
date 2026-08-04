import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_info_tile.dart';

class AppBottomSheetOptionTile extends StatelessWidget {
  final String title;
  final bool selected;
  final String subtitle;
  final VoidCallback? onTap;

  const AppBottomSheetOptionTile({
    super.key,
    required this.title,
    required this.selected,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppInfoTile(
      icon: selected ? Icons.radio_button_checked : Icons.radio_button_off,
      title: title,
      subtitle: subtitle,
      trailing: selected
          ? Icon(Icons.check_circle, color: AppColors.accent(context))
          : Icon(
              Icons.chevron_right,
              size: 24,
              color: AppColors.textMuted(context),
            ),
      onTap: onTap,
    );
  }
}
