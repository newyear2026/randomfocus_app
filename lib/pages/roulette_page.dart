import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'timer_page.dart';
import '../services/spin_storage.dart';

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> {
  final _times = [25, 35, 45, 50, 60, 90];
  late StreamController<int> _wheelController;
  int _spinsUsed = 0;
  int _maxSpinsPerDay = 2;
  bool _isLoading = true;
  int? _pendingIndex; // 룰렛 결과 (애니메이션 끝난 뒤 사용)
  Timer? _dateCheckTimer; // 자정 체크용 타이머

  bool get _hasSpinsLeft => _spinsUsed < _maxSpinsPerDay;

  @override
  void initState() {
    super.initState();
    _wheelController = StreamController<int>();
    _loadSpinInfo();
    _startDateCheckTimer();
  }

  @override
  void dispose() {
    _wheelController.close();
    _dateCheckTimer?.cancel();
    super.dispose();
  }

  /// 자정 체크 타이머 시작 (1분마다 체크)
  void _startDateCheckTimer() {
    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final isDateChanged = await SpinStorage.isDateChanged();
      if (isDateChanged && mounted) {
        // 자정이 지났으면 자동으로 리셋
        _loadSpinInfo();
      }
    });
  }

  /// 스핀 정보 로드 (SpinStorage 서비스 사용)
  Future<void> _loadSpinInfo() async {
    setState(() {
      _isLoading = true;
    });

    final spinData = await SpinStorage.getSpinData();

    if (mounted) {
      setState(() {
        _spinsUsed = spinData['used'] as int;
        _maxSpinsPerDay = spinData['maxSpins'] as int;
        _isLoading = false;
      });
    }
  }

  void _onSpinPressed() {
    if (!_hasSpinsLeft || _isLoading) return;

    // 룰렛에서 선택될 index
    final index = Random().nextInt(_times.length);

    setState(() {
      _pendingIndex = index;
    });

    // 룰렛 회전 시작
    _wheelController.add(index);
  }

  void _handleWheelAnimationEnd() async {
    if (_pendingIndex == null) return;

    final selectedMinutes = _times[_pendingIndex!];
    // 스핀 사용 전에 기회가 남아있는지 확인
    final canSpinAgain = _spinsUsed < _maxSpinsPerDay - 1;

    // 스핀 사용 처리 (SpinStorage 서비스 사용)
    final spinData = await SpinStorage.useSpin();

    if (!mounted) return;

    // 상태 업데이트
    setState(() {
      _spinsUsed = spinData['used'] as int;
    });

    // 팝업 표시
    await _showResultDialog(selectedMinutes, canSpinAgain);

    // 타이머 페이지에서 돌아왔을 때 스핀 데이터 다시 로드
    _loadSpinInfo();

    // 다음 스핀을 위해 초기화
    setState(() {
      _pendingIndex = null;
    });
  }

  Future<void> _showResultDialog(int selectedMinutes, bool canSpinAgain) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              color: _colorForTime(selectedMinutes),
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Result',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _colorForTime(selectedMinutes).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _colorForTime(selectedMinutes).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$selectedMinutes',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _colorForTime(selectedMinutes),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'minutes',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (canSpinAgain)
              Text(
                'You have 1 more chance to spin!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              )
            else
              Column(
                children: [
                  Text(
                    'This is your last attempt!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Starting timer now...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
        actions: [
          if (canSpinAgain) ...[
            TextButton(
              onPressed: () => Navigator.pop(context, 'spin_again'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Spin Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'start_timer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              canSpinAgain ? 'Start Timer' : 'Continue',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result == 'spin_again') {
      // 다시 스핀하기 - 스핀 사용 취소
      await SpinStorage.cancelSpin();
      setState(() {
        _spinsUsed = (_spinsUsed - 1).clamp(0, _maxSpinsPerDay);
        _pendingIndex = null;
      });
      _onSpinPressed();
    } else if (result == 'start_timer' || result == null) {
      // 타이머 시작
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TimerPage(focusMinutes: selectedMinutes),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attemptsText = '$_spinsUsed / $_maxSpinsPerDay';

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Column(
          children: [
            const Text(
              'Random Pomodoro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Spin to choose your focus time',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 메인 카드: 룰렛 + Attempts + Spin 버튼
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 룰렛
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.15),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 260,
                            width: 260,
                            child: FortuneWheel(
                              selected: _wheelController.stream,
                              onAnimationEnd: _handleWheelAnimationEnd,
                              indicators: const <FortuneIndicator>[
                                FortuneIndicator(
                                  alignment: Alignment.topCenter,
                                  child: TriangleIndicator(color: Colors.white),
                                ),
                              ],
                              items: _times
                                  .map(
                                    (t) => FortuneItem(
                                      child: Text(
                                        '$t',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: FortuneItemStyle(
                                        color: _colorForTime(t),
                                        borderColor: Colors.white,
                                        borderWidth: 2,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Attempts 표시
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.deepPurple.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.deepPurple.shade700,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Attempts today: $attemptsText',
                                style: TextStyle(
                                  color: Colors.deepPurple.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Spin 버튼 - 터치 영역 최적화
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: (_hasSpinsLeft && !_isLoading)
                                ? _onSpinPressed
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              disabledBackgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.grey,
                              elevation: _hasSpinsLeft ? 4 : 0,
                              shadowColor: Colors.deepPurple.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.autorenew,
                                  size: 26,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Spin',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}

/// 시간별로 다른 색상 할당
Color _colorForTime(int minutes) {
  switch (minutes) {
    case 25:
      return Colors.pink.shade400;
    case 35:
      return Colors.amber.shade600;
    case 45:
      return Colors.green.shade500;
    case 50:
      return Colors.cyan.shade500;
    case 60:
      return Colors.blue.shade700;
    case 90:
      return Colors.purple.shade600;
    default:
      return Colors.teal;
  }
}
