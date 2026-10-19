import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

Future<void> showTimerCompletionDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String returningLabel,
  required String actionLabel,
  Duration autoCloseDuration = const Duration(milliseconds: 1500),
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => TimerCompletionDialog(
      title: title,
      message: message,
      returningLabel: returningLabel,
      actionLabel: actionLabel,
      autoCloseDuration: autoCloseDuration,
    ),
  );
}

class TimerCompletionDialog extends StatefulWidget {
  final String title;
  final String message;
  final String returningLabel;
  final String actionLabel;
  final Duration autoCloseDuration;

  const TimerCompletionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.returningLabel,
    required this.actionLabel,
    this.autoCloseDuration = const Duration(milliseconds: 1500),
  }) : assert(autoCloseDuration > Duration.zero);

  @override
  State<TimerCompletionDialog> createState() => _TimerCompletionDialogState();
}

class _TimerCompletionDialogState extends State<TimerCompletionDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.autoCloseDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              Navigator.of(context).pop();
            }
          });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _remainingLabel(double progress) {
    final remainingMilliseconds =
        (widget.autoCloseDuration.inMilliseconds * (1 - progress)).ceil();
    final remainingSeconds = remainingMilliseconds / 1000;
    return '${remainingSeconds.toStringAsFixed(1)}s';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        icon: Icon(Icons.vibration, color: AppColors.accent(context), size: 30),
        title: Text(widget.title, style: AppTextStyles.sectionTitle(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.message,
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Semantics(
                  label:
                      '${widget.returningLabel} ${_remainingLabel(_controller.value)}',
                  child: ExcludeSemantics(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.returningLabel,
                                style: AppTextStyles.statLabel(context),
                              ),
                            ),
                            Text(
                              _remainingLabel(_controller.value),
                              style: AppTextStyles.statLabel(
                                context,
                              ).copyWith(color: AppColors.textPrimary(context)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        LinearProgressIndicator(
                          value: 1 - _controller.value,
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(2),
                          color: AppColors.accent(context),
                          backgroundColor: AppColors.surfaceMuted(context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.actionLabel),
          ),
        ],
      ),
    );
  }
}
