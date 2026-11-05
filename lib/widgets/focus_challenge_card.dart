import 'dart:async';

import 'package:flutter/material.dart';

import '../models/focus_challenge.dart';
import '../services/app_localizations.dart';
import '../services/focus_challenge_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Shows how many focus days have been collected, and the badge once seven
/// are in.
///
/// Deliberately not a "Day 1 … Day 7" row: the days do not have to be
/// consecutive, and numbering them reads as a streak the user can break.
class FocusChallengeCard extends StatelessWidget {
  const FocusChallengeCard({super.key, this.service});

  final FocusChallengeService? service;

  @override
  Widget build(BuildContext context) => _FocusChallengeBuilder(
    service: service ?? FocusChallengeService.instance,
    builder: (context, service, failed, retry) {
      if (failed || service.needsRecovery) {
        return _Card(
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  AppLocalizations.text(context, 'focusChallengeLoadError'),
                  style: AppTextStyles.tileSubtitle(context),
                ),
              ),
              TextButton(
                onPressed: retry,
                child: Text(AppLocalizations.text(context, 'refresh')),
              ),
            ],
          ),
        );
      }
      if (!service.isLoaded) return const SizedBox.shrink();

      final challenge = service.challenge;
      final l10n = AppLocalizations.of(context);
      final accent = AppColors.accent(context);
      final complete = challenge.isComplete;
      final today = FocusChallenge.dateKey(service.now());

      final progressLabel =
          l10n?.translateWithParams('focusChallengeProgress', {
            'done': '${challenge.progress}',
            'total': '${FocusChallenge.goalDays}',
          }) ??
          '${challenge.progress} / ${FocusChallenge.goalDays}';
      final semanticsLabel =
          l10n?.translateWithParams('focusChallengeProgressSemantics', {
            'done': '${challenge.progress}',
            'total': '${FocusChallenge.goalDays}',
          }) ??
          progressLabel;

      return _Card(
        key: const ValueKey('focus-challenge-card'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.statusFill(
                  context,
                  complete ? AppColors.statusSuccess(context) : accent,
                ),
                borderRadius: AppRadius.tileBorder,
              ),
              child: Icon(
                complete ? Icons.workspace_premium : Icons.flag_outlined,
                color: complete ? AppColors.statusSuccess(context) : accent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.text(
                      context,
                      complete
                          ? 'focusChallengeBadgeTitle'
                          : 'focusChallengeTitle',
                    ),
                    style: AppTextStyles.tileTitle(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Semantics(
                    label: semanticsLabel,
                    child: ExcludeSemantics(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _ProgressDots(
                            filled: challenge.progress,
                            total: FocusChallenge.goalDays,
                            color: complete
                                ? AppColors.statusSuccess(context)
                                : accent,
                          ),
                          Text(
                            progressLabel,
                            style: AppTextStyles.statLabel(
                              context,
                            ).copyWith(color: AppColors.textPrimary(context)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    complete
                        ? AppLocalizations.text(
                            context,
                            'focusChallengeBadgeEarned',
                          )
                        : AppLocalizations.text(
                            context,
                            challenge.countsDay(today)
                                ? 'focusChallengeTodayCounted'
                                : 'focusChallengeTodayPending',
                          ),
                    style: AppTextStyles.tileSubtitle(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _Card extends StatelessWidget {
  const _Card({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface(context),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.cardBorder,
      side: BorderSide(color: AppColors.subtleBorder(context)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
  );
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({
    required this.filled,
    required this.total,
    required this.color,
  });

  final int filled;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var index = 0; index < total; index++)
        Padding(
          padding: EdgeInsets.only(
            right: index == total - 1 ? 0 : AppSpacing.sm,
          ),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < filled ? color : Colors.transparent,
              border: Border.all(
                color: index < filled ? color : AppColors.subtleBorder(context),
                width: 1.5,
              ),
            ),
          ),
        ),
    ],
  );
}

typedef _ChallengeBuilder =
    Widget Function(
      BuildContext context,
      FocusChallengeService service,
      bool failed,
      VoidCallback retry,
    );

class _FocusChallengeBuilder extends StatefulWidget {
  const _FocusChallengeBuilder({required this.service, required this.builder});

  final FocusChallengeService service;
  final _ChallengeBuilder builder;

  @override
  State<_FocusChallengeBuilder> createState() => _FocusChallengeBuilderState();
}

class _FocusChallengeBuilderState extends State<_FocusChallengeBuilder> {
  Timer? _midnight;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_changed);
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      await widget.service.load();
      if (mounted) {
        setState(() => _failed = false);
        _scheduleMidnight();
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _changed() {
    if (!mounted) return;
    setState(() {
      if (widget.service.isLoaded) _failed = false;
    });
    _scheduleMidnight();
  }

  /// "Today" in the card has to stop being today at midnight, or a session
  /// finished before midnight keeps claiming the new day.
  void _scheduleMidnight() {
    _midnight?.cancel();
    if (widget.service.challenge.isComplete) return;
    final now = widget.service.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(nextDay.difference(now), _changed);
  }

  @override
  void dispose() {
    _midnight?.cancel();
    widget.service.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.service, _failed, () {
        unawaited(_load());
      });
}
