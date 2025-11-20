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
  // 룰렛 시간 옵션 (분 단위)
  final _times = [25, 30, 45, 50, 60, 90]; // 분 단위
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

    final selectedMinutes = _times[_pendingIndex!]; // 분 단위
    final selectedSeconds = selectedMinutes * 60; // 초 단위로 변환

    if (!mounted) return;

    // 팝업 표시
    await _showResultDialog(selectedSeconds);

    // 타이머 페이지에서 돌아왔을 때 스핀 데이터 다시 로드
    _loadSpinInfo();

    // 다음 스핀을 위해 초기화
    setState(() {
      _pendingIndex = null;
    });
  }

  Future<void> _showResultDialog(int selectedSeconds) async {
    final selectedMinutes = selectedSeconds ~/ 60; // 분 단위로 변환
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        elevation: 24,
        title: Text(
          AppLocalizations.of(context)?.translate('result') ?? 'Result',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.deepPurple.shade900,
            letterSpacing: 1.5,
            height: 1.2,
            shadows: [
              Shadow(
                color: Colors.deepPurple.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _colorForTime(selectedSeconds).withOpacity(0.2),
                    _colorForTime(selectedSeconds).withOpacity(0.12),
                    _colorForTime(selectedSeconds).withOpacity(0.08),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _colorForTime(selectedSeconds).withOpacity(0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _colorForTime(selectedSeconds).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: _colorForTime(selectedSeconds).withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '$selectedMinutes',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: _colorForTime(selectedSeconds),
                      letterSpacing: 2.0,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: _colorForTime(
                            selectedSeconds,
                          ).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        Shadow(
                          color: _colorForTime(
                            selectedSeconds,
                          ).withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)?.minutes ?? 'minutes',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      height: 1.3,
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
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.3),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.15),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, 'spin_again'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple.shade800,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.translate('spinAgain') ??
                            'Spin Again',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Start Timer 버튼
                Flexible(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade600,
                          Colors.deepPurple,
                          Colors.purple.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, 'start_timer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.translate('startTimer') ??
                            'Start',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
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
      // 타이머 시작 (초 단위로 전달)
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TimerPage(focusMinutes: selectedSeconds), // 초 단위로 전달
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
                  AppLocalizations.of(context)?.appTitle ?? 'RandomFocus',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
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
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.translate('spinToChoose') ??
                      'Spin to choose your focus time',
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
                          fontSize: 18,
                          color: Colors.deepPurple.shade800,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
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
                                        indicators: <FortuneIndicator>[
                                          FortuneIndicator(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white,
                                                    Colors.white.withOpacity(
                                                      0.95,
                                                    ),
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.deepPurple
                                                        .withOpacity(0.4),
                                                    blurRadius: 12,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors
                                                          .deepPurple
                                                          .shade600,
                                                      Colors
                                                          .deepPurple
                                                          .shade800,
                                                    ],
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: TriangleIndicator(
                                                  color: Colors.white,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        items: _times
                                            .map(
                                              (t) => FortuneItem(
                                                child: Text(
                                                  '$t',
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: 1.0,
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
                                                style: FortuneItemStyle(
                                                  color: _colorForTime(
                                                    t * 60,
                                                  ), // 분을 초로 변환
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
                                    height: 68,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurple.shade600,
                                          Colors.deepPurple,
                                          Colors.purple.shade600,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                      borderRadius: BorderRadius.circular(36),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(
                                            0.5,
                                          ),
                                          blurRadius: 20,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
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
                                        borderRadius: BorderRadius.circular(36),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.white.withOpacity(
                                                        0.4,
                                                      ),
                                                      Colors.white.withOpacity(
                                                        0.25,
                                                      ),
                                                      Colors.white.withOpacity(
                                                        0.15,
                                                      ),
                                                    ],
                                                    stops: const [
                                                      0.0,
                                                      0.5,
                                                      1.0,
                                                    ],
                                                  ),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white
                                                          .withOpacity(0.3),
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 6,
                                                      spreadRadius: 0,
                                                      offset: const Offset(
                                                        0,
                                                        1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Colors.white
                                                            .withOpacity(0.2),
                                                        Colors.white
                                                            .withOpacity(0.1),
                                                      ],
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.autorenew,
                                                    size: 32,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 18),
                                              Text(
                                                AppLocalizations.of(
                                                      context,
                                                    )?.spin ??
                                                    'Spin',
                                                style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 2.0,
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

/// 시간별로 다른 색상 할당 (이미지와 동일한 색상 순서)
/// 분 단위 값에 맞게 색상 할당
/// 색상 순서: 주황(25), 빨강(30), 청록(45), 보라(50), 파랑(60), 분홍(90)
Color _colorForTime(int seconds) {
  final minutes = seconds ~/ 60; // 분 단위로 변환
  switch (minutes) {
    case 25:
      return const Color(0xFFFF9800); // 주황색
    case 30:
      return const Color(0xFFEF4444); // 빨간색
    case 45:
      return const Color(0xFF10B981); // 청록색
    case 50:
      return const Color(0xFF6366F1); // 보라색
    case 60:
      return const Color(0xFF3B82F6); // 파란색
    case 90:
      return const Color(0xFFEC4899); // 분홍색
    default:
      return const Color(0xFF6366F1); // 기본 보라색
  }
}
