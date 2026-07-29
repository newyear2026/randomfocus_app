import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/banner_ad_retry_policy.dart';

void main() {
  test('does not schedule duplicate banner retries', () {
    final policy = BannerAdRetryPolicy();

    expect(policy.scheduleRetry(), const Duration(seconds: 30));
    expect(policy.isRetryScheduled, isTrue);
    expect(policy.scheduleRetry(), isNull);

    policy.beginScheduledRetry();
    expect(policy.scheduleRetry(), const Duration(minutes: 1));
  });

  test('uses capped exponential retry delays and resets after success', () {
    final policy = BannerAdRetryPolicy();
    final delays = <Duration>[];

    for (var index = 0; index < BannerAdRetryPolicy.maxRetries; index++) {
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

    policy.reset();
    expect(policy.retryCount, 0);
    expect(policy.scheduleRetry(), const Duration(seconds: 30));
  });
}
