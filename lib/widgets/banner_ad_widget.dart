import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_consent_service.dart';
import '../services/ad_ids.dart';
import '../services/ad_retry_policy.dart';
import '../services/app_localizations.dart';
import '../services/telemetry_service.dart';
import '../theme/app_colors.dart';

/// 배너 광고 위젯
///
/// 새 광고는 항상 뒤에서 먼저 로드하고, 로드가 끝난 뒤에만 화면의 광고와
/// 교체한다. 그래서 재시도·크기 변경·자동 새로고침 중에도 이미 표시 중인
/// 광고가 사라지지 않는다.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, this.retryTrigger});

  /// 제한된 재시도를 모두 쓴 뒤 다시 기회를 주는 신호.
  ///
  /// 재시도 횟수가 제한되어 있어서, 초기 로드가 연달아 실패하면 앱을 다시
  /// 켜기 전까지 배너가 비어 있게 된다. 타이머 시작처럼 사용자가 화면을
  /// 다시 쓰기 시작하는 시점에 이 신호를 보내면 예산을 새로 받는다.
  final Listenable? retryTrigger;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  /// 콜백이 오지 않는 요청을 정리하기 위한 상한.
  static const Duration _loadTimeout = Duration(seconds: 12);

  /// 적응형 크기 조회가 지연될 때 표준 배너로 넘어가기 위한 상한.
  static const Duration _sizeTimeout = Duration(seconds: 5);

  /// 이 횟수만큼 실패하면 안내 문구를 "로딩 중"에서 "표시 불가"로 바꾼다.
  /// 제한된 마지막 재시도 이후에는 추가 요청 없이 이 상태를 유지한다.
  static const int _quietAfterRetries = 2;

  /// 화면에 표시 중인 광고.
  BannerAd? _visibleAd;

  /// 로드 중인 다음 광고. 성공해야 _visibleAd와 교체된다.
  BannerAd? _pendingAd;

  /// 표시 중인 광고와 로드 중인 광고가 각각 어떤 폭으로 요청됐는지 기억한다.
  int _visibleWidth = 0;
  int _pendingWidth = 0;

  bool _isLoading = false;

  /// 동의가 없어 요청을 보류한 상태. 안내 문구를 "표시 불가"로 바꾸고,
  /// 동의가 생기면 다음 빌드에서 다시 요청하기 위한 표시다.
  bool _consentBlocked = false;
  int _lastRequestedWidth = 0;
  bool _hasRequestedForCurrentWidth = false;
  Timer? _retryTimer;
  Timer? _loadTimeoutTimer;
  final _retryPolicy = AdRetryPolicy.banner();

  @override
  void initState() {
    super.initState();
    widget.retryTrigger?.addListener(_handleRetryTrigger);
  }

  @override
  void didUpdateWidget(BannerAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.retryTrigger != widget.retryTrigger) {
      oldWidget.retryTrigger?.removeListener(_handleRetryTrigger);
      widget.retryTrigger?.addListener(_handleRetryTrigger);
    }
  }

  /// 재시도 예산을 되돌리고 즉시 한 번 더 요청한다.
  ///
  /// 광고가 이미 떠 있으면 새로고침은 SDK가 맡으므로 아무것도 하지 않는다.
  void _handleRetryTrigger() {
    if (!mounted || kIsWeb) return;
    if (_visibleAd != null || _isLoading) return;
    if (_lastRequestedWidth <= 0) return;

    debugPrint('BannerAd retry budget refreshed: width=$_lastRequestedWidth');
    _cancelRetry();
    _retryPolicy.reset();

    // 안내 문구를 "표시 불가"에서 "로딩 중"으로 되돌린다.
    setState(() {});
    _loadBannerAd(_lastRequestedWidth);
  }

  void _ensureBannerLoaded(int width) {
    if (!mounted || kIsWeb || width <= 0) return;
    if (_lastRequestedWidth != width) {
      _cancelRetry();
      _retryPolicy.reset();
      _lastRequestedWidth = width;
      _hasRequestedForCurrentWidth = false;
    }

    if (_isLoading || _hasRequestedForCurrentWidth) {
      return;
    }

    // 동의가 없으면 요청 플래그를 세우지 않는다. 그래야 설정 화면에서 동의를
    // 바꾼 뒤 다음 빌드에서 다시 요청할 수 있다. build 중이므로 setState 없이
    // 값만 바꾸고, 이어지는 build가 이 값을 읽는다.
    if (!AdConsentService.canRequestAds) {
      _consentBlocked = true;
      return;
    }
    _consentBlocked = false;

    _hasRequestedForCurrentWidth = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBannerAd(width);
      }
    });
  }

  Future<void> _loadBannerAd(int width) async {
    if (!mounted || kIsWeb || width <= 0 || _isLoading) return;

    if (!AdConsentService.canRequestAds) {
      debugPrint('BannerAd skipped: consent does not allow ad requests');
      return;
    }

    final adUnitId = AdIds.getBannerAdUnitId();
    _isLoading = true;
    debugPrint(
      'BannerAd load requested: unitId=$adUnitId width=$width retry=${_retryPolicy.retryCount} testAds=${AdIds.usingTestAds}',
    );

    final adaptiveSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      width,
    ).timeout(_sizeTimeout, onTimeout: () => null);

    if (!mounted) {
      _isLoading = false;
      return;
    }

    // 적응형 크기를 못 구해도 표준 배너로 요청해 빈 자리를 남기지 않는다.
    final adSize = adaptiveSize ?? AdSize.banner;
    if (adaptiveSize == null) {
      debugPrint('BannerAd adaptive size unavailable: width=$width');
    }

    final ad = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) => _handleAdLoaded(loadedAd),
        onAdFailedToLoad: (failedAd, error) =>
            _handleAdFailedToLoad(failedAd, error),
        onAdOpened: (_) {
          debugPrint('BannerAd opened');
        },
        onAdClosed: (_) {
          debugPrint('BannerAd closed');
        },
      ),
    );

    _pendingAd = ad;
    _pendingWidth = width;
    _startLoadTimeout();
    ad.load();
  }

  void _handleAdLoaded(Ad ad) {
    // 자동 새로고침으로 이미 표시 중인 광고가 다시 채워진 경우.
    if (identical(ad, _visibleAd)) {
      debugPrint('BannerAd refreshed: unitId=${ad.adUnitId}');
      return;
    }

    // 타임아웃 등으로 이미 버린 요청의 뒤늦은 콜백.
    if (!identical(ad, _pendingAd)) {
      ad.dispose();
      return;
    }

    _cancelLoadTimeout();
    _isLoading = false;
    _pendingAd = null;
    final loadedWidth = _pendingWidth;

    if (!mounted) {
      ad.dispose();
      return;
    }

    debugPrint('BannerAd loaded: unitId=${ad.adUnitId}');
    final previousAd = _visibleAd;
    setState(() {
      _visibleAd = ad as BannerAd;
      _visibleWidth = loadedWidth;
    });

    // 교체된 광고는 새 AdWidget이 화면에 올라간 뒤에 정리한다.
    if (previousAd != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => previousAd.dispose());
    }

    _cancelRetry();
    _retryPolicy.reset();

    // 로드 중에 화면 폭이 바뀌었다면, 표시 중인 광고는 유지한 채
    // 새 폭에 맞는 광고를 다시 요청한다.
    if (_lastRequestedWidth > 0 && _lastRequestedWidth != _visibleWidth) {
      _hasRequestedForCurrentWidth = false;
      _loadBannerAd(_lastRequestedWidth);
    }
  }

  void _handleAdFailedToLoad(Ad ad, LoadAdError error) {
    // SDK 자동 새로고침이 실패한 경우다. 표시 중인 광고는 이전 소재를 그대로
    // 보여주고 있고 SDK가 다음 주기에 다시 채우므로, 여기서 버리면 멀쩡한
    // 광고가 빈 자리로 바뀐다.
    if (identical(ad, _visibleAd)) {
      debugPrint(
        'BannerAd refresh failed, keeping current ad: code=${error.code} message=${error.message}',
      );
      return;
    }

    if (!identical(ad, _pendingAd)) {
      ad.dispose();
      return;
    }

    debugPrint(
      'BannerAd failed to load: unitId=${ad.adUnitId} code=${error.code} message=${error.message}',
    );

    _cancelLoadTimeout();
    _isLoading = false;
    _pendingAd = null;
    ad.dispose();

    TelemetryService.reportError(
      error,
      StackTrace.current,
      reason: 'banner_ad_load',
    );

    if (!mounted) {
      return;
    }

    // 표시 중인 광고는 그대로 두고 다음 시도만 예약한다.
    setState(() {});
    _scheduleRetry();
  }

  void _startLoadTimeout() {
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = Timer(_loadTimeout, () {
      _loadTimeoutTimer = null;
      final stalledAd = _pendingAd;
      if (stalledAd == null || !_isLoading) {
        return;
      }

      debugPrint(
        'BannerAd load timed out after ${_loadTimeout.inSeconds}s: width=$_lastRequestedWidth',
      );
      _pendingAd = null;
      _isLoading = false;
      stalledAd.dispose();

      if (!mounted) {
        return;
      }

      setState(() {});
      _scheduleRetry();
    });
  }

  void _cancelLoadTimeout() {
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = null;
  }

  void _scheduleRetry() {
    final retryDelay = _retryPolicy.scheduleRetry();
    if (retryDelay == null) {
      return;
    }

    debugPrint(
      'BannerAd retry scheduled: retry=${_retryPolicy.retryCount} delay=${retryDelay.inSeconds}s width=$_lastRequestedWidth',
    );

    _retryTimer = Timer(retryDelay, () {
      _retryTimer = null;
      _retryPolicy.beginScheduledRetry();
      if (mounted && _lastRequestedWidth > 0) {
        _loadBannerAd(_lastRequestedWidth);
      }
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  void dispose() {
    widget.retryTrigger?.removeListener(_handleRetryTrigger);
    _cancelRetry();
    _cancelLoadTimeout();
    _pendingAd?.dispose();
    _visibleAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.truncate();
        _ensureBannerLoaded(width);

        final visibleAd = _visibleAd;
        if (visibleAd != null) {
          return Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: visibleAd.size.height.toDouble(),
            child: AdWidget(key: ObjectKey(visibleAd), ad: visibleAd),
          );
        }

        // 첫 광고가 채워지기 전까지만 자리를 유지한다.
        final l10n = AppLocalizations.of(context);
        final isQuiet =
            _consentBlocked || _retryPolicy.retryCount >= _quietAfterRetries;
        final message = isQuiet
            ? (l10n?.adUnavailable ?? 'Ad unavailable')
            : (l10n?.adLoading ?? 'Loading ad...');
        final fallbackHeight =
            _pendingAd?.size.height.toDouble() ??
            AdSize.banner.height.toDouble();

        return Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: fallbackHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted(context),
            border: Border.all(color: AppColors.subtleBorder(context), width: 1),
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: isQuiet
                    ? AppColors.textMuted(context)
                    : AppColors.textSecondary(context),
              ),
            ),
          ),
        );
      },
    );
  }
}
