import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:just_audio/just_audio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/history_service.dart';
import '../models/timer_history.dart';
import '../services/ad_consent_service.dart';
import '../services/app_localizations.dart';
import '../services/interstitial_ad_manager.dart';
import '../services/telemetry_service.dart';
import '../services/timer_alert_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_screen.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/timer_header_content.dart';
import '../widgets/timer_completion_dialog.dart';
import '../widgets/timer_status_panel.dart';

class TimerPage extends StatefulWidget {
  final int focusMinutes;
  final Duration breakDuration;
  final Duration completionDialogDuration;
  final TimerAlertController? alertController;

  const TimerPage({
    super.key,
    required this.focusMinutes,
    this.breakDuration = const Duration(minutes: 10),
    this.completionDialogDuration = const Duration(milliseconds: 1500),
    this.alertController,
  }) : assert(focusMinutes > 0),
       assert(breakDuration > Duration.zero),
       assert(completionDialogDuration > Duration.zero);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

enum TimerState { focus, breakTime }

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  Timer? _ticker;
  Timer? _completionTimer;
  int _remainingSeconds = 0;
  Duration _remainingDuration = Duration.zero;
  DateTime? _deadline;
  TimerState _currentState = TimerState.focus;
  bool _isRunning = false;
  bool _isCompleting = false;
  bool _breakCompleted = false;
  bool _isPresentingCompletion = false;
  int _originalFocusSeconds = 0;
  late final int _originalBreakSeconds;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  // 세션 추적 변수
  String? _sessionId;
  DateTime? _sessionStartTime;
  int _elapsedSeconds = 0; // 실제 진행된 시간 (초)
  bool _sessionSaved = false;

  /// 진행 중인 히스토리 쓰기. 같은 세션이 두 번 기록되지 않게 붙잡아 둔다.
  Future<void>? _pendingSessionSave;

  // 사운드 재생용 AudioPlayer
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 타이머를 시작할 때마다 배너 광고에 재시도 예산을 다시 주는 신호.
  final ValueNotifier<int> _adRetryTrigger = ValueNotifier<int>(0);

