import '../models/timer_history.dart';
import 'history_service.dart';
import 'telemetry_service.dart';

/// A pause is a durable checkpoint, not a terminal analytics outcome.
/// Serializes checkpoints/finalization so a slow pause cannot overwrite a finish.
class FocusSessionRecorder {
  FocusSessionRecorder({
    required this.focusMinutes,
    this.now = DateTime.now,
    this.saveHistory = HistoryService.saveHistory,
    this.logEvent = TelemetryService.logEvent,
  }) : sessionId = '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  static int _sequence = 0;
  final String sessionId;
  final int focusMinutes;
  final DateTime Function() now;
  final Future<void> Function(TimerHistory) saveHistory;
  final Future<void> Function(String, {Map<String, Object>? parameters})
  logEvent;
  Future<void>? _pending;
  bool _finished = false;

  Future<void> checkpoint(int elapsedSeconds) {
    if (_finished) return _pending ?? Future<void>.value();
    return _write(SessionStatus.stopped, elapsedSeconds, terminal: false);
  }

  Future<void> finish(SessionStatus status, int elapsedSeconds) {
    if (_finished) return _pending ?? Future<void>.value();
    // Claim the terminal outcome synchronously, before any storage await.
    _finished = true;
    return _write(status, elapsedSeconds, terminal: true);
  }

  Future<void> _write(
    SessionStatus status,
    int elapsedSeconds, {
    required bool terminal,
  }) {
    final history = TimerHistory(
      sessionId: sessionId,
      dateTime: now(),
      selectedTime: focusMinutes,
      actualTime: elapsedSeconds,
      status: status,
    );
    final previous = _pending;
    Future<void> run() async {
      if (previous != null) {
        try {
          await previous;
        } catch (_) {
          // A failed checkpoint must not prevent a subsequent finalization.
          // The original caller receives/reports that write's failure.
        }
      }
      try {
        await saveHistory(history);
      } finally {
        // Completion/abandonment describes behavior, even if local storage fails.
        // One attempt per session; SDK delivery is managed by the telemetry sink.
        if (terminal) {
          await logEvent(
            status == SessionStatus.completed
                ? 'focus_session_completed'
                : 'focus_session_stopped',
            parameters: {
              'focus_minutes': focusMinutes,
              'elapsed_seconds': elapsedSeconds,
            },
          );
        }
      }
    }

    return _pending = run();
  }
}
