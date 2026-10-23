// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:my_first_app/services/ad_consent_service.dart';
import 'package:my_first_app/services/ad_diagnostics.dart';
import 'package:my_first_app/services/interstitial_ad_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePlatform {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final loads = <int>[];
  final shows = <int>[];
  final disposals = <int>[];
  bool throwShow = false;
  bool throwDispose = false;
  Completer<Object?>? showResult;

  void install() {
    messenger.setMockMethodCallHandler(instanceManager.channel, (call) async {
      final args = call.arguments as Map<dynamic, dynamic>?;
      switch (call.method) {
        case 'loadInterstitialAd':
          loads.add(args!['adId'] as int);
          return null;
        case 'showAdWithoutView':
          shows.add(args!['adId'] as int);
          if (throwShow) {
            throw PlatformException(
              code: 'show_error',
              message: 'private detail',
            );
          }
          return showResult?.future;
        case 'disposeAd':
          disposals.add(args!['adId'] as int);
          if (throwDispose) throw PlatformException(code: 'dispose_error');
          return null;
        default:
          return null;
      }
    });
  }

  Future<void> loaded(int id) async {
    final channel = instanceManager.channel;
    await messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(
        MethodCall('onAdEvent', {
          'adId': id,
          'eventName': 'onAdLoaded',
          'responseInfo': null,
        }),
      ),
      (_) {},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakePlatform platform;
  late InterstitialAdManager manager;
  late List<Map<String, Object>> events;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdConsentService.setCanRequestAdsForTesting(true);
    manager = InterstitialAdManager.forTesting();
    platform = _FakePlatform()..install();
    events = [];
    AdDiagnostics.observer = events.add;
  });
  tearDown(() {
    platform.messenger.setMockMethodCallHandler(instanceManager.channel, null);
    AdDiagnostics.observer = null;
  });
  Future<InterstitialAd> ready(WidgetTester tester) async {
    manager.preload();
    await tester.pump();
    await platform.loaded(platform.loads.last);
    await tester.pump();
    return instanceManager.adFor(platform.loads.last) as InterstitialAd;
  }

  testWidgets('show Future error completes once and permits the next ad', (
    tester,
  ) async {
    final first = await ready(tester);
    final firstId = platform.loads.last;
    platform.throwShow = true;
    var unavailable = 0;
    var dismissed = 0;
    await manager.show(
      onDismissed: () => dismissed++,
      onUnavailable: () => unavailable++,
    );
    await tester.pump();
    expect(unavailable, 1);
    expect(dismissed, 0);
    expect(platform.disposals.where((id) => id == firstId), hasLength(1));
    expect(platform.loads, hasLength(2));
    // A delayed native error from the same show must not complete it again.
    first.fullScreenContentCallback!.onAdFailedToShowFullScreenContent!(
      first,
      AdError(0, 'other', 'private detail'),
    );
    expect(unavailable, 1);
    platform.throwShow = false;
    await platform.loaded(platform.loads.last);
    await tester.pump();
    final second = instanceManager.adFor(platform.loads.last) as InterstitialAd;
    await manager.show(
      onDismissed: () => dismissed++,
      onUnavailable: () => unavailable++,
    );
    expect(platform.shows, hasLength(2));
    second.fullScreenContentCallback!.onAdDismissedFullScreenContent!(second);
    await tester.pump();
    expect(dismissed, 1);
    expect(unavailable, 1);
  });

  testWidgets('native failure followed by Future error only cleans up once', (
    tester,
  ) async {
    final ad = await ready(tester);
    final id = platform.loads.last;
    platform.showResult = Completer<Object?>();
    var callbacks = 0;
    final show = manager.show(
      onDismissed: () => callbacks++,
      onUnavailable: () => callbacks++,
    );
    await tester.pump();
    ad.fullScreenContentCallback!.onAdFailedToShowFullScreenContent!(
      ad,
      AdError(0, 'other', 'private detail'),
    );
    await tester.pump();
    platform.showResult!.completeError(PlatformException(code: 'late_error'));
    await show;
    await tester.pump();
    expect(callbacks, 1);
    expect(platform.disposals.where((value) => value == id), hasLength(1));
    expect(platform.loads, hasLength(2));
    expect(events.where((e) => e['stage'] == 'showFailed'), hasLength(1));
  });

  testWidgets('dispose failure cannot prevent followup or reloading', (
    tester,
  ) async {
    await ready(tester);
    platform.throwShow = true;
    platform.throwDispose = true;
    var callbacks = 0;
    await manager.show(
      onDismissed: () => callbacks++,
      onUnavailable: () => callbacks++,
    );
    await tester.pump();
    expect(callbacks, 1);
    expect(platform.loads, hasLength(2));
    expect(events.where((e) => e['stage'] == 'disposeFailed'), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'show and impression diagnostics are distinct and share request ID',
    (tester) async {
      final ad = await ready(tester);
      await manager.show(onDismissed: () {}, onUnavailable: () {});
      ad.fullScreenContentCallback!.onAdShowedFullScreenContent!(ad);
      await tester.pump();
      expect(events.map((e) => e['stage']), [
        'request',
        'loadSucceeded',
        'showRequested',
        'shown',
      ]);
      ad.fullScreenContentCallback!.onAdImpression!(ad);
      expect(events.last['stage'], 'impression');
      expect(events.map((e) => e['request_id']).toSet(), hasLength(1));
      ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
      await tester.pump();
    },
  );
}
