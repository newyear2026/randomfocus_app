import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/ad_retry_policy.dart';

void main() {
  test('does not schedule duplicate banner retries', () {
    final policy = AdRetryPolicy.banner();

    expect(policy.scheduleRetry(), const Duration(minutes: 2));
    expect(policy.isRetryScheduled, isTrue);
    expect(policy.scheduleRetry(), isNull);

    policy.beginScheduledRetry();
    expect(policy.scheduleRetry(), const Duration(minutes: 4));
  });

  test('banner retries twice with backoff and then gives up', () {
    final policy = AdRetryPolicy.banner();

    expect(policy.scheduleRetry(), const Duration(minutes: 2));
    policy.beginScheduledRetry();
    expect(policy.scheduleRetry(), const Duration(minutes: 4));
    policy.beginScheduledRetry();

    expect(policy.isExhausted, isTrue);
    expect(policy.scheduleRetry(), isNull);

    policy.reset();
    expect(policy.retryCount, 0);
    expect(policy.scheduleRetry(), const Duration(minutes: 2));
  });

  test('interstitial gives up after the configured retry count', () {
    final policy = AdRetryPolicy.interstitial();

    for (var index = 0; index < AdRetryPolicy.defaultMaxRetries; index++) {
      policy.scheduleRetry();
      policy.beginScheduledRetry();
    }

    expect(policy.isExhausted, isTrue);
    expect(policy.scheduleRetry(), isNull);

    policy.reset();
    expect(policy.isExhausted, isFalse);
    expect(policy.scheduleRetry(), const Duration(seconds: 5));
  });

  test('interstitial uses its configured retry sequence', () {
    final policy = AdRetryPolicy.interstitial();
    final delays = <Duration>[];

    for (var index = 0; index < AdRetryPolicy.defaultMaxRetries; index++) {
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
