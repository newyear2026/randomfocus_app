/// 전면 광고가 너무 자주 뜨지 않도록 최소 간격을 지킨다.
///
/// 간격은 세션 횟수가 아니라 시간을 기준으로 잡는다. 집중 시간을 유저가 짧게
/// 고를 수 있게 되면 "N세션마다 한 번"은 간격을 전혀 보장하지 못하기 때문이다.
///
/// 저장과 시계는 다루지 않는다. 마지막 노출 시각을 어디에 보관하고 '지금'을
/// 어떻게 읽을지는 이 정책을 쓰는 쪽이 정한다.
class AdFrequencyPolicy {
  AdFrequencyPolicy({this.minimumInterval = defaultMinimumInterval})
    : assert(minimumInterval >= Duration.zero);

  static const Duration defaultMinimumInterval = Duration(minutes: 15);

  final Duration minimumInterval;

  DateTime? _lastShownAt;

  DateTime? get lastShownAt => _lastShownAt;

  /// 저장소에서 읽어온 마지막 노출 시각을 반영한다.
  ///
  /// 기록이 없으면 `null`을 넘긴다. 앱이 재시작돼도 간격이 이어지도록, 노출
  /// 여부를 판단하기 전에 한 번 호출해야 한다.
  void restoreLastShownAt(DateTime? shownAt) {
    _lastShownAt = shownAt;
  }

  /// [now] 기준으로 광고를 띄워도 되는지 판단한다.
  bool allowsShowAt(DateTime now) {
    final last = _lastShownAt;
    if (last == null) {
      return true;
    }

    // 기기 시계가 뒤로 돌아갔다면 간격을 계산할 수 없다. 이 경우 광고를
    // 영구히 막아버리지 않도록 허용하고, 다음 노출 때 기준을 다시 잡는다.
    if (now.isBefore(last)) {
      return true;
    }

    return now.difference(last) >= minimumInterval;
  }

  /// 광고가 실제로 노출된 시각을 기록한다.
  ///
  /// 노출을 요청한 시점이 아니라 화면에 떴다는 통보를 받은 시점에 호출한다.
  /// 띄우지 못한 광고로 간격을 소모하면 안 된다.
  void markShownAt(DateTime now) {
    _lastShownAt = now;
  }
}
