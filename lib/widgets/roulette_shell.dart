import 'package:flutter/material.dart';

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
                  radius: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 4,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.1),
                              blurRadius: 40,
                              spreadRadius: 8,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: wheelSize,
                          width: wheelSize,
                          child: wheel,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AppPrimaryButton(
                        width: double.infinity,
                        height: 68,
                        borderRadius: BorderRadius.circular(36),
                        onPressed: enabled ? onSpinPressed : null,
                        label: spinLabel,
                        textStyle: AppTextStyles.largeButtonLabel,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Semantics(
                            label: spinSemanticsLabel,
                            child: const Icon(
                              Icons.autorenew,
                              size: 32,
                              color: Colors.white,
                            ),
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
