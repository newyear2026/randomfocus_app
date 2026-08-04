import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/history_service.dart';
import '../models/timer_history.dart';
import '../services/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_state.dart';
import '../widgets/app_loading_view.dart';
import '../widgets/app_screen.dart';
import '../widgets/app_section_card.dart';
import '../widgets/app_stat_tile.dart';
import '../widgets/history_day_detail_section.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  /// 캘린더 한 행의 높이. 접근성 가이드의 최소 터치 타겟 48을 만족한다.
  static const double _calendarRowHeight = 48;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, List<TimerHistory>> _groupedHistories = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final grouped = await HistoryService.getHistoriesByDate();

      if (mounted) {
        setState(() {
          _groupedHistories = grouped;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// 외부에서 호출할 수 있는 새로고침 메서드
  void refresh() {
    _loadHistories();
  }

  /// 날짜 키 생성 (yyyy-MM-dd)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 특정 날짜의 세션 목록 가져오기
  List<TimerHistory> _getSessionsForDay(DateTime day) {
    final dateKey = _getDateKey(day);
    return _groupedHistories[dateKey] ?? [];
  }

  /// 월간 통계 계산
  Map<String, dynamic> _getMonthlyStats(DateTime monthBase) {
    final firstDayOfMonth = DateTime(monthBase.year, monthBase.month, 1);
    final lastDayOfMonth = DateTime(monthBase.year, monthBase.month + 1, 0);

    int totalSessions = 0;
    int totalSeconds = 0;
    int completedSessions = 0;

    for (
      var date = firstDayOfMonth;
      date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      final dateKey = _getDateKey(date);
      final sessions = _groupedHistories[dateKey] ?? [];
      totalSessions += sessions.length;
      completedSessions += sessions
          .where((s) => s.status == SessionStatus.completed)
          .length;
      totalSeconds += sessions.fold<int>(
        0,
        (sum, session) => sum + session.actualTime,
      );
    }

    final totalMinutes = (totalSeconds / 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'totalHours': hours,
      'totalMinutes': minutes,
    };
  }

  /// 일별 세션 수 계산
  int _getDailySessions(DateTime day) {
    final sessions = _getSessionsForDay(day);
    return sessions.length;
  }

  /// 일별 focused 시간 계산
  Map<String, int> _getDailyFocusedTime(DateTime day) {
    final sessions = _getSessionsForDay(day);
    final totalSeconds = sessions.fold<int>(
      0,
      (sum, session) => sum + session.actualTime,
    );
    final totalMinutes = (totalSeconds / 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return {'hours': hours, 'minutes': minutes};
  }

  /// 그날 완료한 집중 시간을 0~1 강도로 환산한다.
  ///
  /// 캘린더 마커의 진하기로 쓰이며, 색 하나만으로 "기록 있음/없음"을
  /// 전달하던 기존 방식보다 한 달치 패턴을 읽기 쉽게 만든다.
  double _dailyIntensity(DateTime day) {
    final completedSeconds = _getSessionsForDay(day)
        .where((session) => session.status == SessionStatus.completed)
        .fold<int>(0, (sum, session) => sum + session.actualTime);
    if (completedSeconds <= 0) return 0;

    // 90분을 하루 최대 집중량으로 보고 정규화한다.
    const fullDaySeconds = 90 * 60;
    return (completedSeconds / fullDaySeconds).clamp(0.25, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final monthlyStats = _getMonthlyStats(_focusedDay);
    final dailySessions = _getDailySessions(_selectedDay);
    final dailyFocused = _getDailyFocusedTime(_selectedDay);

    final l10n = AppLocalizations.of(context);

    return AppScreen(
      titleText: l10n?.history ?? 'History',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadHistories,
          tooltip: l10n?.refreshHistory ?? 'Refresh history',
        ),
      ],
      body: _isLoading
          ? AppLoadingView(message: l10n?.translate('loading') ?? 'Loading...')
          : _errorMessage != null
          ? AppErrorState(
              title: l10n?.history ?? 'History',
              message: _errorMessage!,
              actionLabel: l10n?.refresh ?? 'Refresh',
              onAction: _loadHistories,
            )
          : _groupedHistories.isEmpty
          ? AppEmptyState(
              icon: Icons.history_toggle_off,
              title: l10n?.noHistoryYet ?? 'No history yet',
              message:
                  l10n?.completeSessionToSee ??
                  'Complete a focus session to view it here.',
              actionLabel: l10n?.refresh ?? 'Refresh',
              onAction: _loadHistories,
            )
          // 화면을 고정 비율로 3등분하면 캘린더 셀이 최소 터치 타겟보다
          // 작아진다. 대신 페이지 전체를 스크롤 가능하게 두고 캘린더에는
          // 항상 충분한 행 높이를 준다.
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              children: [
                AppSectionCard(
                  radius: AppRadius.cardLarge,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildCalendar(context),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSectionCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 76,
                        child: Row(
                          children: [
                            Expanded(
                              child: AppStatTile(
                                label: l10n?.monthlySessions ?? 'Monthly',
                                value: '${monthlyStats['totalSessions']}',
                                icon: Icons.calendar_month,
                              ),
                            ),
                            _buildDivider(context),
                            Expanded(
                              child: AppStatTile(
                                label: l10n?.dailySessions ?? 'Today',
                                value: '$dailySessions',
                                icon: Icons.today,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Divider(color: AppColors.subtleBorder(context)),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 76,
                        child: Row(
                          children: [
                            Expanded(
                              child: AppStatTile(
                                label: l10n?.monthlyFocused ?? 'Monthly Focused',
                                value: monthlyStats['totalHours'] > 0
                                    ? '${monthlyStats['totalHours']}h ${monthlyStats['totalMinutes']}m'
                                    : '${monthlyStats['totalMinutes']}m',
                                icon: Icons.timer_outlined,
                              ),
                            ),
                            _buildDivider(context),
                            Expanded(
                              child: AppStatTile(
                                label: l10n?.dailyFocused ?? 'Today Focused',
                                value: dailyFocused['hours']! > 0
                                    ? '${dailyFocused['hours']}h ${dailyFocused['minutes']}m'
                                    : '${dailyFocused['minutes']}m',
                                icon: Icons.access_time,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppSectionCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _buildSelectedDaySection(context),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final accent = AppColors.accent(context);

    return TableCalendar<TimerHistory>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      eventLoader: (day) {
        final dateKey = _getDateKey(day);
        final histories = _groupedHistories[dateKey] ?? [];
        // 완료된 세션이 있는 날짜에만 마커 표시
        return histories
            .where((h) => h.status == SessionStatus.completed)
            .toList();
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      sixWeekMonthsEnforced: true,
      // 최소 터치 타겟 48을 만족하는 행 높이.
      rowHeight: _calendarRowHeight,
      daysOfWeekHeight: 28,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return const SizedBox.shrink();

          // 마커의 진하기로 그날의 집중량을 함께 전달한다.
          final intensity = _dailyIntensity(date);
          return Positioned(
            bottom: 6,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: intensity),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: AppTextStyles.statValue(context),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: AppColors.textSecondary(context),
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary(context),
        ),
        headerPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTextStyles.statLabel(context),
        weekendStyle: AppTextStyles.statLabel(context),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        cellMargin: const EdgeInsets.all(4),
        weekendTextStyle: TextStyle(
          color: AppColors.textMuted(context),
          fontSize: 14,
        ),
        defaultTextStyle: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 14,
        ),
        selectedDecoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(12),
        ),
        selectedTextStyle: TextStyle(
          color: AppColors.onAccent(context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        todayDecoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        todayTextStyle: TextStyle(
          color: AppColors.accentStrong(context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        markersMaxCount: 1,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.subtleBorder(context),
    );
  }

  Widget _buildSelectedDaySection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessions = _getSessionsForDay(_selectedDay);

    return HistoryDayDetailSection(
      shrinkWrap: true,
      selectedDateLabel: _getDateKey(_selectedDay),
      sessions: sessions,
      emptyTitle: l10n?.noSessionsOnThisDay ?? 'No sessions for this day',
      emptyMessage:
          l10n?.selectAnotherDate ?? 'Choose another date to view sessions.',
      actualLabel: l10n?.actual ?? 'Actual',
      completedLabel: l10n?.completed ?? 'Completed',
      stoppedLabel: l10n?.stopped ?? 'Stopped',
      selectedTimeLabel: l10n?.selectedTime ?? 'Selected time',
    );
  }
}
