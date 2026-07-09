import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class TimerHeaderContent extends StatelessWidget {
  final String title;
  final String subtitle;

  const TimerHeaderContent({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.appBarTitle.copyWith(
            fontSize: 24,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.appBarSubtitle(context)),
      ],
    );
  }
}
