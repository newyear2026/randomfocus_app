import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppScreen extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final String? titleText;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final EdgeInsetsGeometry? bodyPadding;
  final Color? backgroundColor;
  final bool useSafeArea;

  const AppScreen({
    super.key,
    required this.body,
    this.title,
    this.titleText,
    this.subtitle,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.bodyPadding,
    this.backgroundColor,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBody = bodyPadding == null
        ? body
        : Padding(padding: bodyPadding!, child: body);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.screenBackground(context),
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: backgroundColor ?? Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: automaticallyImplyLeading,
          leading: leading,
          actions: actions,
          foregroundColor: AppColors.onAppBar(context),
          iconTheme: IconThemeData(color: AppColors.onAppBar(context)),
          actionsIconTheme: IconThemeData(color: AppColors.onAppBar(context)),
          // 앱바는 라이트/다크 모두 어두운 배경이므로 상태바 아이콘은 항상
          // 밝게 둔다. 시스템 네비게이션 바 아이콘만 현재 밝기를 따라간다.
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: AppColors.isDark(context)
                ? Brightness.light
                : Brightness.dark,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.appBarGradient(context),
              ),
            ),
          ),
          title:
              title ?? _ScreenTitle(titleText: titleText, subtitle: subtitle),
          centerTitle: true,
        ),
        body: useSafeArea ? SafeArea(child: resolvedBody) : resolvedBody,
      ),
    );
  }
}

class _ScreenTitle extends StatelessWidget {
  final String? titleText;
  final String? subtitle;

  const _ScreenTitle({required this.titleText, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    if (subtitle == null || subtitle!.isEmpty) {
      return Text(titleText ?? '', style: AppTextStyles.appBarTitle(context));
    }

    return Column(
      children: [
        Text(titleText ?? '', style: AppTextStyles.appBarTitle(context)),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle!, style: AppTextStyles.appBarSubtitle(context)),
      ],
    );
  }
}
