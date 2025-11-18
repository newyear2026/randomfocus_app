import 'dart:async';
import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/timer_history.dart';

class TimerPage extends StatefulWidget {
  final int focusMinutes;

  const TimerPage({super.key, required this.focusMinutes});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

enum TimerState { focus, breakTime }

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  TimerState _currentState = TimerState.focus;
  bool _isRunning = false;
  int _originalFocusSeconds = 0;
  final int _originalBreakSeconds = 5 * 60; // 5분 고정

  // 세션 추적 변수
  String? _sessionId;
  DateTime? _sessionStartTime;
  int _elapsedSeconds = 0; // 실제 진행된 시간 (초)
  bool _sessionSaved = false;

  @override
  void initState() {
    super.initState();
    // 테스트용: 초 단위로 변경 (원래는 widget.focusMinutes * 60)
    _originalFocusSeconds = widget.focusMinutes; // 초 단위로 직접 사용
    _remainingSeconds = _originalFocusSeconds;
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // 페이지를 벗어날 때 세션이 저장되지 않았고 실행 중이었다면 중단으로 저장
    if (!_sessionSaved && _sessionStartTime != null && _elapsedSeconds > 0) {
      _saveSession(SessionStatus.stopped);
    }
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    // 세션 시작 시간 기록
    if (_sessionStartTime == null && _currentState == TimerState.focus) {
      _sessionStartTime = DateTime.now();
      _elapsedSeconds = 0;
    }

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

  Future<void> _endSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Focus Session'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('End'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _stopTimer();
      Navigator.pop(context);
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

  void _onTimerComplete() async {
    _timer?.cancel();

    if (_currentState == TimerState.focus) {
      // 집중 시간 완료 -> 히스토리 저장 (completed 상태)
      await _saveSession(SessionStatus.completed);

      // 집중 시간 종료 -> 휴식 시간 시작
      setState(() {
        _currentState = TimerState.breakTime;
        _remainingSeconds = _originalBreakSeconds;
        _isRunning = false;
      });
      // 자동으로 휴식 타이머 시작
      _startTimer();
    } else {
      // 휴식 시간 종료 -> 룰렛 페이지로 돌아가기
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

  String _getStateLabel() {
    return _currentState == TimerState.focus ? 'Focus' : 'Break';
  }

  String _getStatusText() {
    if (!_isRunning && _remainingSeconds == _originalFocusSeconds) {
      return 'Ready';
    } else if (_isRunning) {
      return 'Running...';
    } else {
      return 'Paused';
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
    final progress = _getProgress();

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Column(
          children: [
            Text(
              _getStateLabel(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${widget.focusMinutes} seconds', // 테스트용: 초 단위
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // 큰 원형 타이머
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 외곽 진행 링 (두꺼운 링)
                        SizedBox(
                          width: 320,
                          height: 320,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 20,
                            backgroundColor: stateColor.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stateColor,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // 내부 원형 배경
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: stateColor.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 상태 라벨
                              Text(
                                _getStateLabel(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // 시간 표시
                              Text(
                                _formatTime(_remainingSeconds),
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade900,
                                  fontFeatures: [
                                    const FontFeature.tabularFigures(),
                                  ],
                                  letterSpacing: -2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // 상태 텍스트
                              Text(
                                _getStatusText(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
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
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _stopTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: stateColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: stateColor.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Stop',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    // Start/Pause 버튼
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _startTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: stateColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: stateColor.withOpacity(0.3),
                          ),
                          icon: const Icon(Icons.play_arrow, size: 24),
                          label: const Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Reset 버튼
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _resetTimer,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Icon(Icons.refresh, size: 24),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // End focus session 링크
              if (_currentState == TimerState.focus && _isRunning)
                TextButton(
                  onPressed: _endSession,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'End focus session',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
