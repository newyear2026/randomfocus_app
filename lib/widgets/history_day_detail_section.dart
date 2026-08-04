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

  /// 바깥이 이미 스크롤 뷰인 경우 true. 이때는 남은 높이를 채우지 않고
  /// 내용 높이만큼만 차지한다.
  final bool shrinkWrap;

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
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (hasTitle) ...[
          Text(
            title!,
            style: AppTextStyles.sectionTitle(context).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
        ],
        Text(selectedDateLabel, style: AppTextStyles.tileSubtitle(context)),
        const SizedBox(height: 12),
        if (shrinkWrap)
          _buildContent(context, shrinkWrapped: true)
        else
          Expanded(child: _buildContent(context, shrinkWrapped: false)),
      ],
    );
  }

  Widget _buildContent(BuildContext context, {required bool shrinkWrapped}) {
    if (sessions.isEmpty) {
      final empty = AppEmptyState(
        icon: Icons.event_busy,
        title: emptyTitle,
        message: emptyMessage,
      );

      if (shrinkWrapped) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: empty,
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: empty,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: shrinkWrapped,
      physics: shrinkWrapped ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.zero,
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => HistorySessionCard(
        session: sessions[index],
        actualLabel: actualLabel,
        completedLabel: completedLabel,
        stoppedLabel: stoppedLabel,
        selectedTimeLabel: selectedTimeLabel,
      ),
    );
  }
}
