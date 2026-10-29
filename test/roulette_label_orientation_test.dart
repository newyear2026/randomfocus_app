import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/duration_weights.dart';
import 'package:my_first_app/pages/roulette_page.dart';

/// 화면 기준으로 [finder]가 얼마나 돌아가 있는지. 0이면 똑바로 서 있다.
///
/// 공식을 다시 쓰는 대신 실제로 합성된 변환을 읽는다 — 패키지가 거는 회전과
/// 라벨이 되돌리는 회전이 함께 반영되므로, 어느 쪽이 바뀌어도 잡힌다.
double _screenRotation(WidgetTester tester, Finder finder) {
  final matrix = tester.renderObject<RenderBox>(finder).getTransformTo(null);
  final angle = math.atan2(matrix.storage[1], matrix.storage[0]);
  // -π..π로 정규화해 359도와 -1도가 다르게 읽히지 않게 한다.
  return math.atan2(math.sin(angle), math.cos(angle));
}

Finder _wheelLabel(int minutes) => find.descendant(
  of: find.byType(FortuneWheel),
  matching: find.text('$minutes'),
);

void main() {
  /// 뒤집힌 라벨은 `-π`에 가깝게 나온다. 60이 "06"으로 읽히던 문제가 이것이다.
  void expectAllLabelsUpright(WidgetTester tester) {
    for (final minutes in DurationWeights.choices) {
      expect(
        _screenRotation(tester, _wheelLabel(minutes)),
        closeTo(0, 0.01),
        reason: '$minutes분 라벨이 똑바로 서 있어야 한다',
      );
    }
  }

  testWidgets('룰렛 라벨은 처음부터 똑바로 서 있다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: RoulettePage()));
    await tester.pumpAndSettle();

    expectAllLabelsUpright(tester);
  });

  testWidgets('룰렛이 멈춘 뒤에도 라벨은 똑바로 서 있다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: RoulettePage(random: math.Random(7))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Spin'));
    await tester.pumpAndSettle();

    // 룰렛은 결과 위치에 그대로 서 있다. 이때도 라벨 기준이 따라와야 한다 —
    // 선택된 슬라이스를 추적하지 않으면 여기서 다시 뒤집힌다.
    expectAllLabelsUpright(tester);
  });
}
