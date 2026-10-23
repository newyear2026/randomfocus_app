import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'telemetry_service.dart';

enum AdFormat { banner, interstitial, consent }

enum AdStage {
  request,
  loadSucceeded,
  loadFailed,
  showRequested,
  shown,
  showFailed,
  impression,
  dismissed,
  timeout,
  sizeFallback,
  permissionAllowed,
  permissionBlocked,
  disposeFailed,
}

enum AdFailureKind { noFill, network, invalidRequest, internal, sdk, platform }

/// Records only lifecycle labels, process-local counters and safe SDK codes.
/// Never includes ad unit IDs, response info, exception messages or user data.
class AdDiagnostics {
  AdDiagnostics._();

  static int _nextRequestId = 0;

  @visibleForTesting
  static void Function(Map<String, Object>)? observer;

  static int beginRequest(AdFormat format) {
    final id = ++_nextRequestId;
    record(format, AdStage.request, requestId: id);
    return id;
  }

  static void record(
    AdFormat format,
    AdStage stage, {
    int? requestId,
    AdError? error,
    AdFailureKind? failure,
    bool refreshed = false,
  }) {
    final fields = <String, Object>{
      'format': format.name,
      'stage': stage.name,
      'request_id': ?requestId,
      if (error != null) ...{
        'error_code': error.code,
        'error_domain': _safeDomain(error.domain),
        'failure_kind': (failure ?? _classify(error)).name,
      } else if (failure != null)
        'failure_kind': failure.name,
      if (refreshed) 'refresh': 1,
    };
    debugPrint('AdDiagnostic: $fields');
    observer?.call(Map<String, Object>.unmodifiable(fields));
    unawaited(TelemetryService.logEvent('ad_lifecycle', parameters: fields));
    // Preserve existing nonfatal error channels, using only the safe fields.
    if (format != AdFormat.consent &&
        !refreshed &&
        (stage == AdStage.loadFailed || stage == AdStage.showFailed)) {
      final action = stage == AdStage.loadFailed ? 'load' : 'show';
      unawaited(
        TelemetryService.reportError(
          'Ad failure: $fields',
          StackTrace.current,
          reason: '${format.name}_ad_$action',
        ),
      );
    }
  }

  static String _safeDomain(String domain) => switch (domain) {
    'com.google.android.gms.ads' || 'com.google.admob' => domain,
    _ => 'other',
  };

  static AdFailureKind _classify(AdError error) {
    // Other platforms/adapters can assign different meanings to these codes.
    if (error.domain != 'com.google.android.gms.ads') return AdFailureKind.sdk;
    return switch (error.code) {
      3 => AdFailureKind.noFill,
      2 => AdFailureKind.network,
      1 => AdFailureKind.invalidRequest,
      0 => AdFailureKind.internal,
      _ => AdFailureKind.sdk,
    };
  }
}
