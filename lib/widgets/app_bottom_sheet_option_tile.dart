import 'package:flutter/material.dart';

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
          ? const Icon(Icons.check_circle, color: Colors.deepPurple)
          : const Icon(Icons.chevron_right, size: 28),
      onTap: onTap,
    );
  }
}
