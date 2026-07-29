/// 배너 광고 재시도 간격과 중복 예약을 관리한다.
///
/// 하나의 실패에 대해 하나의 재시도만 예약하도록 보장한다.
class BannerAdRetryPolicy {
  static const int maxRetries = 5;

  int _retryCount = 0;
  bool _isRetryScheduled = false;

  int get retryCount => _retryCount;
  bool get isRetryScheduled => _isRetryScheduled;

  /// 다음 재시도를 예약하고, 예약할 수 없으면 null을 반환한다.
  Duration? scheduleRetry() {
    if (_isRetryScheduled || _retryCount >= maxRetries) {
      return null;
    }

    _isRetryScheduled = true;
    _retryCount++;
    return Duration(seconds: 30 * (1 << (_retryCount - 1)));
  }

  /// 예약된 재시도가 실행되기 시작했음을 표시한다.
  void beginScheduledRetry() {
    _isRetryScheduled = false;
  }

  /// 광고 로드 성공 또는 새로운 화면 폭에서 재시도 상태를 초기화한다.
  void reset() {
    _retryCount = 0;
    _isRetryScheduled = false;
  }
}
