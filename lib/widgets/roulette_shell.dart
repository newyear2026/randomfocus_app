import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';
import 'app_action_button.dart';
import 'app_section_card.dart';

class RouletteShell extends StatelessWidget {
  final Widget wheel;
  final String spinLabel;
  final String spinSemanticsLabel;
  final VoidCallback? onSpinPressed;
  final bool enabled;

  const RouletteShell({
    super.key,
    required this.wheel,
    required this.spinLabel,
    required this.spinSemanticsLabel,
    this.onSpinPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final cardPadding = isTablet ? 40.0 : 24.0;
        final wheelSize = isTablet
            ? 380.0
            : (constraints.maxWidth - 88).clamp(220.0, 340.0);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 32.0 : 20.0,
            20.0,
            isTablet ? 32.0 : 20.0,
            8.0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                AppSectionCard(
                  padding: EdgeInsets.all(cardPadding),
                  radius: AppRadius.cardLarge,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: wheelSize,
                        width: wheelSize,
                        child: wheel,
                      ),
                      const SizedBox(height: 40),
                      AppPrimaryButton(
                        width: double.infinity,
                        height: 68,
                        borderRadius: AppRadius.heroButtonBorder,
                        onPressed: enabled ? onSpinPressed : null,
                        label: spinLabel,
                        textStyle: AppTextStyles.largeButtonLabel,
                        leading: Semantics(
                          label: spinSemanticsLabel,
                          child: Icon(
                            Icons.autorenew,
                            size: 28,
                            color: AppColors.onAccent(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
