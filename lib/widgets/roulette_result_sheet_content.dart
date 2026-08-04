import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';
import 'app_action_button.dart';

class RouletteResultSheetContent extends StatelessWidget {
  final int selectedMinutes;
  final Color accentColor;
  final String minutesLabel;
  final String spinAgainLabel;
  final String startLabel;
  final VoidCallback? onSpinAgain;
  final VoidCallback? onStart;

  const RouletteResultSheetContent({
    super.key,
    required this.selectedMinutes,
    required this.accentColor,
    required this.minutesLabel,
    required this.spinAgainLabel,
    required this.startLabel,
    this.onSpinAgain,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.statusFill(context, accentColor),
            borderRadius: BorderRadius.circular(AppRadius.cardLarge),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              Text(
                '$selectedMinutes',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                minutesLabel,
                style: AppTextStyles.body(
                  context,
                ).copyWith(fontSize: 16, letterSpacing: 0.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                onPressed: onSpinAgain,
                label: spinAgainLabel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppPrimaryButton(
                onPressed: onStart,
                label: startLabel,
                height: 52,
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
