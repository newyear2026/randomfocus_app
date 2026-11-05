import 'dart:async';

import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_consent_service.dart';
import 'ad_diagnostics.dart';
import 'pro_service.dart';
import 'ad_frequency_policy.dart';
import 'ad_ids.dart';
import 'ad_retry_policy.dart';
import 'telemetry_service.dart';

class InterstitialAdManager {
  InterstitialAdManager._()
    : loadTimeout = const Duration(seconds: 30),
      showTimeout = const Duration(minutes: 1);

  @visibleForTesting
  InterstitialAdManager.forTesting({
    this.loadTimeout = const Duration(seconds: 30),
    this.showTimeout = const Duration(minutes: 1),
  });

  final Duration loadTimeout;
  final Duration showTimeout;

  static final InterstitialAdManager instance = InterstitialAdManager._();

  /// 마지막 노출 시각을 보관하는 키. 에포크 밀리초로 저장하므로 기기 표준시가
  /// 바뀌어도 간격이 흔들리지 않는다.
  static const String _keyLastShownAt = 'interstitial_last_shown_at';

  InterstitialAd? _interstitialAd;
  int? _interstitialRequestId;
  bool _isLoading = false;
  bool _isShowing = false;
  Timer? _retryTimer;
  Timer? _loadTimer;
  Timer? _showTimer;
  Completer<void>? _showInvocation;
  int _loadGeneration = 0;
  bool _disposed = false;
  final _disposedAds = Expando<bool>();
  final _retryPolicy = AdRetryPolicy.interstitial();
  final _frequencyPolicy = AdFrequencyPolicy();
  bool _frequencyRestored = false;

  bool get isReady => _interstitialAd != null;

  void handleEntitlementChanged() {
    if (ProService.instance.adsAllowed) return;
    _discardPreload();
  }

  void _discardPreload() {
    _loadGeneration++;
    _loadTimer?.cancel();
    _loadTimer = null;
    _isLoading = false;
    _cancelRetry();
    _retryPolicy.reset();
    final ad = _interstitialAd;
    _interstitialAd = null;
    if (ad != null) unawaited(_disposeAfterShow(ad, _interstitialRequestId));
    _interstitialRequestId = null;
  }

  void dispose() {
    _disposed = true;
    _showTimer?.cancel();
    final invocation = _showInvocation;
    if (invocation != null && !invocation.isCompleted) invocation.complete();
    _showInvocation = null;
    _discardPreload();
  }

