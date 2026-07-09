enum SessionStatus { completed, stopped }

class TimerHistory {
  final String sessionId;
  final DateTime dateTime;
  final int selectedTime; // 선택된 시간 (분)
  final int actualTime; // 실제 진행된 시간 (초)
  final SessionStatus status;
  final String? notes;

  TimerHistory({
    required this.sessionId,
    required this.dateTime,
    required this.selectedTime,
    required this.actualTime,
    required this.status,
    this.notes,
  });

  // 하위 호환성을 위한 생성자
  TimerHistory.fromLegacy({
    required String id,
    required int focusMinutes,
    required DateTime completedAt,
  }) : sessionId = id,
       dateTime = completedAt,
       selectedTime = focusMinutes,
       actualTime = focusMinutes * 60, // 기본값: 선택된 시간과 동일
       status = SessionStatus.completed,
       notes = null;

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'dateTime': dateTime.toIso8601String(),
      'selectedTime': selectedTime,
      'actualTime': actualTime,
      'status': status.name,
      'notes': notes,
    };
  }

  /// selectedTime을 분 단위로 정규화한다.
  ///
  /// 과거 버전에서는 selectedTime에 초 단위 값(예: 25분 -> 1500)이
  /// 잘못 저장되었다. 분 옵션의 최대값은 90인 반면 초 값은 최소 1500이므로
  /// 300 이상이면 초 단위로 잘못 저장된 데이터로 보고 분으로 변환한다.
  static const int _secondsThreshold = 300;

  static int normalizeSelectedMinutes(int rawSelectedTime) {
    if (rawSelectedTime >= _secondsThreshold) {
      return rawSelectedTime ~/ 60;
    }
    return rawSelectedTime;
  }

  // JSON에서 생성
  factory TimerHistory.fromJson(Map<String, dynamic> json) {
    // 하위 호환성: 기존 형식 지원
    if (json.containsKey('id') && json.containsKey('focusMinutes')) {
      return TimerHistory.fromLegacy(
        id: json['id'] as String,
        focusMinutes: json['focusMinutes'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
    }

    final selectedMinutes = normalizeSelectedMinutes(json['selectedTime'] as int);

    return TimerHistory(
      sessionId: json['sessionId'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      selectedTime: selectedMinutes,
      actualTime: json['actualTime'] as int? ?? selectedMinutes * 60,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.completed,
      ),
      notes: json['notes'] as String?,
    );
  }

  // 실제 진행 시간을 분:초 형식으로 반환
  String get formattedActualTime {
    final minutes = actualTime ~/ 60;
    final seconds = actualTime % 60;
    return '${minutes}m ${seconds}s';
  }

  // 선택된 시간을 분 형식으로 반환
  String get formattedSelectedTime => '${selectedTime}m';

  // 날짜 포맷팅
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final historyDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (historyDate == today) {
      return 'Today';
    } else if (historyDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  // 시간 포맷팅
  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
