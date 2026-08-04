import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 앱 전역 타이포그래피 토큰.
///
/// 색을 가진 스타일은 라이트/다크를 모두 지원하기 위해 `BuildContext`를 받는다.
/// 텍스트 그림자는 사용하지 않는다. 대비는 색으로 확보하고, 그림자는 오히려
/// 글자 가장자리를 흐리게 만들어 가독성을 떨어뜨린다.
class AppTextStyles {
  /// `ThemeData` 처럼 context가 없는 곳에서 쓰는 앱바 타이틀 기본형.
  /// 색은 `AppBarTheme.foregroundColor` 가 채운다.
  static const appBarTitleBase = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.25,
  );

  static TextStyle appBarTitle(BuildContext context) =>
      appBarTitleBase.copyWith(color: AppColors.onAppBar(context));

  static TextStyle appBarSubtitle(BuildContext context) => TextStyle(
    fontSize: 13,
    color: AppColors.onAppBar(context).withValues(alpha: 0.85),
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static TextStyle sectionTitle(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.3,
    color: AppColors.textPrimary(context),
  );

  /// 폼 그룹 위에 붙는 작은 라벨 (예: "환경설정", "정보").
  static TextStyle groupLabel(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.3,
    color: AppColors.textSecondary(context),
  );

  static TextStyle tileTitle(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.35,
    color: AppColors.textPrimary(context),
  );

  static TextStyle tileSubtitle(BuildContext context) => TextStyle(
    fontSize: 14,
    color: AppColors.textMuted(context),
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: 15,
    height: 1.6,
    color: AppColors.textSecondary(context),
    letterSpacing: 0.1,
  );

  /// 버튼 라벨. 색은 버튼의 `foregroundColor` 가 채운다.
  static const buttonLabel = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static const largeButtonLabel = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle statValue(BuildContext context) => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary(context),
    height: 1.15,
    letterSpacing: 0.1,
  );

  static TextStyle statLabel(BuildContext context) => TextStyle(
    fontSize: 12,
    color: AppColors.textMuted(context),
    height: 1.25,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle timerDisplay(BuildContext context) => TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary(context),
    fontFeatures: const [FontFeature.tabularFigures()],
    letterSpacing: -1,
    height: 1.1,
  );
}
