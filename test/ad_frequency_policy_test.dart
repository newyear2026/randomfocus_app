import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/ad_frequency_policy.dart';

void main() {
  final now = DateTime(2026, 10, 19, 14, 0);

  test('the first ad of an install is allowed', () {
    final policy = AdFrequencyPolicy();

    expect(policy.lastShownAt, isNull);
    expect(policy.allowsShowAt(now), isTrue);
  });

  test('a second ad waits for the full interval', () {
    final policy = AdFrequencyPolicy(
      minimumInterval: const Duration(minutes: 15),
    );
    policy.markShownAt(now);

    expect(policy.allowsShowAt(now), isFalse);
    expect(policy.allowsShowAt(now.add(const Duration(minutes: 14))), isFalse);
    expect(
      policy.allowsShowAt(now.add(const Duration(minutes: 14, seconds: 59))),
      isFalse,
    );
    expect(policy.allowsShowAt(now.add(const Duration(minutes: 15))), isTrue);
  });

  test('restoring a stored timestamp keeps the interval across a restart', () {
    final policy = AdFrequencyPolicy(
      minimumInterval: const Duration(minutes: 15),
    );

    // 저장소에는 에포크 밀리초로 보관한다. 기기 표준시가 바뀌어도 간격이
    // 흔들리지 않아야 한다.
    final restored = DateTime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch,
    );
    policy.restoreLastShownAt(restored);

    expect(policy.allowsShowAt(now.add(const Duration(minutes: 14))), isFalse);
    expect(policy.allowsShowAt(now.add(const Duration(minutes: 15))), isTrue);
  });

  test('a restore with no stored record allows an ad', () {
    final policy = AdFrequencyPolicy();
    policy.markShownAt(now);
    policy.restoreLastShownAt(null);

    expect(policy.allowsShowAt(now), isTrue);
  });

  test('a clock that moved backwards does not lock ads out forever', () {
    final policy = AdFrequencyPolicy(
      minimumInterval: const Duration(minutes: 15),
    );
    policy.markShownAt(now);

    // 기기 시계가 과거로 돌아간 경우. 간격을 계산할 수 없으므로 막지 않는다.
    expect(policy.allowsShowAt(now.subtract(const Duration(days: 1))), isTrue);
  });

  test('a zero interval never suppresses an ad', () {
    final policy = AdFrequencyPolicy(minimumInterval: Duration.zero);
    policy.markShownAt(now);

    expect(policy.allowsShowAt(now), isTrue);
  });

  test('the shipped default is fifteen minutes', () {
    expect(
      AdFrequencyPolicy().minimumInterval,
      AdFrequencyPolicy.defaultMinimumInterval,
    );
    expect(
      AdFrequencyPolicy.defaultMinimumInterval,
      const Duration(minutes: 15),
    );
  });
}
