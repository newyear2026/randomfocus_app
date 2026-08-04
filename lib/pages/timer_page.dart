import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:just_audio/just_audio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/history_service.dart';
import '../models/timer_history.dart';
import '../services/app_localizations.dart';
import '../services/interstitial_ad_manager.dart';
import '../services/telemetry_service.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_screen.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/timer_header_content.dart';
import '../widgets/timer_status_panel.dart';

class TimerPage extends StatefulWidget {
  final int focusMinutes;

  const TimerPage({super.key, required this.focusMinutes});

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
  int _originalFocusSeconds = 0;
  final int _originalBreakSeconds = 600; // 10분 (600초)

  // 세션 추적 변수
  String? _sessionId;
  DateTime? _sessionStartTime;
  int _elapsedSeconds = 0; // 실제 진행된 시간 (초)
  bool _sessionSaved = false;

  // 사운드 재생용 AudioPlayer
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _originalFocusSeconds = widget.focusMinutes; // 초 단위
    _remainingSeconds = _originalFocusSeconds;
    _remainingDuration = Duration(seconds: _originalFocusSeconds);
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    InterstitialAdManager.instance.preload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelTimers();
    _audioPlayer.dispose();
    // 페이지를 벗어날 때 세션이 저장되지 않았고 실행 중이었다면 중단으로 저장
    if (!_sessionSaved && _sessionStartTime != null && _elapsedSeconds > 0) {
      _saveSession(SessionStatus.stopped);
    }
    // 화면 잠금 해제 (페이지를 벗어날 때, 웹이 아닐 때만)
    _setScreenAwake(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;

    if (state == AppLifecycleState.resumed) {
      _setScreenAwake(_isRunning);
      _tick();
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
      _onTimerComplete();
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

  /// 전면 광고 표시
  void _showInterstitialAd() {
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

  void _startTimer() {
    if (_isRunning || _isCompleting || _remainingDuration == Duration.zero) {
      return;
    }

    // 세션 시작 시간 기록
    if (_sessionStartTime == null && _currentState == TimerState.focus) {
      _sessionStartTime = DateTime.now();
      _elapsedSeconds = 0;
    }

    // Start 버튼 클릭 시 사운드 재생 (비동기로 실행, 에러는 무시)
    _playStartSound().catchError((error) {
      // 에러 무시
    });

    // 화면이 꺼지지 않도록 설정 (웹이 아닐 때만)
    _setScreenAwake(true);

    setState(() {
      _isRunning = true;
    });

    _deadline = DateTime.now().add(_remainingDuration);
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    _completionTimer = Timer(_remainingDuration, _onTimerComplete);
    unawaited(
      TelemetryService.logEvent(
        'focus_timer_started',
        parameters: {
          'phase': _currentState == TimerState.focus ? 'focus' : 'break',
          'focus_minutes': widget.focusMinutes ~/ 60,
        },
      ),
    );
    _tick();
  }

  Future<void> _stopTimer() async {
    final isComplete = _captureRemainingFromClock();
    if (isComplete) {
      _onTimerComplete();
      return;
    }
    _cancelTimers();
    _deadline = null;

    // Stop 시 현재 세션을 중단으로 저장 (집중 시간이 진행 중이었다면)
    if (_currentState == TimerState.focus &&
        _sessionStartTime != null &&
        _elapsedSeconds > 0 &&
        !_sessionSaved) {
      await _saveSession(SessionStatus.stopped);
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

    // 리셋 시 현재 세션을 중단으로 저장 (집중 시간이 진행 중이었다면)
    if (_currentState == TimerState.focus &&
        _sessionStartTime != null &&
        _elapsedSeconds > 0 &&
        !_sessionSaved) {
      await _saveSession(SessionStatus.stopped);
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
      confirmColor: Colors.deepPurple,
    );

    if (confirmed && mounted) {
      // 전면 광고 표시 (웹이 아닐 때만)
      if (!kIsWeb) {
        _showInterstitialAd();
      } else {
        // 웹에서는 바로 페이지 닫기
        Navigator.pop(context);
      }
    }
  }

  /// 세션을 히스토리에 저장
  Future<void> _saveSession(SessionStatus status) async {
    if (_sessionSaved || _sessionId == null) return;

    final history = TimerHistory(
      sessionId: _sessionId!,
      dateTime: DateTime.now(),
      // widget.focusMinutes는 초 단위로 전달되므로 분으로 정규화하여 저장
      selectedTime: widget.focusMinutes ~/ 60,
      actualTime: _elapsedSeconds,
      status: status,
      notes: null,
    );

    await HistoryService.saveHistory(history);
    _sessionSaved = true;
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

  void _onTimerComplete() {
    if (_isCompleting) return;
    _isCompleting = true;
    _captureRemainingFromClock();
    _cancelTimers();
    _deadline = null;
    _remainingDuration = Duration.zero;
    _remainingSeconds = 0;

    if (_currentState == TimerState.focus) {
      // 집중 시간 완료 -> 히스토리 저장 (completed 상태)
      _saveSession(SessionStatus.completed)
          .then((_) {
            // 저장 완료 후 휴식 시간 시작
            if (mounted) {
              // Focus가 끝나고 Break로 넘어갈 때 사운드 재생 (비동기로 실행)
              _playStartSound().catchError((error) {
                // 에러 무시
              });

              setState(() {
                _currentState = TimerState.breakTime;
                _remainingSeconds = _originalBreakSeconds;
                _remainingDuration = Duration(seconds: _originalBreakSeconds);
                _isRunning = false;
                _isCompleting = false;
              });
              // 자동으로 휴식 타이머 시작 (화면은 계속 켜둠)
              _startTimer();
            }
          })
          .catchError((error, stackTrace) {
            TelemetryService.reportError(
              error,
              stackTrace,
              reason: 'history_save_after_focus_completion',
            );
            // 세션 저장 실패 시 조용히 처리
            // 저장 실패해도 휴식 시간은 시작
            if (mounted) {
              // Focus가 끝나고 Break로 넘어갈 때 사운드 재생 (비동기로 실행)
              _playStartSound().catchError((error) {
                // 에러 무시
              });

              setState(() {
                _currentState = TimerState.breakTime;
                _remainingSeconds = _originalBreakSeconds;
                _remainingDuration = Duration(seconds: _originalBreakSeconds);
                _isRunning = false;
                _isCompleting = false;
              });
              _startTimer();
            }
          });
    } else {
      // 휴식 시간 종료 -> 화면 잠금 해제 후 룰렛 페이지로 돌아가기 (웹이 아닐 때만)
      _setScreenAwake(false);
      if (mounted) {
        Navigator.pop(context);
      }
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
    if (!_isRunning && _remainingSeconds == _originalFocusSeconds) {
      return l10n?.ready ?? 'Ready';
    } else if (_isRunning) {
      return l10n?.running ?? 'Running...';
    } else {
      return l10n?.paused ?? 'Paused';
    }
  }

  Color _getStateColor() {
    return _currentState == TimerState.focus
        ? Colors.deepPurple
        : Colors.blue.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _getStateColor();
    final l10n = AppLocalizations.of(context);

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
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onPressed: _showBackDialog,
                ),
              ),
            ),
      title: TimerHeaderContent(
        title: _getStateLabel(context),
        subtitle: '${widget.focusMinutes} ${l10n?.seconds ?? 'seconds'}',
      ),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              startLabel: l10n?.start ?? 'Start',
              stopLabel: l10n?.stop ?? 'Stop',
              resetLabel: l10n?.resetTimer ?? 'Reset timer',
              onStart: _startTimer,
              onStop: _stopTimer,
              onReset: _resetTimer,
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: BannerAdWidget(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
