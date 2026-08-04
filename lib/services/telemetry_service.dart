import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

/// Sends product signals and recoverable errors without interrupting the user.
class TelemetryService {
  TelemetryService._();

  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (Firebase.apps.isEmpty) return;

    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (error, stackTrace) {
      debugPrint('Analytics event failed ($name): $error');
      await reportError(error, stackTrace, reason: 'analytics_event_$name');
    }
  }

  static Future<void> reportError(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  }) async {
    if (Firebase.apps.isEmpty) return;

    debugPrint('Recoverable error ($reason): $error');

    // Crashlytics has no web implementation. Analytics events remain available
    // there, while errors are still visible in the development console.
    if (kIsWeb) return;

    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: false,
        reason: reason,
      );
    } catch (reportingError) {
      debugPrint('Crashlytics report failed: $reportingError');
    }
  }
}
