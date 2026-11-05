import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dday_goal.dart';

class DDayGoalService extends ChangeNotifier {
  DDayGoalService({
    Future<SharedPreferences> Function()? loadPreferences,
    DateTime Function()? clock,
  }) : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance,
       now = clock ?? DateTime.now;

  static final instance = DDayGoalService();
  static const storageKey = 'dday_goal_v1';
  static const recoveryBackupKey = 'dday_goal_recovery_backup_v1';
  final Future<SharedPreferences> Function() _loadPreferences;
  final DateTime Function() now;
  SharedPreferences? _storage;
  Future<void>? _loading;
  Future<void>? _writing;
  DDayGoal? _goal;
  bool isLoaded = false;
  bool _disposed = false;
  bool _needsRecovery = false;

  DDayGoal? get goal => _goal;
  bool get needsRecovery => _needsRecovery;

  Future<void> load() async {
    if (isLoaded) return;
    final loading = _loading ??= _read();
    try {
      await loading;
    } finally {
      if (identical(_loading, loading)) _loading = null;
    }
  }

  Future<void> _read() async {
    _needsRecovery = false;
    final prefs = _storage ??= await _loadPreferences();
    try {
      final raw = prefs.getString(storageKey);
      _goal = raw == null ? null : DDayGoal.fromJson(jsonDecode(raw));
    } on FormatException {
      _markCorrupt();
      rethrow;
    } on ArgumentError {
      _markCorrupt();
      rethrow;
    } on TypeError {
      _markCorrupt();
      rethrow;
    }
    isLoaded = true;
    if (!_disposed) notifyListeners();
  }

  void _markCorrupt() {
    _needsRecovery = true;
    if (!_disposed) notifyListeners();
  }

  Future<void> save({required String name, required DateTime targetDate}) {
    final next = DDayGoal(name: name, targetDate: targetDate);
    return _change(next);
  }

  Future<void> delete() => _change(null);

  Future<void> _change(DDayGoal? next) => _enqueue(() async {
    await load();
    final prefs = _storage!;
    try {
      final saved = next == null
          ? await prefs.remove(storageKey)
          : await prefs.setString(storageKey, jsonEncode(next.toJson()));
      if (!saved) throw StateError('Goal could not be saved');
    } catch (_) {
      await _reloadAfterFailure(prefs);
      rethrow;
    }
    _goal = next;
    if (!_disposed) notifyListeners();
  });

  /// Call only after the user confirms resetting an unreadable goal. Save the
  /// original value before removing it; never clear history or other settings.
  Future<void> resetCorruptGoal() => _enqueue(() async {
    if (!_needsRecovery) return;
    final prefs = _storage!;
    await prefs.reload();
    try {
      await _read();
      // Another reader may have repaired the value while confirmation was open.
      return;
    } catch (_) {
      if (!_needsRecovery) rethrow;
    }
    final raw = prefs.get(storageKey);
    try {
      final backedUp = await prefs.setString(
        recoveryBackupKey,
        jsonEncode({
          'value': raw,
          'capturedAt': now().toUtc().toIso8601String(),
        }),
      );
      if (!backedUp) throw StateError('Goal backup could not be saved');
      if (!await prefs.remove(storageKey)) {
        throw StateError('Goal could not be reset');
      }
    } catch (_) {
      await _reloadAfterFailure(prefs);
      rethrow;
    }
    _goal = null;
    _needsRecovery = false;
    isLoaded = true;
    if (!_disposed) notifyListeners();
  });

  Future<void> _reloadAfterFailure(SharedPreferences prefs) async {
    // Legacy preferences update their cache before disk writes complete.
    try {
      await prefs.reload();
    } catch (_) {
      // Keep the last successfully committed in-memory goal.
    }
  }

  Future<void> _enqueue(Future<void> Function() action) {
    final previous = _writing;
    late final Future<void> write;
    Future<void> run() async {
      if (previous != null) {
        try {
          await previous;
        } catch (_) {
          // A failed save must not prevent the user's next attempt.
        }
      }
      try {
        await action();
      } finally {
        if (identical(_writing, write)) _writing = null;
      }
    }

    write = run();
    _writing = write;
    return write;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
