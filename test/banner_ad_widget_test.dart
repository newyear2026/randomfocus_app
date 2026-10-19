import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:my_first_app/services/ad_consent_service.dart';
import 'package:my_first_app/widgets/banner_ad_widget.dart';

/// google_mobile_ads 플러그인의 메서드 채널을 가로채 광고 로드 결과를
/// 테스트에서 직접 만들어 준다.
class _FakeAdPlatform {
  _FakeAdPlatform(this._messenger);

  final TestDefaultBinaryMessenger _messenger;
  final MethodChannel _channel = instanceManager.channel;

  final List<int> loadedAdIds = <int>[];
  final List<int> disposedAdIds = <int>[];
  final List<int> requestedWidths = <int>[];

  /// null이면 적응형 크기를 구하지 못한 상황을 흉내 낸다.
  num? adaptiveHeight = 60;

  int get lastAdId => loadedAdIds.last;

  void install() {
    _messenger.setMockMethodCallHandler(_channel, (call) async {
      final arguments = call.arguments as Map<dynamic, dynamic>?;
      switch (call.method) {
        case 'AdSize#getLargeAnchoredAdaptiveBannerAdSize':
          requestedWidths.add(arguments!['width'] as int);
          return adaptiveHeight;
        case 'loadBannerAd':
          loadedAdIds.add(arguments!['adId'] as int);
          return null;
        case 'disposeAd':
          disposedAdIds.add(arguments!['adId'] as int);
          return null;
        default:
          return null;
      }
    });
  }

  void uninstall() {
    _messenger.setMockMethodCallHandler(_channel, null);
  }

  Future<void> emitLoaded(int adId) {
    return _emit(adId, 'onAdLoaded', <String, Object?>{'responseInfo': null});
  }

  Future<void> emitFailedToLoad(int adId) {
    return _emit(adId, 'onAdFailedToLoad', <String, Object?>{
      // ignore: invalid_use_of_protected_member
      'loadAdError': LoadAdError(3, 'test-domain', 'no fill', null),
    });
  }

