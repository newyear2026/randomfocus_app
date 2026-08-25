/// 광고 로드 실패 시 재시도 간격과 중복 예약을 관리한다.
///
/// 하나의 실패에 대해 하나의 재시도만 예약하도록 보장한다.
class AdRetryPolicy {
  AdRetryPolicy({
    this.maxRetries = defaultMaxRetries,
    this.baseDelay = defaultBaseDelay,
  });

  /// 배너처럼 화면에 머무는 광고는 넉넉한 간격으로 재시도한다.
  factory AdRetryPolicy.banner() => AdRetryPolicy();

  /// 전면 광고는 사용자가 화면을 벗어나기 전에 준비되어야 하므로
  /// 더 짧은 간격으로 재시도한다.
  factory AdRetryPolicy.interstitial() =>
      AdRetryPolicy(baseDelay: const Duration(seconds: 5));

  static const int defaultMaxRetries = 5;
  static const Duration defaultBaseDelay = Duration(seconds: 30);

  final int maxRetries;
  final Duration baseDelay;

  int _retryCount = 0;
  bool _isRetryScheduled = false;

  int get retryCount => _retryCount;
  bool get isRetryScheduled => _isRetryScheduled;
  bool get isExhausted => _retryCount >= maxRetries;

  /// 다음 재시도를 예약하고, 예약할 수 없으면 null을 반환한다.
  Duration? scheduleRetry() {
    if (_isRetryScheduled || isExhausted) {
      return null;
    }

    _isRetryScheduled = true;
    _retryCount++;
    return baseDelay * (1 << (_retryCount - 1));
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
