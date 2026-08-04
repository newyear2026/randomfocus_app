import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_action_button.dart';

class RouletteStatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const RouletteStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceMuted(context),
        border: Border.all(color: AppColors.subtleBorder(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent(
                          context,
                        ).withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        icon,
                        size: 26,
                        color: AppColors.accentStrong(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: AppTextStyles.sectionTitle(
                        context,
                      ).copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: AppTextStyles.body(
                        context,
                      ).copyWith(fontSize: 14, height: 1.45),
                      textAlign: TextAlign.center,
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 170,
                        child: AppSecondaryButton(
                          onPressed: onAction,
                          label: actionLabel!,
                          height: 48,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
