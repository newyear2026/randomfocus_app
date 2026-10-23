import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/duration_weights.dart';
import 'pro_service.dart';

class FocusPreferences extends ChangeNotifier {
  FocusPreferences({
    ProService? entitlement,
    Future<SharedPreferences> Function()? loadPreferences,
  }) : _entitlement = entitlement,
       _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;
  static final instance = FocusPreferences();
  static const storageKey = 'pro_focus_preferences_v1';
  final ProService? _entitlement;
  final Future<SharedPreferences> Function() _loadPreferences;
  ProService get _pro => _entitlement ?? ProService.instance;
  DurationWeights _current = DurationWeights.equal(DurationWeights.choices);
  List<FocusPreset> _presets = [];
  String? _activeId;
  bool hadInvalidData = false;
  bool isLoaded = false;
  Future<void>? _loading;
  Future<void>? _writes;
  SharedPreferences? _storage;

  DurationWeights get current => _current;
  List<FocusPreset> get presets => List.unmodifiable(_presets);
  String? get activeId => _activeId;

  Future<void> load() async {
    if (isLoaded) return;
    final loading = _loading ??= _load();
    try {
      await loading;
    } catch (_) {
      if (identical(_loading, loading)) _loading = null;
      rethrow;
    }
  }

  Future<void> _load() async {
    final prefs = _storage ??= await _loadPreferences();
    final raw = prefs.getString(storageKey);
    if (raw == null) {
      isLoaded = true;
      return;
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      throw const FormatException('Unreadable saved settings');
    }
    if (decoded is! Map ||
        decoded['version'] != 1 ||
        decoded['presets'] is! List) {
      throw const FormatException('Unsupported saved settings');
    }
    final valid = <FocusPreset>[];
    for (final item in decoded['presets'] as List) {
      try {
        final preset = FocusPreset.fromJson(item);
        if (valid.any(
          (p) =>
              p.id == preset.id ||
              p.name.toLowerCase() == preset.name.toLowerCase(),
        )) {
          hadInvalidData = true;
        } else {
          valid.add(preset);
        }
      } catch (_) {
        hadInvalidData = true;
      }
    }
    DurationWeights current;
    try {
      current = DurationWeights.fromJson(decoded['current']);
    } catch (_) {
      current = DurationWeights.equal(DurationWeights.choices);
      hadInvalidData = true;
    }
    isLoaded = true;
    _presets = valid;
    _current = current;
    final activeId = decoded['activeId'];
    _activeId = activeId is String && valid.any((p) => p.id == activeId)
        ? activeId
        : null;
    notifyListeners();
  }

  Future<void> _change(Future<void> Function() action) {
    final previous = _writes;
    late final Future<void> next;
    Future<void> run() async {
      if (previous != null) {
        try {
          await previous;
        } catch (_) {
          /* A failed write must not poison the queue. */
        }
      }
      try {
        await load();
        if (!_pro.hasPro) throw StateError('Pro is required');
        await action();
      } finally {
        if (identical(_writes, next)) _writes = null;
      }
    }

    next = run();
    _writes = next;
    return next;
  }

  Future<void> _commit(
    DurationWeights current,
    List<FocusPreset> presets,
    String? activeId,
  ) async {
    final prefs = _storage ??= await _loadPreferences();
    try {
      final saved = await prefs.setString(
        storageKey,
        jsonEncode({
          'version': 1,
          'current': current.toJson(),
          'activeId': activeId,
          'presets': presets.map((p) => p.toJson()).toList(),
        }),
      );
      if (!saved) throw StateError('Settings could not be saved');
    } catch (_) {
      // The legacy preferences API updates its memory cache before disk I/O.
      // Reload after failure so a new service cannot read an uncommitted value.
      try {
        await prefs.reload();
      } catch (_) {
        /* Keep the current in-memory model. */
      }
      rethrow;
    }
    _current = current;
    _presets = presets;
    _activeId = activeId;
    notifyListeners();
  }

  Future<void> saveCurrent(DurationWeights configuration) =>
      _change(() => _commit(configuration, _presets, null));

  Future<void> savePreset({
    String? id,
    required String name,
    required DurationWeights configuration,
  }) => _change(() async {
    if (id != null && !_presets.any((p) => p.id == id)) {
      throw StateError('Preset no longer exists');
    }
    final base = DateTime.now().microsecondsSinceEpoch.toString();
    var newId = base;
    var suffix = 0;
    while (_presets.any((p) => p.id == newId)) {
      newId = '${base}_${++suffix}';
    }
    final preset = FocusPreset(
      id: id ?? newId,
      name: name,
      configuration: configuration,
    );
    if (_presets.any(
      (p) => p.id != id && p.name.toLowerCase() == preset.name.toLowerCase(),
    )) {
      throw ArgumentError('Preset names must be unique');
    }
    final next = [..._presets];
    if (id == null) {
      next.add(preset);
    } else {
      next[next.indexWhere((p) => p.id == id)] = preset;
    }
    await _commit(
      _activeId == id && id != null ? configuration : _current,
      next,
      _activeId,
    );
  });

  Future<void> apply(String id) => _change(() async {
    final preset = _presets.where((p) => p.id == id).firstOrNull;
    if (preset == null) throw StateError('Preset no longer exists');
    await _commit(preset.configuration, _presets, id);
  });

  /// Removing an active preset keeps its current configuration, never the timer.
  Future<void> delete(String id) => _change(() async {
    if (!_presets.any((p) => p.id == id)) {
      throw StateError('Preset no longer exists');
    }
    await _commit(
      _current,
      _presets.where((p) => p.id != id).toList(),
      _activeId == id ? null : _activeId,
    );
  });
}
