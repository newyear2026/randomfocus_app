import 'package:shared_preferences/shared_preferences.dart';

class SpinStorage {
  static const String _keySpinDate = 'spin_date';
  static const String _keySpinUsed = 'spin_used';

  /// 오늘 날짜를 "yyyy-MM-dd" 형식으로 반환
  static String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 저장된 날짜와 사용된 스핀 수를 가져옴
  /// 날짜가 오늘이 아니면 자동으로 리셋
  static Future<Map<String, int>> getSpinData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayDate();
    final savedDate = prefs.getString(_keySpinDate) ?? '';
    final usedSpins = prefs.getInt(_keySpinUsed) ?? 0;

    // 날짜가 오늘이 아니면 리셋
    if (savedDate != today) {
      await prefs.setString(_keySpinDate, today);
      await prefs.setInt(_keySpinUsed, 0);
      return {'used': 0, 'remaining': 2};
    }

    return {'used': usedSpins, 'remaining': 2 - usedSpins};
  }

  /// 사용된 스핀 수를 1 증가시킴
  static Future<void> incrementSpinUsed() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayDate();
    final savedDate = prefs.getString(_keySpinDate) ?? '';
    final usedSpins = prefs.getInt(_keySpinUsed) ?? 0;

    // 날짜가 오늘이 아니면 리셋 후 1로 설정
    if (savedDate != today) {
      await prefs.setString(_keySpinDate, today);
      await prefs.setInt(_keySpinUsed, 1);
    } else {
      // 오늘이면 1 증가 (최대 2)
      await prefs.setInt(_keySpinUsed, (usedSpins + 1).clamp(0, 2));
    }
  }

  /// 스핀 데이터를 수동으로 리셋 (테스트용)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySpinDate);
    await prefs.remove(_keySpinUsed);
  }
}


