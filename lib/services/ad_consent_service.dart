import 'dart:async';

import 'package:flutter/foundation.dart'
    show ValueListenable, ValueNotifier, kIsWeb, visibleForTesting;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_diagnostics.dart';

/// UMP(User Messaging Platform) 동의 흐름을 관리한다.
///
/// EEA/영국 등 규제 지역에서는 인증된 동의 화면 없이 광고를 요청하면
/// 게재가 거부되므로, 광고 초기화 전에 동의 상태를 갱신하고
/// 필요한 경우 동의 양식을 노출한다.
class AdConsentService {
  AdConsentService._();

  /// 동의 정보 갱신이 지연될 때 광고 초기화를 막지 않기 위한 상한.
  static const Duration _timeout = Duration(seconds: 8);

  static final _permission = ValueNotifier<bool>(false);
  static Future<bool>? _consentFlow;
  static int _permissionQuery = 0;

  static bool get canRequestAds => _permission.value;
  static ValueListenable<bool> get adRequestPermission => _permission;

  @visibleForTesting
  static void setCanRequestAdsForTesting(bool value) {
    _permission.value = value;
  }

  /// Bounds startup waiting without cancelling a user's pending consent form.
  /// Late UMP completion still updates permission and notifies ad consumers.
  static Future<bool> requestConsent() async {
    if (kIsWeb) return false;
    final flow = _consentFlow ??= _runConsentFlow();
    return flow.timeout(
      _timeout,
      onTimeout: () {
        AdDiagnostics.record(AdFormat.consent, AdStage.timeout);
        return _refreshPermission();
      },
    );
  }

  static Future<bool> _runConsentFlow() async {
    try {
      await _updateConsentInfo();
      await _showFormIfRequired();
    } catch (_) {
      AdDiagnostics.record(
        AdFormat.consent,
        AdStage.loadFailed,
        failure: AdFailureKind.platform,
      );
    }
    try {
      return await _refreshPermission();
    } finally {
      _consentFlow = null;
    }
  }

  static Future<bool> _refreshPermission() async {
    final query = ++_permissionQuery;
    bool allowed;
    try {
      allowed = await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      allowed = false;
      AdDiagnostics.record(
        AdFormat.consent,
        AdStage.loadFailed,
        failure: AdFailureKind.platform,
      );
    }
    if (query != _permissionQuery) return _permission.value;
    _permission.value = allowed;
    AdDiagnostics.record(
      AdFormat.consent,
      allowed ? AdStage.permissionAllowed : AdStage.permissionBlocked,
    );
    return allowed;
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
    } catch (_) {
      AdDiagnostics.record(
        AdFormat.consent,
        AdStage.loadFailed,
        failure: AdFailureKind.platform,
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
        AdDiagnostics.record(
          AdFormat.consent,
          AdStage.loadFailed,
          failure: AdFailureKind.sdk,
        );
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      await completer.future.timeout(_timeout);
      await _refreshPermission();
    } on TimeoutException {
      AdDiagnostics.record(AdFormat.consent, AdStage.timeout);
    }
  }

  static Future<void> _updateConsentInfo() {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      (formError) {
        AdDiagnostics.record(
          AdFormat.consent,
          AdStage.loadFailed,
          failure: AdFailureKind.sdk,
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
        AdDiagnostics.record(
          AdFormat.consent,
          AdStage.loadFailed,
          failure: AdFailureKind.sdk,
        );
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    return completer.future;
  }
}
