import 'package:shared_preferences/shared_preferences.dart';

class SpinStorage {
  static const String _keySpinDate = 'spin_date';
  static const String _keySpinUsed = 'spin_used';
  static const int _maxSpinsPerDay = 2;

  /// 현재 로컬 타임존 기준 오늘 날짜를 "yyyy-MM-dd" 형식으로 반환
  /// 타임존 문제를 방지하기 위해 로컬 시간 기준으로 날짜만 추출
  static String _getTodayDateString() {
    final now = DateTime.now(); // 로컬 타임존 기준
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 날짜 문자열을 비교하여 같은 날인지 확인
  /// 타임존에 관계없이 날짜만 비교
  static bool _isSameDay(String date1, String date2) {
    return date1 == date2;
  }

  /// 저장된 날짜와 사용된 스핀 수를 가져옴
  /// 날짜가 오늘이 아니면 자동으로 2회로 리셋
  static Future<Map<String, dynamic>> getSpinData() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    final savedDateStr = prefs.getString(_keySpinDate);
    final usedSpins = prefs.getInt(_keySpinUsed) ?? 0;

    // 저장된 날짜가 없거나 오늘이 아니면 자정이 지난 것으로 간주하여 리셋
    if (savedDateStr == null || !_isSameDay(savedDateStr, todayStr)) {
      // 자정 리셋: 2회로 초기화
      await prefs.setString(_keySpinDate, todayStr);
      await prefs.setInt(_keySpinUsed, 0);
      return {
        'used': 0,
        'remaining': _maxSpinsPerDay,
        'maxSpins': _maxSpinsPerDay,
        'isReset': true,
      };
    }

    return {
      'used': usedSpins,
      'remaining': _maxSpinsPerDay - usedSpins,
      'maxSpins': _maxSpinsPerDay,
      'isReset': false,
    };
  }

  /// 스핀 사용 처리 (1회 차감)
  /// 날짜가 바뀌었으면 자동으로 리셋 후 1회 차감
  static Future<Map<String, dynamic>> useSpin() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    final savedDateStr = prefs.getString(_keySpinDate);
    var usedSpins = prefs.getInt(_keySpinUsed) ?? 0;

    // 날짜가 바뀌었으면 리셋
    if (savedDateStr == null || !_isSameDay(savedDateStr, todayStr)) {
      usedSpins = 0;
      await prefs.setString(_keySpinDate, todayStr);
    }

    // 스핀 사용 (1회 차감)
    usedSpins++;

    // 최대값 제한 (안전장치)
    if (usedSpins > _maxSpinsPerDay) {
      usedSpins = _maxSpinsPerDay;
    }

    await prefs.setInt(_keySpinUsed, usedSpins);

    return {
      'used': usedSpins,
      'remaining': _maxSpinsPerDay - usedSpins,
      'maxSpins': _maxSpinsPerDay,
    };
  }

  /// 스핀 사용 취소 (Spin Again 시 사용)
  static Future<void> cancelSpin() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    final savedDateStr = prefs.getString(_keySpinDate);
    var usedSpins = prefs.getInt(_keySpinUsed) ?? 0;

    // 날짜가 바었으면 취소할 필요 없음 (이미 리셋됨)
    if (savedDateStr != null && _isSameDay(savedDateStr, todayStr)) {
      usedSpins = (usedSpins - 1).clamp(0, _maxSpinsPerDay);
      await prefs.setInt(_keySpinUsed, usedSpins);
    }
  }

  /// 스핀 사용 횟수를 직접 설정 (테스트용)
  static Future<void> setSpinUsed(int value) async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    await prefs.setString(_keySpinDate, todayStr);
    await prefs.setInt(_keySpinUsed, value.clamp(0, _maxSpinsPerDay));
  }

  /// 스핀 데이터를 수동으로 리셋 (테스트용)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySpinDate);
    await prefs.remove(_keySpinUsed);
  }

  /// 현재 날짜가 저장된 날짜와 다른지 확인 (자정 체크용)
  static Future<bool> isDateChanged() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    final savedDateStr = prefs.getString(_keySpinDate);

    if (savedDateStr == null) return true;
    return !_isSameDay(savedDateStr, todayStr);
  }
}
