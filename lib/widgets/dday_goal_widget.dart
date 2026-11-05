import 'dart:async';

import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import '../services/dday_goal_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_info_tile.dart';
import 'dday_goal_editor.dart';

class DDaySettingsTile extends StatelessWidget {
  const DDaySettingsTile({super.key, this.service});
  final DDayGoalService? service;

  @override
  Widget build(BuildContext context) => _DDayGoalBuilder(
    service: service ?? DDayGoalService.instance,
    builder: (context, service, failed, retry) {
      final goal = service.goal;
      final subtitle = service.needsRecovery
          ? AppLocalizations.text(context, 'ddayRecoveryNeeded')
          : failed
          ? AppLocalizations.text(context, 'ddayLoadError')
          : !service.isLoaded
          ? AppLocalizations.text(context, 'ddayLoading')
          : goal == null
          ? AppLocalizations.text(context, 'ddayEmpty')
          : '${goal.name} · ${goal.countdown(service.now())}';
      return AppInfoTile(
        key: const ValueKey('dday-settings'),
        grouped: true,
        icon: Icons.event_outlined,
        title: AppLocalizations.text(context, 'ddayTitle'),
        subtitle: subtitle,
        onTap: service.needsRecovery
            ? () => showDDayGoalRecovery(context, service)
            : failed
            ? retry
            : service.isLoaded
            ? () => showDDayGoalEditor(context, service)
            : null,
      );
    },
  );
}

/// Compact enough to keep the timer the primary element of the focus screen.
class DDayGoalWidget extends StatelessWidget {
  const DDayGoalWidget({super.key, this.service});
  final DDayGoalService? service;

  @override
  Widget build(BuildContext context) => _DDayGoalBuilder(
    service: service ?? DDayGoalService.instance,
    builder: (context, service, failed, retry) {
      if (failed || service.needsRecovery) {
        return TextButton.icon(
          onPressed: service.needsRecovery
              ? () => showDDayGoalRecovery(context, service)
              : retry,
          icon: Icon(service.needsRecovery ? Icons.restore : Icons.refresh),
          label: Text(
            AppLocalizations.text(
              context,
              service.needsRecovery ? 'ddayRecoveryNeeded' : 'ddayLoadError',
            ),
          ),
        );
      }
      final goal = service.goal;
      if (goal == null) return const SizedBox.shrink();
      final date = MaterialLocalizations.of(
        context,
      ).formatCompactDate(goal.targetDate);
      final countdown = goal.countdown(service.now());
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Semantics(
          button: true,
          label: AppLocalizations.text(context, 'ddayEdit'),
          child: Material(
            color: AppColors.surfaceMuted(context),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.cardBorder,
              side: BorderSide(color: AppColors.subtleBorder(context)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const ValueKey('dday-goal-card'),
              onTap: () => showDDayGoalEditor(context, service),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      color: AppColors.accent(context),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            goal.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.tileTitle(context),
                          ),
                          Text(
                            date,
                            style: AppTextStyles.tileSubtitle(context),
                          ),
                          Text(
                            countdown,
                            style: AppTextStyles.tileTitle(
                              context,
                            ).copyWith(color: AppColors.accent(context)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.accent(context),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

typedef _GoalBuilder =
    Widget Function(
      BuildContext context,
      DDayGoalService service,
      bool failed,
      VoidCallback retry,
    );

class _DDayGoalBuilder extends StatefulWidget {
  const _DDayGoalBuilder({required this.service, required this.builder});
  final DDayGoalService service;
  final _GoalBuilder builder;

  @override
  State<_DDayGoalBuilder> createState() => _DDayGoalBuilderState();
}

class _DDayGoalBuilderState extends State<_DDayGoalBuilder>
    with WidgetsBindingObserver {
  Timer? _midnight;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  void _scheduleMidnight() {
    _midnight?.cancel();
    if (widget.service.goal == null) return;
    final now = widget.service.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _midnight = Timer(nextDay.difference(now), _changed);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _changed();
  }

  @override
  void didUpdateWidget(_DDayGoalBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      oldWidget.service.removeListener(_changed);
      widget.service.addListener(_changed);
      _failed = false;
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _midnight?.cancel();
    widget.service.removeListener(_changed);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    widget.service,
    _failed,
    () => unawaited(_load()),
  );
}
