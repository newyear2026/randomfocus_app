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
    final attemptsText = 'Intentos de hoy: $_spinsUsed / $_maxSpinsPerDay';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro MX'),
        backgroundColor: const Color(0xFFA7D489), // 연한 라임
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🎡 Tu rueda de estudio',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gira para elegir tu tiempo',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  // 🔵 여기부터 진짜 룰렛 UI
                  SizedBox(
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
                  const SizedBox(height: 32),
                  // 남은 횟수
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F7E4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF8AC68A)),
                    ),
                    child: Text(
                      attemptsText,
                      style: const TextStyle(
                        color: Color(0xFF2F7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Gira 버튼
                  ElevatedButton(
                    onPressed: _hasSpinsLeft ? _onSpinPressed : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Girar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_hasSpinsLeft)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFEE58)),
                      ),
                      child: const Text(
                        'Hoy ya usaste tus intentos. ¡Buen trabajo!',
                        style: TextStyle(color: Color(0xFFB8860B)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

/// 시간별로 멕시칸 느낌 색을 다르게 주기
Color _colorForTime(int minutes) {
  switch (minutes) {
    case 25:
      return const Color(0xFFFF3D7F); // Fiesta Pink
    case 35:
      return const Color(0xFFFFBE0B); // Mango Yellow
    case 45:
      return const Color(0xFF6CC551); // Lime Green
    case 50:
      return const Color(0xFF00B3A4); // Turquoise
    case 60:
      return const Color(0xFF264653); // Cobalt-ish Blue
    case 90:
      return const Color(0xFFE4007C); // Mexican Pink
    default:
      return Colors.teal;
  }
}
