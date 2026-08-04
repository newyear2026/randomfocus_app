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
        final timerSize = isTablet
            ? 360.0
            : constraints.maxWidth.clamp(240.0, 300.0);
        final clampedProgress = progress.clamp(0.0, 1.0);
        final percentLabel = '${(clampedProgress * 100).round()}%';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Semantics(
                  label: progressSemanticsLabel,
                  value: percentLabel,
                  child: SizedBox(
                    width: timerSize,
                    height: timerSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 진행 링은 실제 경과 비율만 표시한다. 안쪽에 별도의
                        // 원판을 두지 않아야 가운데 숫자가 주인공이 된다.
                        SizedBox(
                          width: timerSize,
                          height: timerSize,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: clampedProgress,
                            ),
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                            builder: (context, value, _) =>
                                CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 9,
                                  backgroundColor: stateColor.withValues(
                                    alpha: 0.14,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    stateColor,
                                  ),
                                  strokeCap: StrokeCap.round,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(36),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                stateLabel,
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
                                  style: AppTextStyles.timerDisplay(context)
                                      .copyWith(
                                        fontSize: isTablet
                                            ? 76
                                            : (compact ? 56 : 64),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 24 : 40),
            if (isRunning)
              AppPrimaryButton(
                width: double.infinity,
                onPressed: onStop,
                label: stopLabel,
              )
            else
              Row(
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
                          border: Border.all(
                            color: AppColors.subtleBorder(context),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onReset,
                            borderRadius: BorderRadius.circular(
                              AppRadius.button,
                            ),
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
              ),
          ],
        );
      },
    );
  }
}
