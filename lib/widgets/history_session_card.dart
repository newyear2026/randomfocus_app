import 'package:flutter/material.dart';

import '../models/timer_history.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class HistorySessionCard extends StatelessWidget {
  final TimerHistory session;
  final String actualLabel;
  final String completedLabel;
  final String stoppedLabel;
  final String selectedTimeLabel;

  const HistorySessionCard({
    super.key,
    required this.session,
    this.actualLabel = 'Actual',
    this.completedLabel = 'Completed',
    this.stoppedLabel = 'Stopped',
    this.selectedTimeLabel = 'Selected time',
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == SessionStatus.completed;
    // 상태 색은 룰렛 세그먼트 색과 겹치지 않도록 전용 상태 토큰을 쓴다.
    final accent = isCompleted
        ? AppColors.statusSuccess(context)
        : AppColors.statusWarning(context);
    final statusLabel = isCompleted ? completedLabel : stoppedLabel;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.tile),
        border: Border.all(color: AppColors.subtleBorder(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.statusFill(context, accent),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.pause_circle,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.formattedTime,
                  style: AppTextStyles.tileTitle(context),
                ),
                const SizedBox(height: 2),
                // 한 줄로 이어 붙이면 큰 글꼴에서 구절 중간이 끊겨 읽힌다.
                // 각 값을 자기 완결적인 줄로 분리한다.
                Text(
                  '$selectedTimeLabel ${session.selectedTime}m',
                  style: AppTextStyles.tileSubtitle(context),
                ),
                Text(
                  '$actualLabel ${session.formattedActualTime}',
                  style: AppTextStyles.tileSubtitle(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.statusFill(context, accent),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
