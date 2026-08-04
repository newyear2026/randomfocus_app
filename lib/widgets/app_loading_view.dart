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
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accent(context),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              message!,
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
