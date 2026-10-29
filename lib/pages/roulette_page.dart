import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'timer_page.dart';
import 'focus_settings_page.dart';
import 'presets_page.dart';
import '../models/duration_weights.dart';
import '../services/focus_preferences.dart';
import '../services/pro_service.dart';
import '../services/app_localizations.dart';
import '../services/telemetry_service.dart';
import '../services/screen_tracking_observer.dart';
import '../theme/app_colors.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_screen.dart';
import '../widgets/roulette_result_sheet_content.dart';
import '../widgets/roulette_shell.dart';

class RoulettePage extends StatefulWidget {
  const RoulettePage({
    super.key,
    this.random,
    this.preferences,
    this.proService,
  });
  final Random? random;
  final FocusPreferences? preferences;
  final ProService? proService;

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> {
  // 룰렛 시간 옵션 (분 단위)
  late final _pro = widget.proService ?? ProService.instance;
  late final _preferences = widget.preferences ?? FocusPreferences.instance;
  late final _random = widget.random ?? Random();
  List<int>? _spinTimes;
  int? _pendingMinutes;
  bool _preferencesError = false;
  List<int> get _times =>
      _spinTimes ??
      (_pro.hasPro && _preferences.isLoaded
          ? _preferences.current.durations
          : DurationWeights.choices);
  late StreamController<int> _wheelController;
  int? _pendingIndex; // 룰렛 결과 (애니메이션 끝난 뒤 사용)

  /// 룰렛이 멈춰 있는 슬라이스. 라벨을 세우는 데만 쓴다 ([_labelAngle]).
  ///
  /// [_pendingIndex]와 달리 결과 창을 닫아도 비우지 않는다 — 룰렛은 마지막
  /// 결과 위치에 그대로 서 있기 때문이다.
  int _wheelIndex = 0;

  @override
  void initState() {
    super.initState();
    _wheelController = StreamController<int>();
    _pro.addListener(_onPreferencesChanged);
    _preferences.addListener(_onPreferencesChanged);
    unawaited(_loadPreferences());
  }

  Future<void> _loadPreferences() async {
    try {
      await _preferences.load();
    } catch (_) {
      if (mounted) setState(() => _preferencesError = true);
    }
    _onPreferencesChanged();
  }

  void _onPreferencesChanged() {
    if (mounted) {
      setState(() {
        if (_preferences.isLoaded) _preferencesError = false;
        // 시간 목록이 바뀌면 FortuneWheel의 ValueKey도 바뀌어 룰렛이 처음
        // 위치부터 다시 그려진다. 라벨 기준도 같이 되돌린다.
        _wheelIndex = 0;
      });
    }
  }

  void _openSettings(bool presets) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        settings: RouteSettings(
          name: presets
              ? RandomFocusScreen.presets.routeName
              : RandomFocusScreen.focusSettings.routeName,
        ),
        builder: (_) => presets
            ? PresetsPage(preferences: _preferences, proService: _pro)
            : FocusSettingsPage(preferences: _preferences, proService: _pro),
      ),
    );
  }

  @override
  void dispose() {
    _pro.removeListener(_onPreferencesChanged);
    _preferences.removeListener(_onPreferencesChanged);
    _wheelController.close();
    super.dispose();
  }

  void _onSpinPressed() async {
    if (_pendingIndex != null) {
      return;
    }

    if (!mounted) return;

    // 룰렛에서 선택될 index
    final times = List<int>.from(_times);
    final minutes = _pro.hasPro && _preferences.isLoaded
        ? _preferences.current.draw(_random)
        : times[_random.nextInt(times.length)];
    final index = times.indexOf(minutes);

    setState(() {
      _spinTimes = times;
      _pendingMinutes = minutes;
      _pendingIndex = index;
      _wheelIndex = index;
    });

    unawaited(TelemetryService.logEvent('roulette_spin_started'));

    // 룰렛 회전 시작
    if (times.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleWheelAnimationEnd();
      });
    } else {
      _wheelController.add(index);
    }
  }

  /// 슬라이스 [index]의 라벨을 세우기 위해 되돌릴 각도.
  ///
  /// flutter_fortune_wheel은 라벨을 반지름 방향으로 눕힌다. 멈춰 있을 때
  /// 라벨에 걸리는 각도는 `2π/n * (index - _wheelIndex) - π/2`이고
  /// (`_CircleSlices`의 슬라이스 회전 + `_CircleSliceLayout`의 `angle / 2`,
  /// 기본 `alignment: topCenter`라 정렬 오프셋은 0), 그래서 아래쪽 조각은
  /// 90도를 넘겨 뒤집힌다 — 60이 "06"으로 읽힌다. 그만큼 되돌려 둔다.
  ///
  /// 회전 중에는 룰렛 각도가 계속 변해 라벨도 같이 돌지만, 감속하며 멈출 때
  /// 제자리로 돌아온다.
  double _labelAngle(int index) {
    final anglePerItem = 2 * pi / _times.length;
    return pi / 2 - anglePerItem * (index - _wheelIndex);
  }

  void _handleWheelAnimationEnd() async {
    if (_pendingIndex == null) return;

    final selectedMinutes = _pendingMinutes!;

    unawaited(
      TelemetryService.logEvent(
        'roulette_result_viewed',
        parameters: {'focus_minutes': selectedMinutes},
      ),
    );

    if (!mounted) return;

    // 결과 창이 닫힌 뒤에만 회전 상태를 정리한다. Spin again은 이 처리
    // 이후에 시작해야 이전 회전의 정리 작업이 새 회전 결과를 지우지 않는다.
    final result = await _showResultDialog(selectedMinutes);

    if (!mounted) return;

    setState(() {
      _pendingIndex = null;
      _pendingMinutes = null;
      _spinTimes = null;
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
          settings: RouteSettings(name: RandomFocusScreen.timer.routeName),
          builder: (_) =>
              TimerPage(focusDuration: Duration(minutes: selectedMinutes)),
        ),
      );
    }
  }

  Future<String?> _showResultDialog(int selectedMinutes) {
    return showAppBottomSheet<String>(
      context: context,
      title: AppLocalizations.of(context)?.translate('result') ?? 'Result',
      variant: AppDialogVariant.info,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RouletteResultSheetContent(
            selectedMinutes: selectedMinutes,
            accentColor: _colorForTime(context, selectedMinutes),
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
      actions: [
        IconButton(
          tooltip: AppLocalizations.text(context, 'proCustomTimes'),
          onPressed: _pendingIndex == null ? () => _openSettings(false) : null,
          icon: const Icon(Icons.tune),
        ),
        IconButton(
          tooltip: AppLocalizations.text(context, 'proPresets'),
          onPressed: _pendingIndex == null ? () => _openSettings(true) : null,
          icon: const Icon(Icons.bookmarks_outlined),
        ),
      ],
      subtitle:
          l10n?.translate('spinToChoose') ?? 'Spin to choose your focus time',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RouletteShell(
            enabled: _pendingIndex == null,
            onSpinPressed: _onSpinPressed,
            spinLabel: l10n?.spin ?? 'Spin',
            spinSemanticsLabel: l10n?.spinWheel ?? 'Spin wheel',
            footer: _pro.hasPro
                ? Text(
                    _preferencesError
                        ? AppLocalizations.text(
                            context,
                            'focusSettingsLoadError',
                          )
                        : '${AppLocalizations.text(context, 'focusCustomSummary')}\n${_preferences.current.weights.entries.map((e) => '${e.key}: ${e.value}%').join(' · ')}',
                    textAlign: TextAlign.center,
                  )
                : null,
            wheel: _times.length == 1
                ? Semantics(
                    label:
                        '${_times.single} ${AppLocalizations.text(context, 'minutes')}',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.statusFill(
                          context,
                          AppColors.accent(context),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${_times.single}',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ),
                  )
                : FortuneWheel(
                    key: ValueKey(_times.join(',')),
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
                    items: <FortuneItem>[
                      for (var i = 0; i < _times.length; i++)
                        FortuneItem(
                          child: Transform.rotate(
                            angle: _labelAngle(i),
                            child: Text(
                              '${_times[i]}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          style: FortuneItemStyle(
                            color: _colorForTime(context, _times[i]),
                            borderColor: AppColors.surface(context),
                            borderWidth: 2,
                          ),
                        ),
                    ],
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
Color _colorForTime(BuildContext context, int minutes) {
  return AppColors.segmentColorForMinutes(
    minutes,
    dark: AppColors.isDark(context),
  );
}