  Future<void> _emit(
    int adId,
    String eventName,
    Map<String, Object?> extra,
  ) async {
    final message = _channel.codec.encodeMethodCall(
      MethodCall('onAdEvent', <dynamic, dynamic>{
        'adId': adId,
        'eventName': eventName,
        ...extra,
      }),
    );
    await _messenger.handlePlatformMessage(_channel.name, message, (_) {});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAdPlatform platform;

  setUp(() {
    AdConsentService.setCanRequestAdsForTesting(true);
    platform = _FakeAdPlatform(
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger,
    );
    platform.install();
  });

  tearDown(() {
    platform.uninstall();
    AdConsentService.setCanRequestAdsForTesting(true);
  });

  Widget hostWithWidth(double width) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: const BannerAdWidget()),
        ),
      ),
    );
  }

  Widget hostWithTrigger(double width, Listenable trigger) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: BannerAdWidget(retryTrigger: trigger),
          ),
        ),
      ),
    );
  }

  /// const 인스턴스는 같은 객체라 Flutter가 리빌드를 건너뛴다. 탭 전환처럼
  /// State는 유지한 채 build만 다시 도는 상황을 만들려면 새 인스턴스를 쓴다.
  Widget rebuiltHostWithWidth(double width) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          // ignore: prefer_const_constructors
          child: SizedBox(width: width, child: BannerAdWidget()),
        ),
      ),
    );
  }

  /// 화면에 실제로 붙어 있는 광고의 adId.
  int? visibleAdId(WidgetTester tester) {
    final adWidgets = tester.widgetList<AdWidget>(find.byType(AdWidget));
    if (adWidgets.isEmpty) {
      return null;
    }
    return instanceManager.adIdFor(adWidgets.single.ad);
  }

  /// 위젯 빌드 → postFrameCallback → 채널 응답까지 진행시킨다.
  Future<void> settleRequest(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  /// 제한된 재시도를 모두 소진시킨다.
  Future<void> exhaustRetries(WidgetTester tester) async {
    await platform.emitFailedToLoad(platform.lastAdId);
    await tester.pump(const Duration(minutes: 2));
    await settleRequest(tester);

    await platform.emitFailedToLoad(platform.lastAdId);
    await tester.pump(const Duration(minutes: 4));
    await settleRequest(tester);

    await platform.emitFailedToLoad(platform.lastAdId);
    await tester.pump(const Duration(minutes: 10));
    await settleRequest(tester);
  }

  testWidgets('shows the ad and drops the placeholder once loaded', (
    tester,
  ) async {
    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);

    expect(platform.loadedAdIds, hasLength(1));
    expect(platform.requestedWidths, <int>[320]);
    expect(find.text('Loading ad...'), findsOneWidget);

    await platform.emitLoaded(platform.lastAdId);
    await tester.pump();

    expect(find.byType(AdWidget), findsOneWidget);
    expect(find.text('Loading ad...'), findsNothing);
  });

  testWidgets('keeps the placeholder and retries after a failed first load', (
    tester,
  ) async {
    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);

    await platform.emitFailedToLoad(platform.lastAdId);
    await tester.pump();

    expect(find.byType(AdWidget), findsNothing);
    expect(find.text('Loading ad...'), findsOneWidget);
    expect(platform.loadedAdIds, hasLength(1));

    // 첫 재시도는 2분 뒤.
    await tester.pump(const Duration(minutes: 1, seconds: 59));
    expect(platform.loadedAdIds, hasLength(1));

    await tester.pump(const Duration(seconds: 1));
    await settleRequest(tester);
    expect(platform.loadedAdIds, hasLength(2));
  });

  testWidgets('keeps showing the loaded ad when the next load fails', (
    tester,
  ) async {
    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);
    await platform.emitLoaded(platform.lastAdId);
    await tester.pump();

    final firstAdId = platform.lastAdId;
    expect(find.byType(AdWidget), findsOneWidget);

    // 폭이 바뀌면 새 폭으로 다시 요청한다.
    await tester.pumpWidget(hostWithWidth(300));
    await settleRequest(tester);

    expect(platform.loadedAdIds, hasLength(2));
    expect(platform.requestedWidths, <int>[320, 300]);
    // 로드 중에도 기존 광고는 화면에 남아 있어야 한다.
    expect(visibleAdId(tester), firstAdId);
    expect(platform.disposedAdIds, isNot(contains(firstAdId)));

    await platform.emitFailedToLoad(platform.lastAdId);
    await tester.pump();

    // 실패해도 기존 광고는 그대로 유지된다.
    expect(visibleAdId(tester), firstAdId);
    expect(find.text('Loading ad...'), findsNothing);
    expect(platform.disposedAdIds, isNot(contains(firstAdId)));
  });

  testWidgets('swaps in the new ad and disposes the previous one', (
    tester,
  ) async {
    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);
    await platform.emitLoaded(platform.lastAdId);
    await tester.pump();
    final firstAdId = platform.lastAdId;
    expect(visibleAdId(tester), firstAdId);

    await tester.pumpWidget(hostWithWidth(300));
    await settleRequest(tester);
    final secondAdId = platform.lastAdId;
    expect(secondAdId, isNot(firstAdId));

    await platform.emitLoaded(secondAdId);
    await tester.pump();
    await tester.pump();

    expect(visibleAdId(tester), secondAdId);
    expect(platform.disposedAdIds, contains(firstAdId));
    expect(platform.disposedAdIds, isNot(contains(secondAdId)));
  });

  testWidgets('recovers from a load that never calls back', (tester) async {
    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);
    final stalledAdId = platform.lastAdId;

    // 콜백이 오지 않아도 12초 뒤에는 요청을 정리한다.
    await tester.pump(const Duration(seconds: 11));
    expect(platform.disposedAdIds, isEmpty);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(platform.disposedAdIds, contains(stalledAdId));

    await tester.pump(const Duration(minutes: 2));
    await settleRequest(tester);
    expect(platform.loadedAdIds, hasLength(2));
  });

  testWidgets('falls back to a standard banner when adaptive size is missing', (
    tester,
  ) async {
    platform.adaptiveHeight = null;

    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);

    // 크기를 못 구해도 요청 자체는 나가야 한다.
    expect(platform.loadedAdIds, hasLength(1));

    await platform.emitLoaded(platform.lastAdId);
    await tester.pump();
    expect(find.byType(AdWidget), findsOneWidget);
  });

  testWidgets('does not bypass the retry delay when the app resumes', (
    tester,
  ) async {
    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);
    await platform.emitFailedToLoad(platform.lastAdId);
    await tester.pump();

    expect(platform.loadedAdIds, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settleRequest(tester);

    // 앱 복귀는 예약된 백오프를 초기화하지 않는다.
    expect(platform.loadedAdIds, hasLength(1));

    await tester.pump(const Duration(minutes: 2));
    await settleRequest(tester);

    // 원래 예약된 시간이 지난 뒤에만 다시 요청한다.
    expect(platform.loadedAdIds, hasLength(2));
  });

  testWidgets('does not request ads when consent disallows them', (
    tester,
  ) async {
    AdConsentService.setCanRequestAdsForTesting(false);

    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);

    expect(platform.loadedAdIds, isEmpty);
    expect(find.byType(AdWidget), findsNothing);
    // 영구히 "로딩 중"으로 남겨두지 않는다.
    expect(find.text('Ad unavailable'), findsOneWidget);
  });

  testWidgets('requests an ad once consent becomes available', (tester) async {
    AdConsentService.setCanRequestAdsForTesting(false);

    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);
    expect(platform.loadedAdIds, isEmpty);

    // 설정 화면에서 동의를 허용하고 타이머 탭으로 돌아오면 build가 다시 돈다.
    AdConsentService.setCanRequestAdsForTesting(true);
    await tester.pumpWidget(rebuiltHostWithWidth(320));
    await settleRequest(tester);

    expect(platform.loadedAdIds, hasLength(1));
  });

  testWidgets('keeps the banner alive when an auto-refresh fails', (
    tester,
  ) async {
    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);
    await platform.emitLoaded(platform.lastAdId);
    await tester.pump();

    final adId = platform.lastAdId;
    expect(visibleAdId(tester), adId);

    // SDK 자동 새로고침이 실패하면 표시 중인 광고와 같은 인스턴스로
    // onAdFailedToLoad가 온다.
    await platform.emitFailedToLoad(adId);
    await tester.pump();

    // 표시 중인 광고를 버리면 화면이 빈 자리로 남는다.
    expect(platform.disposedAdIds, isNot(contains(adId)));
    expect(visibleAdId(tester), adId);
  });

  testWidgets('stops requesting once the retry budget is spent', (
    tester,
  ) async {
    await tester.pumpWidget(hostWithWidth(320));
    await settleRequest(tester);
    await exhaustRetries(tester);

    // 최초 1회 + 재시도 2회로 끝난다.
    expect(platform.loadedAdIds, hasLength(3));
    expect(find.text('Ad unavailable'), findsOneWidget);
  });

  testWidgets('requests again when the timer start refreshes the budget', (
    tester,
  ) async {
    final trigger = ValueNotifier<int>(0);
    addTearDown(trigger.dispose);

    await tester.pumpWidget(hostWithTrigger(320, trigger));
    await settleRequest(tester);
    await exhaustRetries(tester);
    expect(platform.loadedAdIds, hasLength(3));

    // 타이머 시작 신호로 예산을 다시 받는다.
    trigger.value++;
    await settleRequest(tester);

    expect(platform.loadedAdIds, hasLength(4));
    // 문구도 "로딩 중"으로 되돌아간다.
    expect(find.text('Loading ad...'), findsOneWidget);

    // 새 예산으로 재시도도 다시 두 번까지 가능하다.
    await exhaustRetries(tester);
    expect(platform.loadedAdIds, hasLength(6));
  });

  testWidgets('leaves a showing ad alone when the budget refreshes', (
    tester,
  ) async {
    final trigger = ValueNotifier<int>(0);
    addTearDown(trigger.dispose);

    await tester.pumpWidget(hostWithTrigger(320, trigger));
    await settleRequest(tester);
    await platform.emitLoaded(platform.lastAdId);
    await tester.pump();

    final adId = platform.lastAdId;

    trigger.value++;
    await settleRequest(tester);

    // 새로고침은 SDK가 맡으므로 중복 요청하지 않는다.
    expect(platform.loadedAdIds, hasLength(1));
    expect(visibleAdId(tester), adId);
    expect(platform.disposedAdIds, isNot(contains(adId)));
  });
}
