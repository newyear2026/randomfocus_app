import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/timer_history.dart';
import 'package:my_first_app/services/history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 인덱스가 커질수록 오래된 세션. 0번이 가장 최신이다.
TimerHistory _session(int index) {
  return TimerHistory(
    sessionId: 's$index',
    dateTime: DateTime(2026, 1, 1).subtract(Duration(minutes: index)),
    selectedTime: 25,
    actualTime: 1500,
    status: SessionStatus.completed,
  );
}

void _seedStoredSessions(int count) {
  final seeded = [for (var i = 0; i < count; i += 1) _session(i).toJson()];
  SharedPreferences.setMockInitialValues({'timer_history': jsonEncode(seeded)});
}

void main() {
  test('a fresh install keeps every session it is given', () async {
    SharedPreferences.setMockInitialValues({});

    await HistoryService.saveHistory(_session(2));
    await HistoryService.saveHistory(_session(1));

    final histories = await HistoryService.getHistories();
    expect(histories.map((h) => h.sessionId), ['s1', 's2']);
  });

  test(
    'storing past the cap drops the oldest session, not the newest',
    () async {
      _seedStoredSessions(HistoryService.maxStoredSessions);
      final oldest = 's${HistoryService.maxStoredSessions - 1}';

      // 저장된 모든 세션보다 최신인 기록을 하나 더 넣는다.
      await HistoryService.saveHistory(_session(-1));

      final histories = await HistoryService.getHistories();
      final ids = histories.map((h) => h.sessionId).toList();

      expect(histories, hasLength(HistoryService.maxStoredSessions));
      expect(ids.first, 's-1');
      expect(ids, isNot(contains(oldest)));
      expect(ids, contains('s${HistoryService.maxStoredSessions - 2}'));
    },
  );

  test('a late session is ranked by its timestamp, not by insertion', () async {
    _seedStoredSessions(3);

    // 중단 세션이 뒤늦게 저장되는 경우. 시각으로는 s1과 s2 사이에 들어간다.
    final late = TimerHistory(
      sessionId: 'late',
      dateTime: DateTime(2026, 1, 1).subtract(const Duration(seconds: 90)),
      selectedTime: 25,
      actualTime: 90,
      status: SessionStatus.stopped,
    );
    await HistoryService.saveHistory(late);

    final histories = await HistoryService.getHistories();
    expect(histories.map((h) => h.sessionId), ['s0', 's1', 'late', 's2']);
  });
}
