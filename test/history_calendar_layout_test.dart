import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/timer_history.dart';
import 'package:my_first_app/pages/history_page.dart';
import 'package:my_first_app/services/app_localizations.dart';
import 'package:my_first_app/theme/app_text_styles.dart';
import 'package:my_first_app/widgets/banner_ad_widget.dart';
import 'package:my_first_app/widgets/app_section_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  testWidgets('history calendar fits six-week months in compact height', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 740));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 176,
            child: AppSectionCard(
              margin: EdgeInsets.zero,
              radius: 20,
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compactCalendar = constraints.maxHeight < 210;
                  final headerVerticalPadding = compactCalendar ? 4.0 : 8.0;
                  final daysOfWeekHeight = compactCalendar ? 22.0 : 32.0;
                  final headerHeight =
                      (compactCalendar ? 24.0 : 28.0) +
                      (headerVerticalPadding * 2);
                  final availableRowsHeight =
                      constraints.maxHeight - headerHeight - daysOfWeekHeight;
                  final rowHeight = (availableRowsHeight / 6).clamp(
                    18.0,
                    compactCalendar ? 28.0 : 36.0,
                  );
                  final chevronSize = compactCalendar ? 18.0 : 20.0;
                  final titleStyle = AppTextStyles.statValue(
                    context,
                  ).copyWith(fontSize: compactCalendar ? 14 : 16);

                  return TableCalendar<void>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: DateTime.utc(2026, 8, 1),
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    sixWeekMonthsEnforced: true,
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
                      markersMaxCount: 1,
                      markerSize: compactCalendar ? 5 : 6,
                      markerMargin: const EdgeInsets.only(bottom: 1),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('August 2026'), findsOneWidget);
  });

  testWidgets('history page uses three content layers without banner ad', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'timer_history': jsonEncode([
        TimerHistory(
          sessionId: 'session-1',
          dateTime: DateTime(2026, 7, 8, 15, 25),
          selectedTime: 90,
          actualTime: 3,
          status: SessionStatus.stopped,
        ).toJson(),
      ]),
    });

    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en'), Locale('es'), Locale('zh')],
        home: HistoryPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BannerAdWidget), findsNothing);
    expect(find.byType(AppSectionCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
