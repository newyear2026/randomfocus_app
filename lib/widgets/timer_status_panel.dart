import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';
import 'app_action_button.dart';

class TimerStatusPanel extends StatelessWidget {
  final Color stateColor;
  final String stateLabel;
  final String timeLabel;
  final String statusLabel;
  final bool isRunning;

  /// 0.0 ~ 1.0. 현재 구간에서 실제로 지난 비율이며 진행 링을 이 값으로 채운다.
  final double progress;

  final String startLabel;
  final String stopLabel;
  final String resetLabel;
  final String progressSemanticsLabel;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onReset;

  const TimerStatusPanel({
    super.key,
    required this.stateColor,
    required this.stateLabel,
    required this.timeLabel,
    required this.statusLabel,
    required this.isRunning,
    required this.progress,
    required this.startLabel,
    required this.stopLabel,
    required this.resetLabel,
    this.progressSemanticsLabel = 'Focus progress',
    this.onStart,
    this.onStop,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final compact = constraints.maxHeight < 700;
        final horizontal = isTablet && constraints.maxHeight < 400;
        final timerSize = horizontal
            ? math.min(300.0, math.max(200.0, constraints.maxHeight))
            : math.min(
                constraints.maxWidth,
                isTablet ? 360.0 : constraints.maxWidth.clamp(240.0, 300.0),
              );
        final gap = compact ? 24.0 : 40.0;
        final minimumHeight = horizontal ? timerSize : timerSize + gap + 60;
        final height = math.max(constraints.maxHeight, minimumHeight);
        final dial = _buildDial(context, timerSize, isTablet, compact);
        final actions = _buildActions(context);

        // Keep the dial square. A short viewport must scroll instead of
        // squeezing the circle and painting its labels over the controls.
        return SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: horizontal
                ? Row(
                    children: [
                      Expanded(child: Center(child: dial)),
                      const SizedBox(width: 24),
                      Expanded(child: Center(child: actions)),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(child: Center(child: dial)),
                      SizedBox(height: gap),
                      actions,
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDial(
    BuildContext context,
    double timerSize,
    bool isTablet,
    bool compact,
  ) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final padding = timerSize < 280 ? 24.0 : 36.0;
    return Semantics(
      label: progressSemanticsLabel,
      value: '${(clampedProgress * 100).round()}%',
      child: SizedBox.square(
        dimension: timerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: timerSize,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: clampedProgress),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 9,
                  backgroundColor: stateColor.withValues(alpha: 0.14),
                  valueColor: AlwaysStoppedAnimation<Color>(stateColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Center(
                // Only extreme text sizes need this final fit; the enclosing
                // scroll view preserves full-size content in short viewports.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: timerSize - 2 * padding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stateLabel,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.statLabel(context).copyWith(
                            fontSize: compact ? 13 : 14,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(height: compact ? 6 : 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            timeLabel,
                            style: AppTextStyles.timerDisplay(context).copyWith(
                              fontSize: isTablet ? 76 : (compact ? 56 : 64),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 6 : 10),
                        Text(
                          statusLabel,
                          style: AppTextStyles.tileSubtitle(
                            context,
                          ).copyWith(fontSize: compact ? 13 : 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (isRunning) {
      return AppPrimaryButton(
        width: double.infinity,
        onPressed: onStop,
        label: stopLabel,
      );
    }
    return Row(
      children: [
        Expanded(
          child: AppPrimaryButton(
            onPressed: onStart,
            label: startLabel,
            leading: Icon(
              Icons.play_arrow,
              size: 24,
              color: AppColors.onAccent(context),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: resetLabel,
          child: Tooltip(
            message: resetLabel,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.subtleBorder(context)),
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onReset,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  child: Center(
                    child: Icon(
                      Icons.refresh,
                      size: 26,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
