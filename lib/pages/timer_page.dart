import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:just_audio/just_audio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/history_service.dart';
import '../models/timer_history.dart';
import '../services/app_localizations.dart';
import '../services/interstitial_ad_manager.dart';
import '../widgets/banner_ad_widget.dart';

class TimerPage extends StatefulWidget {
  final int focusMinutes;

  const TimerPage({super.key, required this.focusMinutes});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

enum TimerState { focus, breakTime }

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  Timer? _timer;
  int _remainingSeconds = 0;
  TimerState _currentState = TimerState.focus;
  bool _isRunning = false;
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
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    InterstitialAdManager.instance.preload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
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
    } catch (error) {
      debugPrint('Failed to update wakelock: $error');
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
    if (_isRunning) {
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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          // 실제 진행 시간 추적 (집중 시간만)
          if (_currentState == TimerState.focus) {
            _elapsedSeconds++;
          }
        } else {
          // 비동기 함수를 제대로 처리
          _onTimerComplete();
        }
      });
    });
  }

  Future<void> _stopTimer() async {
    _timer?.cancel();

    // Stop 시 현재 세션을 중단으로 저장 (집중 시간이 진행 중이었다면)
    if (_currentState == TimerState.focus &&
        _sessionStartTime != null &&
        _elapsedSeconds > 0 &&
        !_sessionSaved) {
      await _saveSession(SessionStatus.stopped);
    }

    // 화면 잠금 해제 (다시 정상적으로 꺼질 수 있도록, 웹이 아닐 때만)
    await _setScreenAwake(false);

    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() async {
    _timer?.cancel();

    // 리셋 시 현재 세션을 중단으로 저장 (집중 시간이 진행 중이었다면)
    if (_currentState == TimerState.focus &&
        _sessionStartTime != null &&
        _elapsedSeconds > 0 &&
        !_sessionSaved) {
      await _saveSession(SessionStatus.stopped);
    }

    // 화면 잠금 해제 (다시 정상적으로 꺼질 수 있도록, 웹이 아닐 때만)
    await _setScreenAwake(false);

    setState(() {
      _isRunning = false;
      if (_currentState == TimerState.focus) {
        _remainingSeconds = _originalFocusSeconds;
        // 세션 초기화
        _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
        _sessionStartTime = null;
        _elapsedSeconds = 0;
        _sessionSaved = false;
      } else {
        _remainingSeconds = _originalBreakSeconds;
      }
    });
  }

  /// 뒤로 가기 확인 다이얼로그
  Future<void> _showBackDialog() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.goBack ?? '뒤로 가시겠습니까?'),
        content: Text(l10n?.goBackConfirm ?? '타이머 페이지를 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? '취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
            child: Text(l10n?.goBackButton ?? '뒤로 가기'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
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
      selectedTime: widget.focusMinutes,
      actualTime: _elapsedSeconds,
      status: status,
      notes: null,
    );

    await HistoryService.saveHistory(history);
    _sessionSaved = true;
  }

  void _onTimerComplete() {
    _timer?.cancel();

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
                _isRunning = false;
              });
              // 자동으로 휴식 타이머 시작 (화면은 계속 켜둠)
              _startTimer();
            }
          })
          .catchError((error) {
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
                _isRunning = false;
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

  double _getProgress() {
    if (_currentState == TimerState.focus) {
      return (_originalFocusSeconds - _remainingSeconds) /
          _originalFocusSeconds;
    } else {
      return (_originalBreakSeconds - _remainingSeconds) /
          _originalBreakSeconds;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _getStateColor();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.purple.shade50,
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: !_isRunning,
            leading: _isRunning
                ? null
                : IconButton(
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
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade500,
                    Colors.purple.shade400,
                  ],
                ),
              ),
            ),
            title: Column(
              children: [
                Text(
                  _getStateLabel(context),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.0,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.focusMinutes} ${AppLocalizations.of(context)?.seconds ?? 'seconds'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 큰 원형 타이머
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 320,
                        height: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 외곽 진행 링 (두꺼운 링) - 그라데이션 효과를 위한 컨테이너
                            Container(
                              width: 320,
                              height: 320,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  startAngle: 0,
                                  endAngle: 3.14159 * 2,
                                  colors: [
                                    stateColor.withOpacity(0.2),
                                    stateColor.withOpacity(0.1),
                                    stateColor.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: SizedBox(
                                width: 320,
                                height: 320,
                                child: CircularProgressIndicator(
                                  value: _getProgress(),
                                  strokeWidth: 22,
                                  backgroundColor: stateColor.withOpacity(0.12),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    stateColor,
                                  ),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ),
                            // 내부 원형 배경
                            Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey.shade50,
                                    Colors.white,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: stateColor.withOpacity(0.15),
                                    blurRadius: 25,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 상태 라벨
                                  Text(
                                    _getStateLabel(context),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey.shade900,
                                      letterSpacing: 1.2,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // 시간 표시
                                  Text(
                                    _formatTime(_remainingSeconds),
                                    style: TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey.shade900,
                                      fontFeatures: [
                                        const FontFeature.tabularFigures(),
                                      ],
                                      letterSpacing: -1,
                                      height: 1.1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // 상태 텍스트
                                  Text(
                                    _getStatusText(context),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Stop 버튼
                  if (_isRunning)
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [stateColor, stateColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: stateColor.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _stopTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.stop ?? 'Stop',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                              Shadow(
                                color: Colors.black12,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        // Start/Pause 버튼
                        Expanded(
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  stateColor,
                                  stateColor.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: stateColor.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _startTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: SizedBox(
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0.2),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              label: Text(
                                AppLocalizations.of(context)?.start ?? 'Start',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                    Shadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Reset 버튼
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Colors.grey.shade50],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _resetTimer,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey.shade100,
                                      Colors.white,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.refresh,
                                    size: 28,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  // 배너 광고
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: BannerAdWidget(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
