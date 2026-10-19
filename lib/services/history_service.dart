import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_history.dart';

class HistoryService {
  static const String _keyHistory = 'timer_history';

  /// 저장소에 보관하는 최대 세션 수.
  ///
  /// 전체 목록을 JSON 한 덩어리로 넣는 구조라 저장할 때마다 전부 다시
  /// 직렬화한다. 항목당 약 136바이트이므로 이 값에서 약 270KB가 되는데,
  /// 여기서 더 키우려면 저장소를 데이터베이스로 바꾸는 쪽이 맞다.
  /// 하루 10세션을 쓰는 유저도 6개월 이상, 하루 3세션이면 1년 10개월쯤
  /// 남는다.
  static const int maxStoredSessions = 2000;

  /// 히스토리 저장
  static Future<void> saveHistory(TimerHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final histories = await getHistories();

    histories.add(history);

    // 상한을 넘으면 가장 오래된 기록부터 버린다. 세션은 보통 최신순으로
    // 쌓이지만, 뒤늦게 저장되는 중단 세션이 있어 순서가 어긋날 수 있다.
    // 무엇이 가장 오래된 기록인지는 목록 위치가 아니라 시각이 정해야 한다.
    histories.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (histories.length > maxStoredSessions) {
      histories.removeRange(maxStoredSessions, histories.length);
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
