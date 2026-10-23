import 'dart:async';

import 'package:flutter/material.dart';

import '../models/duration_weights.dart';
import '../services/app_localizations.dart';
import '../services/focus_preferences.dart';
import '../services/pro_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_action_button.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_screen.dart';
import '../widgets/app_section_card.dart';
import 'pro_page.dart';

class FocusSettingsPage extends StatefulWidget {
  const FocusSettingsPage({
    super.key,
    this.preset,
    this.createPreset = false,
    this.preferences,
    this.proService,
  });
  final FocusPreset? preset;
  final bool createPreset;
  final FocusPreferences? preferences;
  final ProService? proService;
  @override
  State<FocusSettingsPage> createState() => _FocusSettingsPageState();
}

class _FocusSettingsPageState extends State<FocusSettingsPage> {
  late final _pro = widget.proService ?? ProService.instance;
  late final _preferences = widget.preferences ?? FocusPreferences.instance;
  final _name = TextEditingController();
  DurationWeights _configuration = DurationWeights.equal(
    DurationWeights.choices,
  );
  bool _loading = true, _loadError = false, _saving = false, _dirty = false;
  bool _allowPop = false, _askingDiscard = false;
  String? _errorKey;
  bool get _isPreset => widget.createPreset || widget.preset != null;
  String t(String key) => AppLocalizations.text(context, key);

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = false;
    });
    try {
      await Future.wait([_pro.initialize(), _preferences.load()]);
      if (!mounted) return;
      setState(() {
        _configuration = widget.preset?.configuration ?? _preferences.current;
        _name.text = widget.preset?.name ?? '';
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _change(DurationWeights value) => setState(() {
    _configuration = value;
    _dirty = true;
    _errorKey = null;
  });
  void _select(int minutes, bool selected) {
    try {
      _change(_configuration.withSelected(minutes, selected));
    } on StateError {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('focusAtLeastOne'))));
    }
  }

  Future<void> _save() async {
    if (_saving || !_pro.hasPro) return;
    setState(() {
      _saving = true;
      _errorKey = null;
    });
    try {
      if (_isPreset) {
        await _preferences.savePreset(
          id: widget.preset?.id,
          name: _name.text,
          configuration: _configuration,
        );
      } else {
        await _preferences.saveCurrent(_configuration);
      }
      if (!mounted) return;
      _close();
    } on ArgumentError {
      if (mounted) setState(() => _errorKey = 'focusNameError');
    } catch (_) {
      if (mounted) setState(() => _errorKey = 'focusError');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _close() {
    setState(() {
      _dirty = false;
      _allowPop = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _discard() async {
    if (_askingDiscard || _saving) return;
    _askingDiscard = true;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: t('focusDiscard'),
      content: t('focusDiscard'),
      cancelLabel: t('cancel'),
      confirmLabel: t('focusDiscardAction'),
    );
    _askingDiscard = false;
    if (confirmed && mounted) _close();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _pro,
      builder: (context, _) => PopScope(
        canPop: (!_dirty || _allowPop) && !_saving,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_discard());
        },
        child: AppScreen(
          titleText: t(_isPreset ? 'proPresets' : 'proCustomTimes'),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _loadError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t('focusSettingsLoadError')),
                      TextButton(
                        onPressed: _load,
                        child: Text(t('focusRetry')),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (!_pro.hasPro) ...[
                      Text(t('focusPreview')),
                      const SizedBox(height: 16),
                    ],
                    if (_preferences.hadInvalidData) ...[
                      Text(t('focusInvalidSaved')),
                      const SizedBox(height: 16),
                    ],
                    if (_isPreset) ...[
                      TextField(
                        key: const ValueKey('preset-name'),
                        controller: _name,
                        maxLength: 40,
                        enabled: _pro.hasPro && !_saving,
                        onChanged: (_) => setState(() {
                          _dirty = true;
                          _errorKey = null;
                        }),
                        decoration: InputDecoration(
                          labelText: t('focusPresetName'),
                          hintText: t('focusNameHint'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    AppSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('focusChoices'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final minutes in DurationWeights.choices)
                                FilterChip(
                                  key: ValueKey('duration-$minutes'),
                                  label: Text('$minutes ${t('minutes')}'),
                                  selected: _configuration.weights.containsKey(
                                    minutes,
                                  ),
                                  onSelected: _pro.hasPro && !_saving
                                      ? (value) => _select(minutes, value)
                                      : null,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 16,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                t('focusWeights'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Chip(label: Text(t('focusTotal'))),
                            ],
                          ),
                          for (final entry
                              in _configuration.weights.entries) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text('${entry.key} ${t('minutes')}'),
                                ),
                                Text('${entry.value}%'),
                              ],
                            ),
                            Slider(
                              key: ValueKey('weight-${entry.key}'),
                              min: 0,
                              max: 100,
                              divisions: 100,
                              value: entry.value.toDouble(),
                              label: '${entry.value}%',
                              semanticFormatterCallback: (value) =>
                                  '${entry.key} ${t('minutes')}, ${value.round()}%',
                              onChanged:
                                  _pro.hasPro &&
                                      !_saving &&
                                      _configuration.weights.length > 1
                                  ? (value) => _change(
                                      _configuration.withWeight(
                                        entry.key,
                                        value.round(),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                          TextButton(
                            onPressed: _pro.hasPro && !_saving
                                ? () => _change(
                                    DurationWeights.equal(
                                      _configuration.durations,
                                    ),
                                  )
                                : null,
                            child: Text(t('focusEqualize')),
                          ),
                          Text(
                            t('focusAutoAdjust'),
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorKey != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            t(_errorKey!),
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    AppPrimaryButton(
                      onPressed: _saving
                          ? null
                          : _pro.hasPro
                          ? _save
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => ProPage(service: _pro),
                              ),
                            ),
                      label: t(
                        _pro.hasPro
                            ? (_isPreset ? 'focusPresetSave' : 'focusSave')
                            : 'focusProNeeded',
                      ),
                    ),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () {
                              if (_dirty) {
                                unawaited(_discard());
                              } else {
                                Navigator.pop(context);
                              }
                            },
                      child: Text(t('cancel')),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
