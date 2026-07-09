import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppLoadingView extends StatelessWidget {
  final String? message;
  final double indicatorSize;

  const AppLoadingView({super.key, this.message, this.indicatorSize = 40});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              message!,
              style: AppTextStyles.tileSubtitle(context).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.deepPurple.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
