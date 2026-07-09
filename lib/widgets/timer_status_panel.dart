import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_action_button.dart';

class TimerStatusPanel extends StatelessWidget {
  final Color stateColor;
  final String stateLabel;
  final String timeLabel;
  final String statusLabel;
  final bool isRunning;
  final String startLabel;
  final String stopLabel;
  final String resetLabel;
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
    required this.startLabel,
    required this.stopLabel,
    required this.resetLabel,
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
            ? 380.0
            : constraints.maxWidth.clamp(260.0, 320.0);
        final innerSize = timerSize - 40;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: timerSize,
                  height: timerSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: timerSize,
                        height: timerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            startAngle: 0,
                            endAngle: 3.14159 * 2,
                            colors: [
                              stateColor.withValues(alpha: 0.2),
                              stateColor.withValues(alpha: 0.1),
                              stateColor.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                        child: SizedBox(
                          width: timerSize,
                          height: timerSize,
                          child: CircularProgressIndicator(
                            value: isRunning ? 0.55 : 0.0,
                            strokeWidth: 22,
                            backgroundColor: stateColor.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stateColor,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),
                      Container(
                        width: innerSize,
                        height: innerSize,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.grey.shade50,
                              Colors.white,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: stateColor.withValues(alpha: 0.15),
                              blurRadius: 25,
                              spreadRadius: 3,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stateLabel,
                              style: TextStyle(
                                fontSize: isTablet ? 32 : 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: 1.2,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: compact ? 12 : 20),
                            Text(
                              timeLabel,
                              style: AppTextStyles.timerDisplay(context)
                                  .copyWith(
                                    fontSize: isTablet
                                        ? 84
                                        : (compact ? 60 : 72),
                                  ),
                            ),
                            SizedBox(height: compact ? 12 : 20),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: compact ? 16 : 18,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 24 : 60),
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
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 24,
                          color: Colors.white,
                        ),
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
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Colors.grey.shade50],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onReset,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.grey.shade100, Colors.white],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.refresh,
                                  size: 28,
                                  color: Colors.grey.shade800,
                                ),
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
