import 'dart:async';

import 'package:flutter/material.dart';

import '../models/duration_weights.dart';
import '../services/app_localizations.dart';
import '../services/focus_preferences.dart';
import '../services/pro_service.dart';
import '../widgets/app_action_button.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_screen.dart';
import '../widgets/app_section_card.dart';
import 'focus_settings_page.dart';
import 'pro_page.dart';

class PresetsPage extends StatefulWidget {
  const PresetsPage({super.key, this.preferences, this.proService});
  final FocusPreferences? preferences;
  final ProService? proService;
  @override
  State<PresetsPage> createState() => _PresetsPageState();
}

class _PresetsPageState extends State<PresetsPage> {
  late final _pro = widget.proService ?? ProService.instance;
  late final _preferences = widget.preferences ?? FocusPreferences.instance;
  late final _changes = Listenable.merge([_pro, _preferences]);
  bool _loading = true, _loadError = false, _busy = false, _writeError = false;
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
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = true;
        });
      }
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _writeError = false;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) setState(() => _writeError = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(FocusPreset preset) async {
    if (_busy) return;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: t('delete'),
      content: t('focusPresetDelete'),
      cancelLabel: t('cancel'),
      confirmLabel: t('delete'),
      variant: AppDialogVariant.danger,
    );
    if (confirmed && mounted) await _run(() => _preferences.delete(preset.id));
  }

  void _edit(FocusPreset? preset) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FocusSettingsPage(
          preset: preset,
          createPreset: preset == null,
          preferences: _preferences,
          proService: _pro,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _changes,
    builder: (context, _) => AppScreen(
      titleText: t('proPresets'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t('focusSettingsLoadError')),
                  TextButton(onPressed: _load, child: Text(t('focusRetry'))),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (!_pro.hasPro) ...[
                  Text(t('focusPreview')),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ProPage(service: _pro),
                      ),
                    ),
                    child: Text(t('focusProNeeded')),
                  ),
                ],
                if (_preferences.hadInvalidData) Text(t('focusInvalidSaved')),
                if (_preferences.presets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(t('focusPresetEmpty')),
                  ),
                for (final preset in _preferences.presets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            preset.configuration.weights.entries
                                .map(
                                  (e) => '${e.key} ${t('minutes')} ${e.value}%',
                                )
                                .join(' · '),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (_preferences.activeId == preset.id)
                                Chip(label: Text(t('focusInUse')))
                              else
                                TextButton(
                                  key: ValueKey('apply-${preset.id}'),
                                  onPressed: _pro.hasPro && !_busy
                                      ? () => _run(
                                          () => _preferences.apply(preset.id),
                                        )
                                      : null,
                                  child: Text(t('focusApply')),
                                ),
                              TextButton(
                                key: ValueKey('edit-${preset.id}'),
                                onPressed: _pro.hasPro && !_busy
                                    ? () => _edit(preset)
                                    : null,
                                child: Text(t('focusEdit')),
                              ),
                              IconButton(
                                key: ValueKey('delete-${preset.id}'),
                                tooltip: t('delete'),
                                onPressed: _pro.hasPro && !_busy
                                    ? () => _delete(preset)
                                    : null,
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_writeError)
                  Semantics(liveRegion: true, child: Text(t('focusError'))),
                AppSecondaryButton(
                  onPressed: _pro.hasPro && !_busy ? () => _edit(null) : null,
                  label: t('focusNewPreset'),
                ),
              ],
            ),
    ),
  );
}
