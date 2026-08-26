/// 광고 로드 실패 시 재시도 간격과 중복 예약을 관리한다.
///
/// 하나의 실패에 대해 하나의 재시도만 예약하도록 보장한다.
class AdRetryPolicy {
  AdRetryPolicy({
    this.maxRetries = defaultMaxRetries,
    this.baseDelay = defaultBaseDelay,
    this.maxDelay = defaultMaxDelay,
  });

  /// 배너는 화면에 계속 머무르므로 짧은 간격으로 무제한 재시도한다.
  ///
  /// 노필(no fill)은 정상적인 응답이라 언젠가는 채워지므로,
  /// 재시도를 포기해 빈 자리를 남기는 대신 상한(1분) 간격으로 계속 시도한다.
  factory AdRetryPolicy.banner() => AdRetryPolicy(
    maxRetries: null,
    baseDelay: const Duration(seconds: 6),
    maxDelay: const Duration(seconds: 60),
  );

  /// 전면 광고는 사용자가 화면을 벗어나기 전에 준비되어야 하므로
  /// 더 짧은 간격으로 재시도한다.
  factory AdRetryPolicy.interstitial() =>
      AdRetryPolicy(baseDelay: const Duration(seconds: 5));

  static const int defaultMaxRetries = 5;
  static const Duration defaultBaseDelay = Duration(seconds: 30);
  static const Duration defaultMaxDelay = Duration(minutes: 8);

  /// null이면 재시도 횟수를 제한하지 않는다.
  final int? maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  int _retryCount = 0;
  bool _isRetryScheduled = false;

  int get retryCount => _retryCount;
  bool get isRetryScheduled => _isRetryScheduled;
  bool get isExhausted {
    final limit = maxRetries;
    return limit != null && _retryCount >= limit;
  }

  /// 다음 재시도를 예약하고, 예약할 수 없으면 null을 반환한다.
  Duration? scheduleRetry() {
    if (_isRetryScheduled || isExhausted) {
      return null;
    }

    _isRetryScheduled = true;
    _retryCount++;

    final exponent = _retryCount - 1;
    if (exponent >= 32) {
      return maxDelay;
    }

    final delay = baseDelay * (1 << exponent);
    return delay > maxDelay ? maxDelay : delay;
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
