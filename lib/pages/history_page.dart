import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/history_service.dart';
import '../models/timer_history.dart';
import '../services/app_localizations.dart';
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
          icon: const Icon(Icons.refresh, color: Colors.white),
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
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: AppSectionCard(
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    radius: 20,
                    padding: const EdgeInsets.all(0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compactCalendar = constraints.maxHeight < 210;
                        final headerVerticalPadding = compactCalendar
                            ? 4.0
                            : 8.0;
                        final daysOfWeekHeight = compactCalendar ? 22.0 : 32.0;
                        final headerHeight =
                            (compactCalendar ? 24.0 : 28.0) +
                            (headerVerticalPadding * 2);
                        final availableRowsHeight =
                            constraints.maxHeight -
                            headerHeight -
                            daysOfWeekHeight;
                        final rowHeight = (availableRowsHeight / 6).clamp(
                          18.0,
                          compactCalendar ? 28.0 : 36.0,
                        );
                        final chevronSize = compactCalendar ? 18.0 : 20.0;
                        final titleStyle = AppTextStyles.statValue(
                          context,
                        ).copyWith(fontSize: compactCalendar ? 14 : 16);

                        return TableCalendar<TimerHistory>(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          calendarFormat: _calendarFormat,
                          eventLoader: (day) {
                            final dateKey = _getDateKey(day);
                            final histories = _groupedHistories[dateKey] ?? [];
                            // 완료된 세션이 있는 날짜에만 마커 표시
                            return histories
                                .where(
                                  (h) => h.status == SessionStatus.completed,
                                )
                                .toList();
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          sixWeekMonthsEnforced: true,
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (events.isNotEmpty) {
                                return Positioned(
                                  bottom: 2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade400,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: titleStyle,
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: Colors.deepPurple.shade700,
                              size: chevronSize,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: Colors.deepPurple.shade700,
                              size: chevronSize,
                            ),
                            headerPadding: EdgeInsets.symmetric(
                              vertical: headerVerticalPadding,
                            ),
                            leftChevronPadding: EdgeInsets.zero,
                            rightChevronPadding: EdgeInsets.zero,
                          ),
                          rowHeight: rowHeight,
                          daysOfWeekHeight: daysOfWeekHeight,
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: compactCalendar ? 11 : 12,
                            ),
                            weekendStyle: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: compactCalendar ? 11 : 12,
                            ),
                          ),
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            weekendTextStyle: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontSize: compactCalendar ? 12 : 13,
                            ),
                            defaultTextStyle: TextStyle(
                              color: Colors.deepPurple.shade800,
                              fontSize: compactCalendar ? 12 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.deepPurple.shade100,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: Colors.deepPurple.shade400,
                              shape: BoxShape.circle,
                            ),
                            markersMaxCount: 1,
                            markerSize: compactCalendar ? 5 : 6,
                            markerMargin: const EdgeInsets.only(bottom: 1),
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
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: AppSectionCard(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepPurple.shade50,
                        Colors.purple.shade50,
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Expanded(
                                child: AppStatTile(
                                  label: l10n?.monthlySessions ?? 'Monthly',
                                  value: '${monthlyStats['totalSessions']}',
                                  icon: Icons.calendar_month,
                                ),
                              ),
                              _buildDivider(),
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
                        const SizedBox(height: 4),
                        Divider(
                          color: Colors.deepPurple.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Row(
                            children: [
                              Expanded(
                                child: AppStatTile(
                                  label:
                                      l10n?.monthlyFocused ?? 'Monthly Focused',
                                  value: monthlyStats['totalHours'] > 0
                                      ? '${monthlyStats['totalHours']}h ${monthlyStats['totalMinutes']}m'
                                      : '${monthlyStats['totalMinutes']}m',
                                  icon: Icons.timer_outlined,
                                ),
                              ),
                              _buildDivider(),
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
                ),
                Expanded(
                  flex: 5,
                  child: AppSectionCard(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    padding: const EdgeInsets.all(16),
                    child: _buildSelectedDaySection(context),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.deepPurple.withValues(alpha: 0.2),
    );
  }

  Widget _buildSelectedDaySection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessions = _getSessionsForDay(_selectedDay);

    return HistoryDayDetailSection(
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
