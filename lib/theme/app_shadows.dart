import 'package:flutter/material.dart';

/// 그림자 토큰.
///
/// 그림자는 "이 표면이 다른 표면 위에 떠 있다"는 정보를 전달할 때만 쓴다.
/// 장식 목적의 다중 그림자는 사용하지 않는다. 배지나 버튼처럼 색 대비만으로
/// 충분히 구분되는 요소는 그림자 없이 평면으로 둔다.
class AppShadows {
  /// 카드/시트가 배경 위에 올라가 있음을 나타내는 유일한 그림자.
  static List<BoxShadow> card(Color color) => [
    BoxShadow(
      color: color,
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  /// 기본 CTA는 채움색 대비로 충분히 두드러지므로 그림자를 두지 않는다.
  static List<BoxShadow> button(Color color) => const [];

  /// 아이콘 배지는 배경과의 색 대비로 구분한다.
  static List<BoxShadow> iconBadge(Color color) => const [];

  /// 통계 배지도 마찬가지로 평면을 유지한다.
  static List<BoxShadow> statBadge(Color color) => const [];
}
