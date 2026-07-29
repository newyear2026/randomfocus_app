import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppVersion {
  const AppVersion({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  String get displayLabel => 'v$version ($buildNumber)';
  String get identifier => '$version+$buildNumber';
}

class AppVersionService {
  static const _seenUpdateNoticeKey = 'seen_update_notice_version';

  static Future<AppVersion> getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return AppVersion(version: info.version, buildNumber: info.buildNumber);
    } on Exception {
      // 위젯 테스트처럼 플랫폼 채널을 사용할 수 없는 환경을 위한 fallback.
      return const AppVersion(version: '1.1.3', buildNumber: '10');
    }
  }

  static Future<bool> shouldShowUpdateNotice(AppVersion version) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_seenUpdateNoticeKey) != version.identifier;
  }

  static Future<void> markUpdateNoticeSeen(AppVersion version) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_seenUpdateNoticeKey, version.identifier);
  }
}
