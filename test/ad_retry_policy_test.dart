import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/ad_retry_policy.dart';

void main() {
  test('does not schedule duplicate banner retries', () {
    final policy = AdRetryPolicy.banner();

    expect(policy.scheduleRetry(), const Duration(seconds: 30));
    expect(policy.isRetryScheduled, isTrue);
    expect(policy.scheduleRetry(), isNull);

    policy.beginScheduledRetry();
    expect(policy.scheduleRetry(), const Duration(minutes: 1));
  });

  test('uses capped exponential retry delays and resets after success', () {
    final policy = AdRetryPolicy.banner();
    final delays = <Duration>[];

    for (var index = 0; index < policy.maxRetries; index++) {
      delays.add(policy.scheduleRetry()!);
      policy.beginScheduledRetry();
    }

    expect(delays, const [
      Duration(seconds: 30),
      Duration(minutes: 1),
      Duration(minutes: 2),
      Duration(minutes: 4),
      Duration(minutes: 8),
    ]);
    expect(policy.scheduleRetry(), isNull);
    expect(policy.isExhausted, isTrue);

    policy.reset();
    expect(policy.retryCount, 0);
    expect(policy.isExhausted, isFalse);
    expect(policy.scheduleRetry(), const Duration(seconds: 30));
  });

  test('interstitial retries start sooner than banner retries', () {
    final policy = AdRetryPolicy.interstitial();
    final delays = <Duration>[];

    for (var index = 0; index < policy.maxRetries; index++) {
      delays.add(policy.scheduleRetry()!);
      policy.beginScheduledRetry();
    }

    expect(delays, const [
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 20),
      Duration(seconds: 40),
      Duration(seconds: 80),
    ]);
    expect(policy.scheduleRetry(), isNull);
  });
}
