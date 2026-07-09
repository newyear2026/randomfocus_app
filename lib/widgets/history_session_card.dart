import 'package:flutter/material.dart';

import '../models/timer_history.dart';
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
    final accent = isCompleted ? Colors.green : Colors.orange;
    final statusLabel = isCompleted ? completedLabel : stoppedLabel;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.pause_circle,
              color: accent.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.formattedTime,
                  style: AppTextStyles.tileTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '$selectedTimeLabel: ${session.selectedTime}m  •  ${session.formattedActualTime} $actualLabel',
                  style: AppTextStyles.tileSubtitle(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accent.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
