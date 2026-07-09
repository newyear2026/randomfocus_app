import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.2),
                accentColor.withValues(alpha: 0.12),
                accentColor.withValues(alpha: 0.08),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.5),
              width: 3,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$selectedMinutes',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                  letterSpacing: 2.0,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                minutesLabel,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
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
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
