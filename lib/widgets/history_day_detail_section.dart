import 'package:flutter/material.dart';

import '../models/timer_history.dart';
import '../theme/app_text_styles.dart';
import 'app_empty_state.dart';
import 'history_session_card.dart';

class HistoryDayDetailSection extends StatelessWidget {
  final String? title;
  final String selectedDateLabel;
  final List<TimerHistory> sessions;
  final String emptyTitle;
  final String emptyMessage;
  final String actualLabel;
  final String completedLabel;
  final String stoppedLabel;
  final String selectedTimeLabel;

  const HistoryDayDetailSection({
    super.key,
    this.title,
    required this.selectedDateLabel,
    required this.sessions,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.actualLabel,
    required this.completedLabel,
    required this.stoppedLabel,
    this.selectedTimeLabel = 'Selected time',
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle) ...[
          Text(
            title!,
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 18,
              color: Colors.deepPurple.shade900,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(selectedDateLabel, style: AppTextStyles.tileSubtitle(context)),
        const SizedBox(height: 12),
        Expanded(
          child: sessions.isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: AppEmptyState(
                        icon: Icons.event_busy,
                        title: emptyTitle,
                        message: emptyMessage,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => HistorySessionCard(
                    session: sessions[index],
                    actualLabel: actualLabel,
                    completedLabel: completedLabel,
                    stoppedLabel: stoppedLabel,
                    selectedTimeLabel: selectedTimeLabel,
                  ),
                ),
        ),
      ],
    );
  }
}
