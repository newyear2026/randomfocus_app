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
import 'package:my_first_app/services/pro_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_pro_store.dart';

class _FakePlatform {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final loads = <int>[];
  final shows = <int>[];
  final disposals = <int>[];
  bool throwLoad = false;
  bool throwShow = false;
  bool throwDispose = false;
  Completer<Object?>? showResult;

  void install() {
    messenger.setMockMethodCallHandler(instanceManager.channel, (call) async {
      final args = call.arguments as Map<dynamic, dynamic>?;
      switch (call.method) {
        case 'loadInterstitialAd':
          loads.add(args!['adId'] as int);
          if (throwLoad) throw PlatformException(code: 'load_error');
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
  late FakeProStore store;
  late ProService pro;
  setUp(() async {
    store = FakeProStore();
    pro = ProService.forTesting(store);
    await pro.initialize();
    ProService.setInstanceForTesting(pro);
    SharedPreferences.setMockInitialValues({});
    AdConsentService.setCanRequestAdsForTesting(true);
    manager = InterstitialAdManager.forTesting();
    platform = _FakePlatform()..install();
    events = [];
    AdDiagnostics.observer = events.add;
  });
  tearDown(() async {
    manager.dispose();
    platform.messenger.setMockMethodCallHandler(instanceManager.channel, null);
    AdDiagnostics.observer = null;
    ProService.setInstanceForTesting(null);
    pro.dispose();
    await store.dispose();
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
    manager.dispose();
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
    manager.dispose();
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
    manager.dispose();
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
      manager.dispose();
    },
  );
  testWidgets('load Future failures recover with a bounded retry budget', (
    tester,
  ) async {
    platform.throwLoad = true;
    manager.preload();
    manager.preload();
    await tester.pump();
    expect(platform.loads, hasLength(1));
    for (final seconds in [5, 10, 20, 40, 80]) {
      await tester.pump(Duration(seconds: seconds));
      await tester.pump();
    }
    expect(platform.loads, hasLength(6));
    await tester.pump(const Duration(minutes: 10));
    expect(platform.loads, hasLength(6));
    expect(events.where((e) => e['stage'] == 'loadFailed'), hasLength(6));
    expect(tester.takeException(), isNull);
    manager.dispose();
  });

  testWidgets(
    'silent load times out and a late callback cannot replace retry',
    (tester) async {
      manager.preload();
      await tester.pump();
      final firstId = platform.loads.single;
      await tester.pump(const Duration(seconds: 30));
      expect(events.last['stage'], 'timeout');
      await tester.pump(const Duration(seconds: 5));
      final secondId = platform.loads.last;
      expect(platform.loads, hasLength(2));
      await platform.loaded(firstId);
      await tester.pump();
      expect(manager.isReady, isFalse);
      expect(platform.disposals, contains(firstId));
      await platform.loaded(secondId);
      await tester.pump();
      expect(manager.isReady, isTrue);
      await tester.pump(const Duration(seconds: 31));
      expect(platform.loads, hasLength(2));
    },
  );

  testWidgets('late failure cannot clear a later ready ad', (tester) async {
    manager.preload();
    await tester.pump();
    final abandoned =
        instanceManager.adFor(platform.loads.single) as InterstitialAd;
    await tester.pump(const Duration(seconds: 35));
    await tester.pump();
    await platform.loaded(platform.loads.last);
    await tester.pump();
    abandoned.adLoadCallback.onAdFailedToLoad(
      LoadAdError(2, 'com.google.android.gms.ads', 'offline', null),
    );
    expect(manager.isReady, isTrue);
    expect(events.where((e) => e['stage'] == 'loadFailed'), isEmpty);
  });

  testWidgets('revoked consent rejects loaded cache and prevents show', (
    tester,
  ) async {
    manager.preload();
    await tester.pump();
    final id = platform.loads.single;
    AdConsentService.setCanRequestAdsForTesting(false);
    await platform.loaded(id);
    await tester.pump();
    expect(manager.isReady, isFalse);
    expect(platform.disposals, contains(id));
    var unavailable = 0;
    await manager.show(onDismissed: () {}, onUnavailable: () => unavailable++);
    expect(unavailable, 1);
    expect(platform.shows, isEmpty);
    await tester.pump(const Duration(minutes: 1));
    expect(platform.loads, hasLength(1));
  });

  testWidgets('disposing during a load cancels retries and disposes late ads', (
    tester,
  ) async {
    manager.preload();
    await tester.pump();
    final id = platform.loads.single;
    manager.dispose();
    await platform.loaded(id);
    await tester.pump(const Duration(minutes: 2));
    expect(manager.isReady, isFalse);
    expect(platform.disposals.where((value) => value == id), hasLength(1));
    expect(platform.loads, hasLength(1));
  });

  testWidgets(
    'missing show callback releases caller but keeps presentation lease',
    (tester) async {
      final ad = await ready(tester);
      final id = platform.loads.last;
      var unavailable = 0, dismissed = 0;
      await manager.show(
        onDismissed: () => dismissed++,
        onUnavailable: () => unavailable++,
      );
      await tester.pump(const Duration(minutes: 1));
      expect(unavailable, 1);
      expect(dismissed, 0);
      expect(platform.disposals, isNot(contains(id)));
      final loadCount = platform.loads.length;
      await manager.show(onDismissed: () {}, onUnavailable: () {});
      expect(platform.shows, hasLength(1));
      expect(platform.loads, hasLength(loadCount));
      ad.fullScreenContentCallback!.onAdFailedToShowFullScreenContent!(
        ad,
        AdError(0, 'test', 'late'),
      );
      await tester.pump();
      expect(unavailable, 1);
      expect(dismissed, 0);
      expect(platform.disposals.where((value) => value == id), hasLength(1));
      await platform.loaded(platform.loads.last);
      await tester.pump();
      final next = instanceManager.adFor(platform.loads.last) as InterstitialAd;
      await manager.show(
        onDismissed: () => dismissed++,
        onUnavailable: () => unavailable++,
      );
      expect(platform.shows, hasLength(2));
      next.fullScreenContentCallback!.onAdDismissedFullScreenContent!(next);
      await tester.pump();
      expect(dismissed, 1);
      manager.dispose();
    },
  );

  testWidgets('hung show Future is bounded and cannot overlap a second ad', (
    tester,
  ) async {
    manager.dispose();
    manager = InterstitialAdManager.forTesting(
      showTimeout: const Duration(seconds: 1),
    );
    final ad = await ready(tester);
    platform.showResult = Completer<Object?>();
    var callbacks = 0;
    final pending = manager.show(
      onDismissed: () => callbacks++,
      onUnavailable: () => callbacks++,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await pending;
    expect(callbacks, 1);
    await manager.show(onDismissed: () {}, onUnavailable: () {});
    expect(platform.shows, hasLength(1));
    expect(platform.disposals, isEmpty);
    platform.showResult!.complete();
    await tester.pump();
    expect(callbacks, 1);
    ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
    ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
    await tester.pump();
    expect(callbacks, 1);
    expect(platform.disposals, hasLength(1));
    manager.dispose();
  });

  testWidgets(
    'Future error after shown frees caller but waits for native close',
    (tester) async {
      final ad = await ready(tester);
      platform.showResult = Completer<Object?>();
      var callbacks = 0;
      final pending = manager.show(
        onDismissed: () => callbacks++,
        onUnavailable: () => callbacks++,
      );
      await tester.pump();
      ad.fullScreenContentCallback!.onAdShowedFullScreenContent!(ad);
      ad.fullScreenContentCallback!.onAdShowedFullScreenContent!(ad);
      ad.fullScreenContentCallback!.onAdImpression!(ad);
      ad.fullScreenContentCallback!.onAdImpression!(ad);
      platform.showResult!.completeError(PlatformException(code: 'after_show'));
      await pending;
      await tester.pump();
      expect(callbacks, 1);
      expect(platform.disposals, isEmpty);
      expect(events.where((e) => e['stage'] == 'shown'), hasLength(1));
      expect(events.where((e) => e['stage'] == 'impression'), hasLength(1));
      await manager.show(onDismissed: () {}, onUnavailable: () {});
      expect(platform.shows, hasLength(1));
      ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
      await tester.pump();
      expect(callbacks, 1);
      expect(platform.disposals, hasLength(1));
      manager.dispose();
    },
  );

  testWidgets('dispose releases a hung invocation without late navigation', (
    tester,
  ) async {
    final ad = await ready(tester);
    platform.showResult = Completer<Object?>();
    var callbacks = 0;
    final pending = manager.show(
      onDismissed: () => callbacks++,
      onUnavailable: () => callbacks++,
    );
    await tester.pump();
    manager.dispose();
    await pending;
    await tester.pump(const Duration(minutes: 2));
    expect(callbacks, 0);
    expect(platform.disposals, isEmpty);
    ad.fullScreenContentCallback!.onAdDismissedFullScreenContent!(ad);
    platform.showResult!.complete();
    await tester.pump();
    expect(callbacks, 0);
    expect(platform.disposals, hasLength(1));
    expect(platform.loads, hasLength(1));
  });
}
