import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'timer_page.dart';
import '../services/spin_storage.dart';
import '../services/app_localizations.dart';

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> {
  // 테스트용: 초 단위로 변경 (원래는 분 단위였음: [25, 35, 45, 50, 60, 90])
  final _times = [5, 10, 15, 20, 25, 30]; // 초 단위 (테스트용)
  late StreamController<int> _wheelController;
  bool _isLoading = true;
  int? _pendingIndex; // 룰렛 결과 (애니메이션 끝난 뒤 사용)
  Timer? _dateCheckTimer; // 자정 체크용 타이머

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

    await SpinStorage.getSpinData();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSpinPressed() async {
    // 테스트용: _hasSpinsLeft 체크 제거
    if (_isLoading) {
      print('Spin button pressed but isLoading is true');
      return;
    }

    print('Spin button pressed! Starting spin...');

    // Spin 버튼을 누르는 순간 attempts 사용 처리
    await SpinStorage.useSpin();

    if (!mounted) return;

    // 룰렛에서 선택될 index
    final index = Random().nextInt(_times.length);
    print('Selected index: $index, time: ${_times[index]}');

    setState(() {
      _pendingIndex = index;
    });

    // 룰렛 회전 시작
    _wheelController.add(index);
    print('Wheel controller event sent');
  }

  void _handleWheelAnimationEnd() async {
    if (_pendingIndex == null) return;

    final selectedMinutes = _times[_pendingIndex!]; // 초 단위

    if (!mounted) return;

    // 팝업 표시
    await _showResultDialog(selectedMinutes);

    // 타이머 페이지에서 돌아왔을 때 스핀 데이터 다시 로드
    _loadSpinInfo();

    // 다음 스핀을 위해 초기화
    setState(() {
      _pendingIndex = null;
    });
  }

  Future<void> _showResultDialog(int selectedMinutes) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)?.translate('result') ?? 'Result',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
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
                    AppLocalizations.of(context)?.seconds ?? 'seconds',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 버튼들 - 가운데 정렬
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spin Again 버튼
                Flexible(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, 'spin_again'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.translate('spinAgain') ??
                          'Spin Again',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Start Timer 버튼
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'start_timer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.translate('startTimer') ??
                          'Start Timer',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result == 'spin_again') {
      // 다시 스핀하기
      setState(() {
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
                  AppLocalizations.of(context)?.appTitle ?? 'Random Pomodoro',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)?.translate('spinToChoose') ??
                      'Spin to choose your focus time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w500,
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
                        AppLocalizations.of(context)?.translate('loading') ??
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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 40,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // 메인 카드: 룰렛 + Spin 버튼
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.2),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 룰렛 (더 크고 현대적인 디자인)
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(
                                            0.25,
                                          ),
                                          blurRadius: 24,
                                          spreadRadius: 4,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.1),
                                          blurRadius: 40,
                                          spreadRadius: 8,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: SizedBox(
                                      height: 340,
                                      width: 340,
                                      child: FortuneWheel(
                                        selected: _wheelController.stream,
                                        onAnimationEnd:
                                            _handleWheelAnimationEnd,
                                        indicators: const <FortuneIndicator>[
                                          FortuneIndicator(
                                            alignment: Alignment.topCenter,
                                            child: TriangleIndicator(
                                              color: Colors.white,
                                              width: 20,
                                              height: 20,
                                            ),
                                          ),
                                        ],
                                        items: _times
                                            .map(
                                              (t) => FortuneItem(
                                                child: Text(
                                                  '$t',
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black26,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                style: FortuneItemStyle(
                                                  color: _colorForTime(t),
                                                  borderColor: Colors.white,
                                                  borderWidth: 3,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // Spin 버튼 - 현대적인 디자인
                                  Container(
                                    width: double.infinity,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple,
                                          Colors.purple.shade600,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(
                                            0.4,
                                          ),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _isLoading
                                            ? null
                                            : () {
                                                print(
                                                  'Button onPressed called',
                                                );
                                                _onSpinPressed();
                                              },
                                        borderRadius: BorderRadius.circular(32),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.autorenew,
                                                  size: 28,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                AppLocalizations.of(
                                                      context,
                                                    )?.spin ??
                                                    'Spin',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
                  },
                ),
        ),
      ),
    );
  }
}

/// 시간별로 다른 색상 할당 (현대적인 그라데이션 색상)
Color _colorForTime(int minutes) {
  switch (minutes) {
    case 5:
      return const Color(0xFF6366F1); // 인디고
    case 10:
      return const Color(0xFF8B5CF6); // 보라
    case 15:
      return const Color(0xFFEC4899); // 핑크
    case 20:
      return const Color(0xFFF59E0B); // 앰버
    case 25:
      return const Color(0xFFEF4444); // 레드
    case 30:
      return const Color(0xFF10B981); // 그린
    case 35:
      return const Color(0xFF06B6D4); // 시안
    case 45:
      return const Color(0xFF3B82F6); // 블루
    case 50:
      return const Color(0xFF6366F1); // 인디고
    case 60:
      return const Color(0xFF8B5CF6); // 보라
    case 90:
      return const Color(0xFFEC4899); // 핑크
    default:
      return const Color(0xFF6366F1); // 기본 인디고
  }
}