  void preload() {
    if (_disposed) return;
    if (!ProService.instance.adsAllowed) {
      handleEntitlementChanged();
      return;
    }
    if (kIsWeb || _isShowing || _isLoading || _interstitialAd != null) {
      return;
    }

    // 배너와 같은 기준으로 막는다. 호출 지점이 여러 곳이라 각자 확인하게 두면
    // 하나가 빠지고, 그 경로로 동의 없는 광고 요청이 나간다.
    if (!AdConsentService.canRequestAds) {
      debugPrint('InterstitialAd skipped: consent does not allow ad requests');
      return;
    }

    final adUnitId = AdIds.getInterstitialAdUnitId();
    _isLoading = true;

    final requestId = AdDiagnostics.beginRequest(AdFormat.interstitial);
    final generation = ++_loadGeneration;

    bool finishLoad() {
      if (_disposed || !_isLoading || generation != _loadGeneration) {
        return false;
      }
      _loadTimer?.cancel();
      _loadTimer = null;
      _isLoading = false;
      return true;
    }

    void fail({LoadAdError? error, bool timedOut = false}) {
      if (!finishLoad()) return;
      AdDiagnostics.record(
        AdFormat.interstitial,
        timedOut ? AdStage.timeout : AdStage.loadFailed,
        requestId: requestId,
        error: error,
        failure: error == null && !timedOut ? AdFailureKind.platform : null,
      );
      if (ProService.instance.adsAllowed && AdConsentService.canRequestAds) {
        _scheduleRetry();
      }
    }

    _loadTimer = Timer(loadTimeout, () => fail(timedOut: true));

    Future<void> request() async {
      try {
        await InterstitialAd.load(
          adUnitId: adUnitId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              if (!finishLoad()) {
                if (!identical(ad, _interstitialAd)) {
                  unawaited(_disposeAfterShow(ad, requestId));
                }
                return;
              }
              if (!ProService.instance.adsAllowed ||
                  !AdConsentService.canRequestAds) {
                unawaited(_disposeAfterShow(ad, requestId));
                return;
              }
              AdDiagnostics.record(
                AdFormat.interstitial,
                AdStage.loadSucceeded,
                requestId: requestId,
              );
              _interstitialAd = ad;
              _interstitialRequestId = requestId;
              _isLoading = false;
              _cancelRetry();
              _retryPolicy.reset();
            },
            onAdFailedToLoad: (error) => fail(error: error),
          ),
        );
      } catch (_) {
        fail();
      }
    }

    unawaited(request());
  }

  Future<void> show({
    required VoidCallback onDismissed,
    required VoidCallback onUnavailable,
  }) async {
    if (_disposed ||
        kIsWeb ||
        !ProService.instance.adsAllowed ||
        !AdConsentService.canRequestAds) {
      _discardPreload();
      onUnavailable();
      return;
    }

    await _restoreFrequencyState();
    if (_disposed ||
        !ProService.instance.adsAllowed ||
        !AdConsentService.canRequestAds) {
      _discardPreload();
      onUnavailable();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null || _isShowing) {
      debugPrint(
        'InterstitialAd unavailable: ready=${ad != null} isShowing=$_isShowing',
      );
      _retryPolicy.reset();
      _cancelRetry();
      preload();
      onUnavailable();
      return;
    }

    // 간격에 걸리면 준비된 광고를 버리지 않고 그대로 들고 간다. 다음 노출
    // 지점에서 곧바로 쓸 수 있다.
    if (!_frequencyPolicy.allowsShowAt(DateTime.now())) {
      debugPrint('InterstitialAd suppressed by frequency cap');
      unawaited(TelemetryService.logEvent('interstitial_suppressed_by_cap'));
      onUnavailable();
      return;
    }

    _isShowing = true;
    _interstitialAd = null;
    final requestId = _interstitialRequestId;
    var answered = false;
    var closed = false;
    var shown = false;
    var impressionRecorded = false;
    final invocation = Completer<void>();
    _showInvocation = invocation;

    void completeInvocation() {
      if (!invocation.isCompleted) invocation.complete();
    }

    void answer({required bool dismissed}) {
      if (answered) return;
      answered = true;
      _showTimer?.cancel();
      _showTimer = null;
      completeInvocation();
      if (_disposed) return;
      if (dismissed) {
        onDismissed();
      } else {
        onUnavailable();
      }
    }

    // UI completion and native presentation ownership are separate. A timeout
    // must not dispose a possibly visible ad or allow another one to overlap.
    void close({required bool dismissed, AdError? error}) {
      if (closed) return;
      closed = true;
      _isShowing = false;
      AdDiagnostics.record(
        AdFormat.interstitial,
        dismissed ? AdStage.dismissed : AdStage.showFailed,
        requestId: requestId,
        error: error,
        failure: !dismissed && error == null ? AdFailureKind.platform : null,
      );
      unawaited(_disposeAfterShow(ad, requestId));
      preload();
      answer(dismissed: dismissed);
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        if (closed || shown) return;
        shown = true;
        AdDiagnostics.record(
          AdFormat.interstitial,
          AdStage.shown,
          requestId: requestId,
        );
        unawaited(_recordShown());
      },
      onAdImpression: (_) {
        if (closed || impressionRecorded) return;
        impressionRecorded = true;
        AdDiagnostics.record(
          AdFormat.interstitial,
          AdStage.impression,
          requestId: requestId,
        );
      },
      onAdDismissedFullScreenContent: (_) => close(dismissed: true),
      onAdFailedToShowFullScreenContent: (_, error) =>
          close(dismissed: false, error: error),
    );

    _showTimer = Timer(showTimeout, () {
      if (answered) return;
      AdDiagnostics.record(
        AdFormat.interstitial,
        AdStage.timeout,
        requestId: requestId,
      );
      answer(dismissed: false);
    });
    AdDiagnostics.record(
      AdFormat.interstitial,
      AdStage.showRequested,
      requestId: requestId,
    );
    Future<void> present() async {
      try {
        await ad.show();
      } catch (_) {
        if (shown) {
          // A platform error after showing is not a native close acknowledgement.
          answer(dismissed: false);
        } else {
          close(dismissed: false);
        }
      } finally {
        completeInvocation();
      }
    }

    unawaited(present());
    // Keep the existing invocation Future semantics, but also release a hung
    // platform call on the UI deadline or manager disposal.
    await invocation.future;
    if (identical(_showInvocation, invocation)) _showInvocation = null;
  }

  Future<void> _disposeAfterShow(InterstitialAd ad, int? requestId) async {
    if (_disposedAds[ad] == true) return;
    _disposedAds[ad] = true;
    try {
      await ad.dispose();
    } catch (_) {
      AdDiagnostics.record(
        AdFormat.interstitial,
        AdStage.disposeFailed,
        requestId: requestId,
        failure: AdFailureKind.platform,
      );
    }
  }

  /// 저장된 마지막 노출 시각을 한 번만 불러온다.
  ///
  /// 실패해도 다시 시도하지 않는다. 간격 기준이 없으면 광고를 막기보다 띄우는
  /// 쪽으로 넘어가는 게 맞고, 노출에 성공하면 그 시점부터 기준이 다시 선다.
  Future<void> _restoreFrequencyState() async {
    if (_frequencyRestored) return;
    _frequencyRestored = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt(_keyLastShownAt);
      _frequencyPolicy.restoreLastShownAt(
        millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis),
      );
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'interstitial_frequency_restore',
      );
    }
  }

  /// 노출 시각을 메모리와 저장소에 함께 남긴다.
  Future<void> _recordShown() async {
    final now = DateTime.now();
    _frequencyPolicy.markShownAt(now);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastShownAt, now.millisecondsSinceEpoch);
    } catch (error, stackTrace) {
      // 저장에 실패해도 메모리 값은 남으므로 이번 실행 동안은 간격이 지켜진다.
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'interstitial_frequency_persist',
      );
    }
  }

  void _scheduleRetry() {
    final retryDelay = _retryPolicy.scheduleRetry();
    if (retryDelay == null) {
      return;
    }

    debugPrint(
      'InterstitialAd retry scheduled: retry=${_retryPolicy.retryCount} delay=${retryDelay.inSeconds}s',
    );

    _retryTimer = Timer(retryDelay, () {
      _retryTimer = null;
      _retryPolicy.beginScheduledRetry();
      preload();
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }
}
