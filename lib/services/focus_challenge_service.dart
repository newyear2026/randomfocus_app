import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/focus_challenge.dart';

/// Stores the "collect 7 focus days" progress.
///
/// Progress is kept here rather than derived from the session history so that
/// clearing the session history never takes away a day the user already
/// earned, and so the badge survives the 2000-session storage cap.
class FocusChallengeService extends ChangeNotifier {
  FocusChallengeService({
    Future<SharedPreferences> Function()? loadPreferences,
    DateTime Function()? clock,
  }) : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance,
       now = clock ?? DateTime.now;

  static final instance = FocusChallengeService();
  static const storageKey = 'focus_challenge_v1';

  final Future<SharedPreferences> Function() _loadPreferences;
  final DateTime Function() now;
  SharedPreferences? _storage;
  Future<void>? _loading;
  Future<void>? _writing;
  FocusChallenge _challenge = FocusChallenge.empty;
  bool isLoaded = false;
  bool _disposed = false;
  bool _needsRecovery = false;

  FocusChallenge get challenge => _challenge;

  /// True when the stored value could not be read. Progress is left on disk
  /// untouched: an unreadable value is never overwritten, because doing so
  /// would throw away a badge the user already earned.
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
      _challenge = raw == null
          ? FocusChallenge.empty
          : FocusChallenge.fromJson(jsonDecode(raw));
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

  /// Counts the day a focus session finished on.
  ///
  /// Safe to call after every completed session: the same day is only counted
  /// once, and a finished challenge stops counting so the badge cannot be
  /// earned twice. Sessions that the user stopped early never reach this.
  Future<void> recordCompletedFocus({DateTime? at}) {
    // Resolved here rather than inside the queued write: a write waiting
    // behind a slow one must still count the day the session finished on,
    // even if midnight passes while it waits.
    final dayKey = FocusChallenge.dateKey(at ?? now());
    return _enqueue(() async {
      try {
        await load();
      } catch (_) {
        // An unreadable value is surfaced through needsRecovery. Recording a
        // session is a background side effect of finishing a timer, so it
        // fails quietly instead of interrupting the user.
        return;
      }
      if (_needsRecovery) return;

      final next = _challenge.withDay(dayKey);
      if (identical(next, _challenge)) return;

      final prefs = _storage!;
      try {
        final saved = await prefs.setString(
          storageKey,
          jsonEncode(next.toJson()),
        );
        if (!saved) throw StateError('Challenge progress could not be saved');
      } catch (_) {
        await _reloadAfterFailure(prefs);
        rethrow;
      }
      _challenge = next;
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> _reloadAfterFailure(SharedPreferences prefs) async {
    // Legacy preferences update their cache before disk writes complete.
    try {
      await prefs.reload();
    } catch (_) {
      // Keep the last successfully committed in-memory progress.
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
          // A failed save must not prevent the next session from counting.
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
