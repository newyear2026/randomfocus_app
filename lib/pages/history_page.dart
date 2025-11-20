import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/history_service.dart';
import '../models/timer_history.dart';
import '../services/app_localizations.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, List<TimerHistory>> _groupedHistories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    setState(() {
      _isLoading = true;
    });

    final grouped = await HistoryService.getHistoriesByDate();

    if (mounted) {
      setState(() {
        _groupedHistories = grouped;
        _isLoading = false;
      });
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
  Map<String, dynamic> _getMonthlyStats() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

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
    final monthlyStats = _getMonthlyStats();
    final dailySessions = _getDailySessions(_selectedDay);
    final dailyFocused = _getDailyFocusedTime(_selectedDay);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.purple.shade50,
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade500,
                    Colors.purple.shade400,
                  ],
                ),
              ),
            ),
            title: Text(
              AppLocalizations.of(context)?.history ?? 'History',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadHistories,
                tooltip: AppLocalizations.of(context)?.refresh ?? 'Refresh',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // 캘린더
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.08),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TableCalendar<TimerHistory>(
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
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            weekendTextStyle: TextStyle(
                              color: Colors.deepPurple.shade700,
                            ),
                            selectedDecoration: BoxDecoration(
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
                            markerSize: 8,
                            markerMargin: const EdgeInsets.only(bottom: 2),
                          ),
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
                                          color: Colors.deepPurple.withOpacity(
                                            0.3,
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
                            titleTextStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade700,
                            ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: Colors.deepPurple.shade700,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            weekendStyle: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                        ),
                      ),
                      // 월간 통계 요약
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.deepPurple.shade50,
                              Colors.purple.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 첫 번째 행: 세션 통계
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    context,
                                    AppLocalizations.of(
                                          context,
                                        )?.monthlySessions ??
                                        'Monthly',
                                    '${monthlyStats['totalSessions']}',
                                    Icons.calendar_month,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: Colors.deepPurple.withOpacity(0.2),
                                ),
                                Expanded(
                                  child: _buildStatItem(
                                    context,
                                    AppLocalizations.of(
                                          context,
                                        )?.dailySessions ??
                                        'Today',
                                    '$dailySessions',
                                    Icons.today,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 1,
                              color: Colors.deepPurple.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            // 두 번째 행: Focused 시간 통계
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    context,
                                    AppLocalizations.of(
                                          context,
                                        )?.monthlyFocused ??
                                        'Monthly Focused',
                                    monthlyStats['totalHours'] > 0
                                        ? '${monthlyStats['totalHours']}h ${monthlyStats['totalMinutes']}m'
                                        : '${monthlyStats['totalMinutes']}m',
                                    Icons.timer_outlined,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: Colors.deepPurple.withOpacity(0.2),
                                ),
                                Expanded(
                                  child: _buildStatItem(
                                    context,
                                    AppLocalizations.of(
                                          context,
                                        )?.dailyFocused ??
                                        'Today Focused',
                                    dailyFocused['hours']! > 0
                                        ? '${dailyFocused['hours']}h ${dailyFocused['minutes']}m'
                                        : '${dailyFocused['minutes']}m',
                                    Icons.access_time,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.deepPurple.shade700, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade700,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.deepPurple.shade600,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
