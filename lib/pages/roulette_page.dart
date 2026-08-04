import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'timer_page.dart';
import '../services/app_localizations.dart';
import '../services/telemetry_service.dart';
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

    unawaited(TelemetryService.logEvent('roulette_spin_started'));

    // 룰렛 회전 시작
    _wheelController.add(index);
  }

  void _handleWheelAnimationEnd() async {
    if (_pendingIndex == null) return;

    final selectedMinutes = _times[_pendingIndex!]; // 분 단위
    final selectedSeconds = selectedMinutes * 60; // 초 단위로 변환

    unawaited(
      TelemetryService.logEvent(
        'roulette_result_viewed',
        parameters: {'focus_minutes': selectedMinutes},
      ),
    );

    if (!mounted) return;

    // 결과 창이 닫힌 뒤에만 회전 상태를 정리한다. Spin again은 이 처리
    // 이후에 시작해야 이전 회전의 정리 작업이 새 회전 결과를 지우지 않는다.
    final result = await _showResultDialog(selectedSeconds);

    if (!mounted) return;

    setState(() {
      _pendingIndex = null;
    });

    unawaited(
      TelemetryService.logEvent(
        'roulette_result_action',
        parameters: {
          'action': result ?? 'dismissed',
          'focus_minutes': selectedMinutes,
        },
      ),
    );

    // result == null 은 사용자가 시트를 밀어 닫은 경우다. 취소한 것이므로
    // 타이머를 시작하지 않고 룰렛 화면에 그대로 머문다.
    if (result == 'spin_again') {
      _onSpinPressed();
    } else if (result == 'start_timer') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TimerPage(focusMinutes: selectedSeconds),
        ),
      );
    }
  }

  Future<String?> _showResultDialog(int selectedSeconds) {
    final selectedMinutes = selectedSeconds ~/ 60; // 분 단위로 변환
    return showAppBottomSheet<String>(
      context: context,
      title: AppLocalizations.of(context)?.translate('result') ?? 'Result',
      variant: AppDialogVariant.info,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RouletteResultSheetContent(
            selectedMinutes: selectedMinutes,
            accentColor: _colorForTime(context, selectedSeconds),
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
            enabled: _pendingIndex == null,
            onSpinPressed: _onSpinPressed,
            spinLabel: l10n?.spin ?? 'Spin',
            spinSemanticsLabel: l10n?.spinWheel ?? 'Spin wheel',
            wheel: FortuneWheel(
              selected: _wheelController.stream,
              onAnimationEnd: _handleWheelAnimationEnd,
              indicators: <FortuneIndicator>[
                // 삼각형 하나만으로 가리키는 위치를 표현한다. 원 배경을 덧대면
                // 삼각형이 잘려 포인터가 아니라 얼룩처럼 보인다.
                FortuneIndicator(
                  alignment: Alignment.topCenter,
                  child: TriangleIndicator(
                    color: AppColors.accentStrong(context),
                    width: 30,
                    height: 30,
                    elevation: 0,
                  ),
                ),
              ],
              items: _times
                  .map(
                    (t) => FortuneItem(
                      child: Text(
                        '$t',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: FortuneItemStyle(
                        color: _colorForTime(context, t * 60),
                        borderColor: AppColors.surface(context),
                        borderWidth: 2,
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

/// 시간별로 다른 색상 할당.
/// 색상 순서: 주황(25), 빨강(30), 청록(45), 보라(50), 파랑(60), 분홍(90)
/// 다크 모드에서는 채도를 낮춘 변형을 쓴다.
Color _colorForTime(BuildContext context, int seconds) {
  final minutes = seconds ~/ 60; // 분 단위로 변환
  return AppColors.segmentColorForMinutes(
    minutes,
    dark: AppColors.isDark(context),
  );
}
