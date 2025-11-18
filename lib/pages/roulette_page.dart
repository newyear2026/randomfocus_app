import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'timer_page.dart';

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> {
  static const _maxSpinsPerDay = 2;
  final _times = [25, 35, 45, 50, 60, 90];
  late StreamController<int> _wheelController;
  int _spinsUsed = 0;
  bool _isLoading = true;
  int? _pendingIndex; // 룰렛 결과 (애니메이션 끝난 뒤 사용)

  bool get _hasSpinsLeft => _spinsUsed < _maxSpinsPerDay;

  @override
  void initState() {
    super.initState();
    _wheelController = StreamController<int>();
    _loadSpinInfo();
  }

  @override
  void dispose() {
    _wheelController.close();
    super.dispose();
  }

  Future<void> _loadSpinInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final savedDate = prefs.getString('spin_date');
    var used = prefs.getInt('spin_used') ?? 0;

    if (savedDate != todayStr) {
      // 날짜 바뀌면 초기화
      await prefs.setString('spin_date', todayStr);
      await prefs.setInt('spin_used', 0);
      used = 0;
    }

    setState(() {
      _spinsUsed = used;
      _isLoading = false;
    });
  }

  Future<void> _saveSpinsUsed(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('spin_used', value);
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

    // 스핀 사용 처리
    setState(() {
      _spinsUsed++;
    });
    await _saveSpinsUsed(_spinsUsed);

    // 타이머 페이지로 이동
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimerPage(focusMinutes: selectedMinutes),
      ),
    );

    // 타이머 페이지에서 돌아왔을 때 스핀 데이터 다시 로드
    _loadSpinInfo();

    // 다음 스핀을 위해 초기화
    setState(() {
      _pendingIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final attemptsText = 'Attempts today: $_spinsUsed / $_maxSpinsPerDay';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.casino, size: 24),
            const SizedBox(width: 8),
            const Text('Random Pomodoro'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(strokeWidth: 3),
                  const SizedBox(height: 24),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // 제목 섹션
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withOpacity(0.1),
                          Colors.blue.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎡 Random Timer',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Spin to choose your focus time',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 룰렛 UI with 그림자 효과
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 280,
                      width: 280,
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
                  const SizedBox(height: 40),
                  // 남은 횟수 - 개선된 디자인
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withOpacity(0.1),
                          Colors.blue.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.deepPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          attemptsText,
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Gira 버튼 - 그라데이션 효과
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: _hasSpinsLeft
                          ? LinearGradient(
                              colors: [
                                Colors.deepPurple,
                                Colors.blue,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: _hasSpinsLeft
                          ? [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _hasSpinsLeft ? _onSpinPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasSpinsLeft
                            ? Colors.transparent
                            : Colors.grey.shade300,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.autorenew,
                            color: _hasSpinsLeft ? Colors.white : Colors.grey,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Spin',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: _hasSpinsLeft ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_hasSpinsLeft)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.1),
                            Colors.amber.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.celebration,
                            color: Colors.orange.shade700,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Flexible(
                            child: Text(
                              'You\'ve used all attempts today.\nGreat work!',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
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
