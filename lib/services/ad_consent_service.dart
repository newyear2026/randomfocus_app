import 'dart:async';

import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, visibleForTesting;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'telemetry_service.dart';

/// UMP(User Messaging Platform) 동의 흐름을 관리한다.
///
/// EEA/영국 등 규제 지역에서는 인증된 동의 화면 없이 광고를 요청하면
/// 게재가 거부되므로, 광고 초기화 전에 동의 상태를 갱신하고
/// 필요한 경우 동의 양식을 노출한다.
class AdConsentService {
  AdConsentService._();

  /// 동의 정보 갱신이 지연될 때 광고 초기화를 막지 않기 위한 상한.
  static const Duration _timeout = Duration(seconds: 8);

  static bool _canRequestAds = false;

  /// 마지막 동의 확인 결과.
  ///
  /// 동의 흐름이 끝나기 전에는 false다. 앱 시작 시 [requestConsent]를 기다린
  /// 뒤에 광고를 올리므로 이 값이 광고를 지연시키지는 않고, 혹시 흐름을 건너
  /// 뛴 경로가 생겨도 동의 없이 광고를 요청하지 않는다.
  static bool get canRequestAds => _canRequestAds;

  @visibleForTesting
  static void setCanRequestAdsForTesting(bool value) {
    _canRequestAds = value;
  }

  /// 동의 흐름을 실행하고, 광고를 요청할 수 있는지 여부를 반환한다.
  ///
  /// 네트워크 오류 등으로 흐름을 끝내지 못하면 기기에 남은 동의 상태로
  /// 판단한다. [_canRequestAdsFromCachedStatus]를 참고한다.
  static Future<bool> requestConsent() async {
    if (kIsWeb) {
      return false;
    }

    try {
      await _updateConsentInfo().timeout(_timeout);
      await _showFormIfRequired().timeout(_timeout);
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      return _canRequestAds;
    } on TimeoutException {
      debugPrint('AdConsent: timed out, falling back to the cached status');
      _canRequestAds = await _canRequestAdsFromCachedStatus();
      return _canRequestAds;
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'ad_consent_request',
      );
      _canRequestAds = await _canRequestAdsFromCachedStatus();
      return _canRequestAds;
    }
  }

  /// 동의 흐름을 끝내지 못했을 때, 기기에 남은 동의 상태로 판단한다.
  ///
  /// UMP는 한 번 확인한 상태를 기기에 보관하므로 두 번째 실행 이후에는
  /// 네트워크가 끊겨도 규제 지역인지 알 수 있다. 규제 대상이 아니거나 이미
  /// 동의를 받은 경우에만 광고를 요청한다.
  ///
  /// 상태를 전혀 모르면(첫 실행에서 연결이 실패한 경우) 요청하지 않는다.
  /// 규제 지역 사용자의 데이터를 동의 없이 보내는 쪽이, 광고 한 번을 놓치는
  /// 것보다 나쁘다.
  static Future<bool> _canRequestAdsFromCachedStatus() async {
    try {
      final status = await ConsentInformation.instance.getConsentStatus();
      debugPrint('AdConsent: cached status is $status');
      return allowsAdsForConsentStatus(status);
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'ad_consent_cached_status',
      );
      return false;
    }
  }

  /// 주어진 동의 상태에서 광고를 요청해도 되는지 판단한다.
  ///
  /// 규제 대상이 아니거나([ConsentStatus.notRequired]) 이미 동의를 받은
  /// ([ConsentStatus.obtained]) 경우에만 허용한다. 동의가 필요한데 아직 받지
  /// 못했거나([ConsentStatus.required]) 상태를 모르면
  /// ([ConsentStatus.unknown]) 요청하지 않는다.
  static bool allowsAdsForConsentStatus(ConsentStatus status) =>
      status == ConsentStatus.notRequired || status == ConsentStatus.obtained;

  /// 설정 화면에서 사용자가 동의 내용을 다시 변경할 수 있게 한다.
  ///
  /// 규제 지역 사용자에게는 개인정보 옵션 진입점 제공이 요구된다.
  static Future<bool> isPrivacyOptionsRequired() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'ad_consent_privacy_status',
      );
      return false;
    }
  }

  /// 개인정보 옵션 양식을 표시한다.
  static Future<void> showPrivacyOptionsForm() async {
    if (kIsWeb) {
      return;
    }

    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        debugPrint(
          'AdConsent privacy form error: ${formError.errorCode} ${formError.message}',
        );
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      await completer.future.timeout(_timeout);
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
    } on TimeoutException {
      debugPrint('AdConsent: privacy options form timed out');
    }
  }

  static Future<void> _updateConsentInfo() {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        debugPrint('AdConsent: consent info updated');
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      (formError) {
        debugPrint(
          'AdConsent update failed: ${formError.errorCode} ${formError.message}',
        );
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    return completer.future;
  }

  static Future<void> _showFormIfRequired() {
    final completer = Completer<void>();

    ConsentForm.loadAndShowConsentFormIfRequired((formError) {
      if (formError != null) {
        debugPrint(
          'AdConsent form error: ${formError.errorCode} ${formError.message}',
        );
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    return completer.future;
  }
}
