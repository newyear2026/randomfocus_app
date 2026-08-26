import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/ad_retry_policy.dart';

void main() {
  test('does not schedule duplicate banner retries', () {
    final policy = AdRetryPolicy.banner();

    expect(policy.scheduleRetry(), const Duration(seconds: 6));
    expect(policy.isRetryScheduled, isTrue);
    expect(policy.scheduleRetry(), isNull);

    policy.beginScheduledRetry();
    expect(policy.scheduleRetry(), const Duration(seconds: 12));
  });

  test('banner retries back off up to the cap and never give up', () {
    final policy = AdRetryPolicy.banner();
    final delays = <Duration>[];

    for (var index = 0; index < 6; index++) {
      delays.add(policy.scheduleRetry()!);
      policy.beginScheduledRetry();
    }

    expect(delays, const [
      Duration(seconds: 6),
      Duration(seconds: 12),
      Duration(seconds: 24),
      Duration(seconds: 48),
      Duration(seconds: 60),
      Duration(seconds: 60),
    ]);
    expect(policy.isExhausted, isFalse);
    expect(policy.scheduleRetry(), const Duration(seconds: 60));

    policy.reset();
    expect(policy.retryCount, 0);
    expect(policy.scheduleRetry(), const Duration(seconds: 6));
  });

  test('banner backoff stays capped after many failures', () {
    final policy = AdRetryPolicy.banner();

    for (var index = 0; index < 200; index++) {
      expect(policy.scheduleRetry(), isNotNull);
      policy.beginScheduledRetry();
    }

    policy.beginScheduledRetry();
    expect(policy.scheduleRetry(), const Duration(seconds: 60));
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

  test('interstitial retries start sooner than banner retries', () {
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
