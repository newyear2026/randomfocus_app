import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_consent_service.dart';
import 'ad_frequency_policy.dart';
import 'ad_ids.dart';
import 'ad_retry_policy.dart';
import 'telemetry_service.dart';

class InterstitialAdManager {
  InterstitialAdManager._();

  static final InterstitialAdManager instance = InterstitialAdManager._();

  /// 마지막 노출 시각을 보관하는 키. 에포크 밀리초로 저장하므로 기기 표준시가
  /// 바뀌어도 간격이 흔들리지 않는다.
  static const String _keyLastShownAt = 'interstitial_last_shown_at';

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isShowing = false;
  Timer? _retryTimer;
  final _retryPolicy = AdRetryPolicy.interstitial();
  final _frequencyPolicy = AdFrequencyPolicy();
  bool _frequencyRestored = false;

  bool get isReady => _interstitialAd != null;

  void preload() {
    if (kIsWeb || _isLoading || _interstitialAd != null) {
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

    debugPrint(
      'InterstitialAd preload requested: unitId=$adUnitId retry=${_retryPolicy.retryCount} testAds=${AdIds.usingTestAds}',
    );

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd preloaded: unitId=${ad.adUnitId}');
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          _isLoading = false;
          _cancelRetry();
          _retryPolicy.reset();
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'InterstitialAd preload failed: unitId=$adUnitId code=${error.code} message=${error.message}',
          );
          _interstitialAd = null;
          _isLoading = false;
          TelemetryService.reportError(
            error,
            StackTrace.current,
            reason: 'interstitial_ad_load',
          );
          _scheduleRetry();
        },
      ),
    );
  }

  Future<void> show({
    required VoidCallback onDismissed,
    required VoidCallback onUnavailable,
  }) async {
    if (kIsWeb) {
      onUnavailable();
      return;
    }

    await _restoreFrequencyState();

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
      debugPrint(
        'InterstitialAd suppressed by frequency cap: '
        'lastShownAt=${_frequencyPolicy.lastShownAt} '
        'interval=${_frequencyPolicy.minimumInterval.inMinutes}m',
      );
      unawaited(TelemetryService.logEvent('interstitial_suppressed_by_cap'));
      onUnavailable();
      return;
    }

    _isShowing = true;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('InterstitialAd showed: unitId=${ad.adUnitId}');
        unawaited(_recordShown());
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('InterstitialAd dismissed: unitId=${ad.adUnitId}');
        _isShowing = false;
        ad.dispose();
        preload();
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          'InterstitialAd failed to show: unitId=${ad.adUnitId} code=${error.code} message=${error.message}',
        );
        _isShowing = false;
        ad.dispose();
        TelemetryService.reportError(
          error,
          StackTrace.current,
          reason: 'interstitial_ad_show',
        );
        preload();
        onUnavailable();
      },
    );

    debugPrint('InterstitialAd show requested');
    ad.show();
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
