import 'dart:async';
import 'package:flutter/material.dart';

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
  int _originalBreakSeconds = 5 * 60; // 5분 고정

  @override
  void initState() {
    super.initState();
    _originalFocusSeconds = widget.focusMinutes * 60;
    _remainingSeconds = _originalFocusSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_currentState == TimerState.focus) {
        _remainingSeconds = _originalFocusSeconds;
      } else {
        _remainingSeconds = _originalBreakSeconds;
      }
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();

    if (_currentState == TimerState.focus) {
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
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getStateLabel() {
    return _currentState == TimerState.focus ? 'Focus Time' : 'Break Time';
  }

  Color _getStateColor() {
    return _currentState == TimerState.focus ? Colors.green : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentState == TimerState.focus
                  ? Icons.timer
                  : Icons.coffee,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Random Pomodoro'),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 진행률 원형 표시기 추가
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: _currentState == TimerState.focus
                          ? (_originalFocusSeconds - _remainingSeconds) /
                              _originalFocusSeconds
                          : (_originalBreakSeconds - _remainingSeconds) /
                              _originalBreakSeconds,
                      strokeWidth: 8,
                      backgroundColor: _getStateColor().withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStateColor(),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getStateColor().withOpacity(0.15),
                          _getStateColor().withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getStateColor().withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getStateColor().withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _currentState == TimerState.focus
                              ? Icons.psychology
                              : Icons.coffee,
                          size: 40,
                          color: _getStateColor(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getStateLabel(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _getStateColor(),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: _getStateColor(),
                            fontFeatures: [
                              const FontFeature.tabularFigures(),
                            ],
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // 모바일 터치 최적화: 세로 배치로 변경하여 더 큰 터치 영역 제공
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 시작/일시정지 버튼 - 그라데이션 효과
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isRunning
                            ? [
                                Colors.orange.shade400,
                                Colors.orange.shade600,
                              ]
                            : [
                                Colors.deepPurple,
                                Colors.blue,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: (_isRunning
                                  ? Colors.orange
                                  : Colors.deepPurple)
                              .withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        size: 28,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isRunning ? 'Pause' : 'Start',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 재시작 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _resetTimer,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 24),
                      label: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_currentState == TimerState.focus) ...[
                const SizedBox(height: 32),
                Text(
                  'Focus time: ${widget.focusMinutes} minutes',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
