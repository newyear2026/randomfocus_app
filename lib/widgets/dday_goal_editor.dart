import 'package:flutter/material.dart';

import '../models/dday_goal.dart';
import '../services/app_localizations.dart';
import '../services/dday_goal_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_action_button.dart';
import 'app_dialogs.dart';
import 'app_feedback.dart';

Future<void> showDDayGoalRecovery(
  BuildContext context,
  DDayGoalService service,
) async {
  final confirmed = await showAppConfirmDialog(
    context: context,
    title: AppLocalizations.text(context, 'ddayRecoveryTitle'),
    content: AppLocalizations.text(context, 'ddayRecoveryMessage'),
    cancelLabel: AppLocalizations.text(context, 'cancel'),
    confirmLabel: AppLocalizations.text(context, 'ddayRecoveryAction'),
  );
  if (!confirmed || !context.mounted) return;
  try {
    await service.resetCorruptGoal();
  } catch (_) {
    if (context.mounted) {
      showAppSnackBar(
        context,
        message: AppLocalizations.text(context, 'ddayRecoveryError'),
        variant: AppSnackBarVariant.error,
      );
    }
    return;
  }
  if (context.mounted) await showDDayGoalEditor(context, service);
}

Future<void> showDDayGoalEditor(
  BuildContext context,
  DDayGoalService service,
) async {
  if (!service.isLoaded) return;
  await showAppBottomSheet<void>(
    context: context,
    title: AppLocalizations.text(context, 'ddayTitle'),
    message: AppLocalizations.text(context, 'ddayEditorHint'),
    child: DDayGoalEditor(service: service),
  );
}

/// The same editor is used by Settings and the timer's goal card.
class DDayGoalEditor extends StatefulWidget {
  const DDayGoalEditor({super.key, required this.service});

  final DDayGoalService service;

  @override
  State<DDayGoalEditor> createState() => _DDayGoalEditorState();
}

class _DDayGoalEditorState extends State<DDayGoalEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.service.goal?.name);
  late DateTime _date =
      widget.service.goal?.targetDate ??
      DateUtils.dateOnly(widget.service.now());
  bool _saving = false;
  bool _confirmingDelete = false;
  String? _error;

  String t(String key) => AppLocalizations.text(context, key);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      currentDate: widget.service.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200, 12, 31),
      helpText: t('ddayDate'),
    );
    if (selected != null && mounted) {
      setState(() {
        _date = selected;
        _error = null;
      });
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.service.save(name: _name.text, targetDate: _date);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _error = t('ddaySaveError'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (_saving || _confirmingDelete) return;
    _confirmingDelete = true;
    FocusScope.of(context).unfocus();
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: t('ddayDeleteTitle'),
      content: t('ddayDeleteMessage'),
      cancelLabel: t('cancel'),
      confirmLabel: t('delete'),
    );
    _confirmingDelete = false;
    if (!confirmed || !mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.service.delete();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _error = t('ddaySaveError'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = DDayGoal(name: t('ddayNameHint'), targetDate: _date);
    return PopScope(
      canPop: !_saving,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const ValueKey('dday-name'),
              controller: _name,
              enabled: !_saving,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: t('ddayName'),
                hintText: t('ddayNameHint'),
              ),
              validator: (value) {
                try {
                  DDayGoal(name: value ?? '', targetDate: _date);
                  return null;
                } on ArgumentError {
                  return t('ddayNameError');
                }
              },
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              key: const ValueKey('dday-date'),
              onPressed: _saving ? null : _selectDate,
              icon: const Icon(Icons.calendar_today_outlined),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.lg),
                alignment: Alignment.centerLeft,
              ),
              label: Text(
                '${t('ddayDate')} · '
                '${MaterialLocalizations.of(context).formatCompactDate(_date)}',
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              preview.countdown(widget.service.now()),
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle(
                context,
              ).copyWith(color: AppColors.accent(context), fontSize: 32),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              t('ddayDisplayHint'),
              textAlign: TextAlign.center,
              style: AppTextStyles.tileSubtitle(context),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(color: AppColors.statusDanger(context)),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            AppPrimaryButton(
              key: const ValueKey('dday-save'),
              onPressed: _saving ? null : _save,
              label: t(_saving ? 'ddaySaving' : 'ddaySave'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: Text(t('cancel')),
                ),
                if (widget.service.goal != null)
                  TextButton(
                    key: const ValueKey('dday-delete'),
                    onPressed: _saving ? null : _delete,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.statusDanger(context),
                    ),
                    child: Text(t('ddayDeleteTitle')),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
