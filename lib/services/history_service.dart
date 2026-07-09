import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_history.dart';

class HistoryService {
  static const String _keyHistory = 'timer_history';

  /// 히스토리 저장
  static Future<void> saveHistory(TimerHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final histories = await getHistories();

    // 새로운 히스토리를 맨 앞에 추가 (최신순)
    histories.insert(0, history);

    // 최대 100개까지만 저장
    if (histories.length > 100) {
      histories.removeRange(100, histories.length);
    }

    // JSON으로 변환하여 저장
    final jsonList = histories.map((h) => h.toJson()).toList();
    await prefs.setString(_keyHistory, jsonEncode(jsonList));
  }

  /// 저장소에 초 단위로 잘못 저장된 selectedTime을 분으로 정규화한다.
  ///
  /// 앱 시작 시 1회 호출하면 되며, 변환이 필요한 데이터가 없으면
  /// 저장소를 다시 쓰지 않는다.
  static Future<void> migrateSelectedTimeIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyHistory);

    if (jsonString == null || jsonString.isEmpty) {
      return;
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;

      final needsMigration = jsonList.any((json) {
        if (json is! Map<String, dynamic>) return false;
        final selectedTime = json['selectedTime'];
        return selectedTime is int &&
            selectedTime != TimerHistory.normalizeSelectedMinutes(selectedTime);
      });

      if (!needsMigration) {
        return;
      }

      // fromJson이 정규화를 수행하므로, 파싱 후 다시 저장하면 정상화된다.
      final histories = jsonList
          .map((json) => TimerHistory.fromJson(json as Map<String, dynamic>))
          .toList();
      final normalized = histories.map((h) => h.toJson()).toList();
      await prefs.setString(_keyHistory, jsonEncode(normalized));
    } catch (e) {
      // 마이그레이션 실패 시 조용히 처리 (읽기 시 fromJson이 방어적으로 정규화)
    }
  }

  /// 모든 히스토리 가져오기
  static Future<List<TimerHistory>> getHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyHistory);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => TimerHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 히스토리 삭제
  static Future<void> deleteHistory(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final histories = await getHistories();

    histories.removeWhere((h) => h.sessionId == sessionId);

    final jsonList = histories.map((h) => h.toJson()).toList();
    await prefs.setString(_keyHistory, jsonEncode(jsonList));
  }

  /// 여러 히스토리 삭제
  static Future<void> deleteHistories(List<String> sessionIds) async {
    final prefs = await SharedPreferences.getInstance();
    final histories = await getHistories();

    histories.removeWhere((h) => sessionIds.contains(h.sessionId));

    final jsonList = histories.map((h) => h.toJson()).toList();
    await prefs.setString(_keyHistory, jsonEncode(jsonList));
  }

  /// 모든 히스토리 삭제
  static Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }

  /// 통계 정보 가져오기
  static Future<Map<String, dynamic>> getStatistics() async {
    final histories = await getHistories();

    if (histories.isEmpty) {
      return {
        'totalSessions': 0,
        'totalMinutes': 0,
        'averageMinutes': 0,
        'completedSessions': 0,
        'stoppedSessions': 0,
      };
    }

    final totalSessions = histories.length;
    final completedSessions = histories
        .where((h) => h.status == SessionStatus.completed)
        .length;
    final stoppedSessions = histories
        .where((h) => h.status == SessionStatus.stopped)
        .length;

    // 실제 진행된 시간 기준으로 통계 계산
    final totalSeconds = histories.fold<int>(
      0,
      (sum, history) => sum + history.actualTime,
    );
    final totalMinutes = (totalSeconds / 60).round();
    final averageMinutes = (totalMinutes / totalSessions).round();

    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'averageMinutes': averageMinutes,
      'completedSessions': completedSessions,
      'stoppedSessions': stoppedSessions,
    };
  }

  /// 날짜별로 그룹화된 히스토리 가져오기
  static Future<Map<String, List<TimerHistory>>> getHistoriesByDate() async {
    final histories = await getHistories();
    final Map<String, List<TimerHistory>> grouped = {};

    for (final history in histories) {
      final dateKey = _getDateKey(history.dateTime);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(history);
    }

    return grouped;
  }

  /// 날짜 키 생성 (yyyy-MM-dd)
  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
