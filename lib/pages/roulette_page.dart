import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'timer_page.dart';
import '../services/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_screen.dart';
import '../widgets/roulette_result_sheet_content.dart';
import '../widgets/roulette_shell.dart';

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> {
  // 룰렛 시간 옵션 (분 단위)
  final _times = [25, 30, 45, 50, 60, 90]; // 분 단위
  late StreamController<int> _wheelController;
  int? _pendingIndex; // 룰렛 결과 (애니메이션 끝난 뒤 사용)

  @override
  void initState() {
    super.initState();
    _wheelController = StreamController<int>();
  }

  @override
  void dispose() {
    _wheelController.close();
    super.dispose();
  }

  void _onSpinPressed() async {
    if (_pendingIndex != null) {
      return;
    }

    if (!mounted) return;

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

    final selectedMinutes = _times[_pendingIndex!]; // 분 단위
    final selectedSeconds = selectedMinutes * 60; // 초 단위로 변환

    if (!mounted) return;

    // 팝업 표시
    await _showResultDialog(selectedSeconds);

    // 다음 스핀을 위해 초기화
    setState(() {
      _pendingIndex = null;
    });
  }

  Future<void> _showResultDialog(int selectedSeconds) async {
    final selectedMinutes = selectedSeconds ~/ 60; // 분 단위로 변환
    final result = await showAppBottomSheet<String>(
      context: context,
      title: AppLocalizations.of(context)?.translate('result') ?? 'Result',
      variant: AppDialogVariant.info,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RouletteResultSheetContent(
            selectedMinutes: selectedMinutes,
            accentColor: _colorForTime(selectedSeconds),
            minutesLabel: AppLocalizations.of(context)?.minutes ?? 'minutes',
            spinAgainLabel:
                AppLocalizations.of(context)?.translate('spinAgain') ??
                'Spin Again',
            startLabel:
                AppLocalizations.of(context)?.translate('startTimer') ??
                'Start',
            onSpinAgain: () => Navigator.pop(context, 'spin_again'),
            onStart: () => Navigator.pop(context, 'start_timer'),
          ),
        ],
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
    final l10n = AppLocalizations.of(context);

    return AppScreen(
      titleText: l10n?.appTitle ?? 'RandomFocus',
      subtitle:
          l10n?.translate('spinToChoose') ?? 'Spin to choose your focus time',
      body: LayoutBuilder(
              builder: (context, constraints) {
                return RouletteShell(
                  enabled: true,
                  onSpinPressed: _onSpinPressed,
                  spinLabel: l10n?.spin ?? 'Spin',
                  spinSemanticsLabel: l10n?.spinWheel ?? 'Spin wheel',
                  wheel: FortuneWheel(
                    selected: _wheelController.stream,
                    onAnimationEnd: _handleWheelAnimationEnd,
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
                                Colors.white.withValues(alpha: 0.95),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
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
                                  Colors.deepPurple.shade600,
                                  Colors.deepPurple.shade800,
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
                              color: _colorForTime(t * 60),
                              borderColor: Colors.white,
                              borderWidth: 3,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
    );
  }
}

/// 시간별로 다른 색상 할당 (이미지와 동일한 색상 순서)
/// 분 단위 값에 맞게 색상 할당
/// 색상 순서: 주황(25), 빨강(30), 청록(45), 보라(50), 파랑(60), 분홍(90)
Color _colorForTime(int seconds) {
  final minutes = seconds ~/ 60; // 분 단위로 변환
  return AppColors.segmentColorForMinutes(minutes);
}
