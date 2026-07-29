import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayUpdateService {
  static const _lastPromptKey = 'last_play_update_prompt_at';
  static const _promptInterval = Duration(hours: 24);

  /// Google Play에 새 버전이 있는지 확인한다.
  ///
  /// Play Store에서 설치된 Android 앱에서만 동작하며, 다른 플랫폼과 오류
  /// 상황에서는 사용자 흐름을 방해하지 않도록 false를 반환한다.
  static Future<bool> isRecommendedUpdateAvailable() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      return updateInfo.updateAvailability ==
              UpdateAvailability.updateAvailable &&
          updateInfo.flexibleUpdateAllowed;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canShowPrompt() async {
    final preferences = await SharedPreferences.getInstance();
    final lastPromptMilliseconds = preferences.getInt(_lastPromptKey);
    if (lastPromptMilliseconds == null) return true;

    final lastPrompt = DateTime.fromMillisecondsSinceEpoch(
      lastPromptMilliseconds,
    );
    return DateTime.now().difference(lastPrompt) >= _promptInterval;
  }

  static Future<void> markPromptShown() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      _lastPromptKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Google Play의 유연한 업데이트 흐름을 시작하고 다운로드 완료 후 설치한다.
  static Future<void> startRecommendedUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    } catch (_) {
      // Google Play API를 사용할 수 없는 경우 현재 앱을 계속 사용할 수 있다.
    }
  }
}
