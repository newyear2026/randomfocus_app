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

  static bool _canRequestAds = true;

  /// 마지막 동의 확인 결과. 동의 흐름이 끝나기 전에는 true로 취급해
  /// 규제 지역이 아닌 사용자의 광고 요청이 지연되지 않게 한다.
  static bool get canRequestAds => _canRequestAds;

  @visibleForTesting
  static void setCanRequestAdsForTesting(bool value) {
    _canRequestAds = value;
  }

  /// 동의 흐름을 실행하고, 광고를 요청할 수 있는지 여부를 반환한다.
  ///
  /// 네트워크 오류 등으로 동의 상태를 확인하지 못하면 true를 반환해
  /// 규제 지역이 아닌 사용자의 광고가 사라지지 않도록 한다.
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
      debugPrint('AdConsent: timed out, falling back to ad request');
      _canRequestAds = true;
      return true;
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'ad_consent_request',
      );
      _canRequestAds = true;
      return true;
    }
  }

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