  TimerAlertController get _alerts =>
      widget.alertController ?? TimerAlertService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _originalFocusSeconds = widget.focusMinutes; // 초 단위
    _originalBreakSeconds = widget.breakDuration.inSeconds;
    _remainingSeconds = _originalFocusSeconds;
    _remainingDuration = Duration(seconds: _originalFocusSeconds);
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    if (AdConsentService.canRequestAds) {
      InterstitialAdManager.instance.preload();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adRetryTrigger.dispose();
    _cancelTimers();
    unawaited(_cancelAlerts());
    _audioPlayer.dispose();
    // 떠나는 흐름(_showBackDialog)에서 이미 저장을 기다렸으므로 보통 여기서는
    // 할 일이 없다. 그 흐름을 타지 않고 화면이 사라진 경우를 위한 안전망이며,
    // dispose는 Future를 기다릴 수 없어 완료를 보장하지 못한다.
    unawaited(_saveStoppedSessionIfNeeded());
    // 화면 잠금 해제 (페이지를 벗어날 때, 웹이 아닐 때만)
    _setScreenAwake(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;

    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      unawaited(_cancelAlerts());
      unawaited(_setScreenAwake(_isRunning));
      if (_breakCompleted) {
        unawaited(_presentBreakCompletion());
        return;
      }
      _tick();
      return;
    }

    if (_isRunning &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden ||
            state == AppLifecycleState.detached)) {
      _captureRemainingFromClock();
      unawaited(_scheduleBackgroundAlerts());
    }
  }

  void _cancelTimers() {
    _ticker?.cancel();
    _ticker = null;
    _completionTimer?.cancel();
    _completionTimer = null;
  }

  int _displaySeconds(Duration duration) {
    if (duration <= Duration.zero) return 0;
    return (duration.inMilliseconds + Duration.millisecondsPerSecond - 1) ~/
        Duration.millisecondsPerSecond;
  }

  /// 종료 시각을 기준으로 남은 시간을 다시 계산한다.
  ///
  /// 주기 타이머는 화면만 갱신하며, 시간의 기준은 항상 [_deadline]이다.
  bool _captureRemainingFromClock() {
    final deadline = _deadline;
    if (deadline == null) return false;

    final remaining = deadline.difference(DateTime.now());
    _remainingDuration = remaining.isNegative ? Duration.zero : remaining;
    _remainingSeconds = _displaySeconds(_remainingDuration);

    if (_currentState == TimerState.focus) {
      final elapsedMilliseconds =
          (_originalFocusSeconds * Duration.millisecondsPerSecond) -
          _remainingDuration.inMilliseconds;
      _elapsedSeconds = (elapsedMilliseconds ~/ Duration.millisecondsPerSecond)
          .clamp(0, _originalFocusSeconds);
    }

    return _remainingDuration == Duration.zero;
  }

  void _tick() {
    if (!_isRunning || _isCompleting) return;

    final isComplete = _captureRemainingFromClock();
    if (isComplete) {
      unawaited(_onTimerComplete());
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setScreenAwake(bool enabled) async {
    if (kIsWeb) return;

    try {
      if (enabled) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }

      final isEnabled = await WakelockPlus.enabled;
      debugPrint('Wakelock state: requested=$enabled actual=$isEnabled');
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'wakelock_update',
      );
    }
  }

  bool get _isForeground => _lifecycleState == AppLifecycleState.resumed;

  /// 알림 권한을 이 화면에서 이미 요청했는지. 시작할 때마다 다시 묻지 않도록
  /// 한 번만 세운다. 요청이 겹치면 플러그인이 진행 중 오류를 돌려준다.
  bool _alertPermissionsRequested = false;

  Future<void> _requestAlertPermissions() async {
    try {
      await _alerts.requestPermissions();
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'timer_alert_permission',
      );
    }
  }

  Future<void> _scheduleBackgroundAlerts() async {
    if (!_shouldKeepBackgroundAlerts) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final scheduledState = _currentState;
    final scheduledRemaining = _remainingDuration;
    try {
      await _alerts.cancelAll();
      if (!_shouldKeepBackgroundAlerts) return;

      if (scheduledState == TimerState.focus) {
        await _alerts.schedule(
          phase: TimerAlertPhase.focus,
          delay: scheduledRemaining,
          title: l10n?.focusCompleteTitle ?? 'Focus complete',
          body:
              l10n?.focusCompleteBody ??
              'Great work. Your 10-minute break starts now.',
        );
        if (!_shouldKeepBackgroundAlerts) {
          await _alerts.cancelAll();
          return;
        }
        await _alerts.schedule(
          phase: TimerAlertPhase.breakTime,
          delay: scheduledRemaining + widget.breakDuration,
          title: l10n?.breakCompleteTitle ?? 'Break complete',
          body:
              l10n?.breakCompleteBody ??
              'Your break is over. Ready to focus again?',
        );
        if (!_shouldKeepBackgroundAlerts) {
          await _alerts.cancelAll();
        }
        return;
      }

      await _alerts.schedule(
        phase: TimerAlertPhase.breakTime,
        delay: scheduledRemaining,
        title: l10n?.breakCompleteTitle ?? 'Break complete',
        body:
            l10n?.breakCompleteBody ??
            'Your break is over. Ready to focus again?',
      );
      if (!_shouldKeepBackgroundAlerts) {
        await _alerts.cancelAll();
      }
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'timer_alert_schedule',
      );
    }
  }

  Future<void> _scheduleBreakAlertOnly() async {
    if (!_shouldKeepBackgroundAlerts) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final scheduledRemaining = _remainingDuration;
    try {
      await _alerts.schedule(
        phase: TimerAlertPhase.breakTime,
        delay: scheduledRemaining,
        title: l10n?.breakCompleteTitle ?? 'Break complete',
        body:
            l10n?.breakCompleteBody ??
            'Your break is over. Ready to focus again?',
      );
      if (!_shouldKeepBackgroundAlerts) {
        await _alerts.cancelAll();
      }
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'break_alert_schedule',
      );
    }
  }

  bool get _shouldKeepBackgroundAlerts =>
      mounted &&
      _isRunning &&
      !_isForeground &&
      _remainingDuration > Duration.zero;

  Future<void> _cancelAlerts() async {
    try {
      await _alerts.cancelAll();
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'timer_alert_cancel',
      );
    }
  }

  Future<void> _announceCompletion(TimerAlertPhase phase) async {
    if (!_isForeground) return;

    await _cancelAlerts();
    unawaited(_playStartSound());
    try {
      await _alerts.vibrate(phase);
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'timer_completion_haptic',
      );
    }
  }

  /// 전면 광고 표시
  void _showInterstitialAd() {
    unawaited(
      InterstitialAdManager.instance.show(
        onDismissed: () {
          if (mounted) {
            Navigator.pop(context);
          }
        },
        onUnavailable: () {
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  /// 사운드 재생 함수
  Future<void> _playStartSound() async {
    try {
      // 이전 재생이 있으면 중지 (에러 무시)
      try {
        await _audioPlayer.stop();
      } catch (e) {
        // 에러 무시
      }

      // just_audio는 setAsset을 먼저 호출하고 play()를 호출해야 함
      await _audioPlayer.setAsset('assets/sounds/START_SOUND.mp3');
      await _audioPlayer.play();
    } catch (e) {
      // 사운드 재생 실패 시 조용히 처리 (사용자 경험에 영향 없음)
    }
  }

  void _startTimer({
    bool announceStart = true,
    bool requestAlertPermission = true,
    bool scheduleBackgroundAlert = true,
  }) {
    if (_isRunning || _isCompleting || _remainingDuration == Duration.zero) {
      return;
    }

    // 세션 시작 시간 기록
    if (_sessionStartTime == null && _currentState == TimerState.focus) {
      _sessionStartTime = DateTime.now();
      _elapsedSeconds = 0;
    }

    if (requestAlertPermission && !_alertPermissionsRequested) {
      _alertPermissionsRequested = true;
      unawaited(_requestAlertPermissions());
    }

    // 자동 휴식 전환에서는 완료음이 이미 재생됐으므로 시작음을 반복하지 않는다.
    if (announceStart) {
      unawaited(_playStartSound());
    }

    // 화면이 꺼지지 않도록 설정 (웹이 아닐 때만)
    _setScreenAwake(true);

    setState(() {
      _isRunning = true;
    });

    // 초기 로드가 연달아 실패해 비어 있는 배너에 다시 기회를 준다.
    _adRetryTrigger.value++;

    _deadline = DateTime.now().add(_remainingDuration);
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    _completionTimer = Timer(
      _remainingDuration,
      () => unawaited(_onTimerComplete()),
    );
    unawaited(
      TelemetryService.logEvent(
        'focus_timer_started',
        parameters: {
          'phase': _currentState == TimerState.focus ? 'focus' : 'break',
          'focus_minutes': widget.focusMinutes ~/ 60,
        },
      ),
    );
    if (!_isForeground && scheduleBackgroundAlert) {
      unawaited(_scheduleBackgroundAlerts());
    }
    _tick();
  }

  Future<void> _stopTimer() async {
    final isComplete = _captureRemainingFromClock();
    if (isComplete) {
      unawaited(_onTimerComplete());
      return;
    }
    _cancelTimers();
    _deadline = null;
    await _cancelAlerts();

    // Stop 시 현재 세션을 중단으로 저장 (집중 시간이 진행 중이었다면)
    if (_currentState == TimerState.focus) {
      await _saveStoppedSessionIfNeeded();
    }

    // 화면 잠금 해제 (다시 정상적으로 꺼질 수 있도록, 웹이 아닐 때만)
    await _setScreenAwake(false);

    if (mounted) {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() async {
    _captureRemainingFromClock();
    _cancelTimers();
    _deadline = null;
    await _cancelAlerts();

    // 리셋 시 현재 세션을 중단으로 저장 (집중 시간이 진행 중이었다면)
    if (_currentState == TimerState.focus) {
      await _saveStoppedSessionIfNeeded();
    }

    // 화면 잠금 해제 (다시 정상적으로 꺼질 수 있도록, 웹이 아닐 때만)
    await _setScreenAwake(false);

    if (!mounted) return;
    setState(() {
      _isRunning = false;
      if (_currentState == TimerState.focus) {
        _remainingSeconds = _originalFocusSeconds;
        _remainingDuration = Duration(seconds: _originalFocusSeconds);
        // 세션 초기화
        _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
        _sessionStartTime = null;
        _elapsedSeconds = 0;
        _sessionSaved = false;
      } else {
        _remainingSeconds = _originalBreakSeconds;
        _remainingDuration = Duration(seconds: _originalBreakSeconds);
      }
    });
  }

  /// 뒤로 가기 확인 다이얼로그
  Future<void> _showBackDialog() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n?.goBack ?? '뒤로 가시겠습니까?',
      content: l10n?.goBackConfirm ?? '타이머 페이지를 나가시겠습니까?',
      cancelLabel: l10n?.cancel ?? '취소',
      confirmLabel: l10n?.goBackButton ?? '뒤로 가기',
      variant: AppDialogVariant.warning,
      confirmColor: AppColors.accent(context),
    );

    if (!confirmed || !mounted) return;

    // 화면을 떠나기 전에 중단 세션을 끝까지 저장한다. dispose는 Future를 기다릴
    // 수 없어 쓰기가 중간에 끊길 수 있으므로, 기다릴 수 있는 이 지점에서
    // 마무리한다. 저장 실패가 이탈을 막아서는 안 되므로 예외는 보고만 한다.
    try {
      await _saveStoppedSessionIfNeeded();
    } catch (error, stackTrace) {
      await TelemetryService.reportError(
        error,
        stackTrace,
        reason: 'history_save_before_timer_exit',
      );
    }

    if (!mounted) return;

    // 전면 광고 표시 (웹이 아닐 때만)
    if (!kIsWeb) {
      _showInterstitialAd();
    } else {
      // 웹에서는 바로 페이지 닫기
      Navigator.pop(context);
    }
  }

  /// 진행 중이던 집중 세션을 중단으로 저장한다.
  ///
  /// 저장할 세션이 없으면 아무 일도 하지 않으므로, 떠나는 경로마다 같은 조건을
  /// 늘어놓지 않아도 된다.
  Future<void> _saveStoppedSessionIfNeeded() {
    if (_sessionStartTime == null || _elapsedSeconds <= 0) {
      return Future<void>.value();
    }
    return _saveSession(SessionStatus.stopped);
  }

  /// 세션을 히스토리에 저장
  ///
  /// 저장이 이미 진행 중이면 그 Future를 그대로 돌려준다. 저장 완료 표시는
  /// 쓰기가 끝난 뒤에야 서기 때문에, 정지·리셋·화면 이탈이 겹치면 같은 세션이
  /// 두 번 기록될 수 있다.
  Future<void> _saveSession(SessionStatus status) {
    final pending = _pendingSessionSave;
    if (pending != null) return pending;
    if (_sessionSaved || _sessionId == null) return Future<void>.value();

    final future = _writeSession(status);
    _pendingSessionSave = future;
    return future;
  }

  Future<void> _writeSession(SessionStatus status) async {
    final history = TimerHistory(
      sessionId: _sessionId!,
      dateTime: DateTime.now(),
      // widget.focusMinutes는 초 단위로 전달되므로 분으로 정규화하여 저장
      selectedTime: widget.focusMinutes ~/ 60,
      actualTime: _elapsedSeconds,
      status: status,
      notes: null,
    );

    try {
      await HistoryService.saveHistory(history);
      _sessionSaved = true;
    } finally {
      _pendingSessionSave = null;
    }

    unawaited(
      TelemetryService.logEvent(
        status == SessionStatus.completed
            ? 'focus_session_completed'
            : 'focus_session_stopped',
        parameters: {
          'focus_minutes': widget.focusMinutes ~/ 60,
          'elapsed_seconds': _elapsedSeconds,
        },
      ),
    );
  }

  Future<void> _onTimerComplete() async {
    if (_isCompleting) return;
    _isCompleting = true;

    final completedDeadline = _deadline ?? DateTime.now();
    _captureRemainingFromClock();
    _cancelTimers();
    _deadline = null;
    _remainingDuration = Duration.zero;
    _remainingSeconds = 0;

    if (_currentState == TimerState.focus) {
      try {
        await _saveSession(SessionStatus.completed);
      } catch (error, stackTrace) {
        await TelemetryService.reportError(
          error,
          stackTrace,
          reason: 'history_save_after_focus_completion',
        );
      }

      if (!mounted) return;

      final breakDeadline = completedDeadline.add(widget.breakDuration);
      final breakRemaining = breakDeadline.difference(DateTime.now());

      // 앱으로 돌아왔을 때 휴식까지 이미 끝났다면 집중 완료와 휴식 완료를
      // 연달아 울리지 않고, 최종 상태인 휴식 완료만 안내한다.
      if (breakRemaining <= Duration.zero) {
        setState(() {
          _currentState = TimerState.breakTime;
          _remainingDuration = Duration.zero;
          _remainingSeconds = 0;
          _isRunning = false;
          _isCompleting = false;
          _breakCompleted = true;
        });
        unawaited(_setScreenAwake(false));
        if (_isForeground) {
          await _presentBreakCompletion();
        }
        return;
      }

      if (_isForeground) {
        await _announceCompletion(TimerAlertPhase.focus);
      }
      if (!mounted) return;

      final adjustedBreakRemaining = breakDeadline.difference(DateTime.now());
      if (adjustedBreakRemaining <= Duration.zero) {
        setState(() {
          _currentState = TimerState.breakTime;
          _remainingDuration = Duration.zero;
          _remainingSeconds = 0;
          _isRunning = false;
          _isCompleting = false;
          _breakCompleted = true;
        });
        unawaited(_setScreenAwake(false));
        if (_isForeground) {
          await _presentBreakCompletion();
        }
        return;
      }

      setState(() {
        _currentState = TimerState.breakTime;
        _remainingDuration = adjustedBreakRemaining;
        _remainingSeconds = _displaySeconds(adjustedBreakRemaining);
        _isRunning = false;
        _isCompleting = false;
      });
      // 백그라운드로 전환될 때 집중/휴식 완료 알림을 함께 예약했으므로,
      // 자동 휴식 전환 중에는 같은 알림을 다시 예약하지 않는다.
      _startTimer(
        announceStart: false,
        requestAlertPermission: false,
        scheduleBackgroundAlert: false,
      );
      if (!_isForeground) {
        unawaited(_scheduleBreakAlertOnly());
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _isCompleting = false;
      _breakCompleted = true;
    });
    unawaited(_setScreenAwake(false));
    if (_isForeground) {
      await _presentBreakCompletion();
    }
  }

  Future<void> _presentBreakCompletion() async {
    if (!mounted || !_breakCompleted || _isPresentingCompletion) return;

    _isPresentingCompletion = true;
    final l10n = AppLocalizations.of(context);
    unawaited(_announceCompletion(TimerAlertPhase.breakTime));

    try {
      await showTimerCompletionDialog(
        context: context,
        title: l10n?.breakCompleteTitle ?? 'Break complete',
        message:
            l10n?.breakCompleteBody ??
            'Your break is over. Ready to focus again?',
        returningLabel: l10n?.returningToWheel ?? 'Returning to Wheel',
        actionLabel: l10n?.goNow ?? 'Go now',
        autoCloseDuration: widget.completionDialogDuration,
      );
    } finally {
      _isPresentingCompletion = false;
    }

    if (mounted && _breakCompleted) {
      Navigator.of(context).pop();
    }
  }

  String _formatTime(int seconds) {
    // 분:초 형식으로 표시
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getStateLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _currentState == TimerState.focus
        ? (l10n?.focus ?? 'Focus')
        : (l10n?.breakTime ?? 'Break');
  }

  String _getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_breakCompleted) {
      return l10n?.completed ?? 'Completed';
    }
    if (!_isRunning && _remainingSeconds == _originalFocusSeconds) {
      return l10n?.ready ?? 'Ready';
    } else if (_isRunning) {
      return l10n?.running ?? 'Running...';
    } else {
      return l10n?.paused ?? 'Paused';
    }
  }

  Color _getStateColor(BuildContext context) {
    return _currentState == TimerState.focus
        ? AppColors.accent(context)
        : AppColors.info;
  }

  /// 현재 구간에서 실제로 지난 비율. 진행 링이 이 값으로 채워진다.
  double get _progress {
    final total = _currentState == TimerState.focus
        ? _originalFocusSeconds
        : _originalBreakSeconds;
    if (total <= 0) return 0;

    final remaining = _remainingDuration.inMilliseconds.clamp(
      0,
      total * Duration.millisecondsPerSecond,
    );
    final elapsed = (total * Duration.millisecondsPerSecond) - remaining;
    return (elapsed / (total * Duration.millisecondsPerSecond)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _getStateColor(context);
    final l10n = AppLocalizations.of(context);

    // Android의 시스템 뒤로가기는 앱바 닫기 버튼을 숨겨도 항상 열려 있는
    // 탈출구다. PopScope로 가로채 화면 안의 닫기 흐름과 동일하게 확인을 받는다.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showBackDialog();
      },
      child: _buildScreen(context, stateColor, l10n),
    );
  }

  Widget _buildScreen(
    BuildContext context,
    Color stateColor,
    AppLocalizations? l10n,
  ) {
    return AppScreen(
      automaticallyImplyLeading: !_isRunning,
      leading: _isRunning
          ? null
          : Semantics(
              button: true,
              label: l10n?.closeTimerPage ?? 'Close timer page',
              child: Tooltip(
                message: l10n?.closeTimerPage ?? 'Close timer page',
                child: IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  color: AppColors.onAppBar(context),
                  onPressed: _showBackDialog,
                ),
              ),
            ),
      title: TimerHeaderContent(
        title: _getStateLabel(context),
        // focusMinutes 는 초 단위로 전달되므로 사람이 읽는 분 단위로 환산한다.
        subtitle: '${widget.focusMinutes ~/ 60} ${l10n?.minutes ?? 'minutes'}',
      ),
      bodyPadding: AppSpacing.screenHorizontal,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TimerStatusPanel(
              stateColor: stateColor,
              stateLabel: _getStateLabel(context),
              timeLabel: _formatTime(_remainingSeconds),
              statusLabel: _getStatusText(context),
              isRunning: _isRunning,
              progress: _progress,
              startLabel: l10n?.start ?? 'Start',
              stopLabel: l10n?.stop ?? 'Stop',
              resetLabel: l10n?.resetTimer ?? 'Reset timer',
              progressSemanticsLabel:
                  l10n?.translate('focusProgress') ?? 'Focus progress',
              onStart: () => _startTimer(),
              onStop: _stopTimer,
              onReset: _resetTimer,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: BannerAdWidget(retryTrigger: _adRetryTrigger),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
