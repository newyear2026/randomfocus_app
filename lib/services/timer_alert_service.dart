import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

enum TimerAlertPhase { focus, breakTime }

abstract interface class TimerAlertController {
  Future<void> initialize();

  Future<void> requestPermissions();

  Future<void> schedule({
    required TimerAlertPhase phase,
    required Duration delay,
    required String title,
    required String body,
  });

  Future<void> cancel(TimerAlertPhase phase);

  Future<void> cancelAll();

  Future<void> vibrate(TimerAlertPhase phase);
}

class TimerAlertService implements TimerAlertController {
  TimerAlertService._();

  static final TimerAlertService instance = TimerAlertService._();

  static const int _focusNotificationId = 31001;
  static const int _breakNotificationId = 31002;
  static const String _channelId = 'timer_completion_v1';
  static const String _channelName = 'Timer completion';
  static const String _channelDescription =
      'Alerts when a focus or break timer finishes.';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  int _notificationId(TimerAlertPhase phase) => phase == TimerAlertPhase.focus
      ? _focusNotificationId
      : _breakNotificationId;

  @override
  Future<void> initialize() async {
    if (!_isSupportedPlatform || _initialized) return;

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('ic_stat_timer');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: false,
      defaultPresentBadge: false,
      defaultPresentSound: false,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _notifications.initialize(settings);
    _initialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    if (!_isSupportedPlatform) return;
    await initialize();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      // 정확 알람 권한은 요청하지 않는다. 매니페스트의 USE_EXACT_ALARM으로
      // 설치 시 부여되고, 플러그인의 requestExactAlarmsPermission은 권한이
      // 없을 때 시스템 설정 화면을 띄워 타이머 시작을 가로막는다. 권한이
      // 없는 기기에서는 schedule이 부정확 알람으로 알아서 내려간다.
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: false, sound: true);
    }
  }

  @override
  Future<void> schedule({
    required TimerAlertPhase phase,
    required Duration delay,
    required String title,
    required String body,
  }) async {
    if (!_isSupportedPlatform || delay <= Duration.zero) return;
    await initialize();

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canScheduleExactly =
        await androidPlugin?.canScheduleExactNotifications() ?? false;
    final scheduleMode = canScheduleExactly
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final vibrationPattern = phase == TimerAlertPhase.focus
        ? Int64List.fromList(<int>[0, 180, 110, 180])
        : Int64List.fromList(<int>[0, 360]);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      _notificationId(phase),
      title,
      body,
      tz.TZDateTime.now(tz.UTC).add(delay),
      details,
      androidScheduleMode: scheduleMode,
      payload: 'timer:${phase.name}',
    );
  }

  @override
  Future<void> cancel(TimerAlertPhase phase) async {
    if (!_isSupportedPlatform) return;
    await initialize();
    await _notifications.cancel(_notificationId(phase));
  }

  @override
  Future<void> cancelAll() async {
    if (!_isSupportedPlatform) return;
    await initialize();
    await _notifications.cancel(_focusNotificationId);
    await _notifications.cancel(_breakNotificationId);
  }

  @override
  Future<void> vibrate(TimerAlertPhase phase) async {
    if (kIsWeb) return;

    if (phase == TimerAlertPhase.focus) {
      await HapticFeedback.mediumImpact();
      await Future<void>.delayed(const Duration(milliseconds: 110));
      await HapticFeedback.mediumImpact();
      return;
    }

    await HapticFeedback.heavyImpact();
  }
}
