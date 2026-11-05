import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/timer_history.dart';
import 'package:my_first_app/services/focus_session_recorder.dart';

void main() {
  test(
    'slow checkpoint cannot overwrite final state or emit a second outcome',
    () async {
      final gate = Completer<void>();
      final writes = <TimerHistory>[];
      final events = <String>[];
      final recorder = FocusSessionRecorder(
        focusMinutes: 1,
        saveHistory: (history) async {
          if (writes.isEmpty) await gate.future;
          writes.add(history);
        },
        logEvent: (name, {parameters}) async => events.add(name),
      );
      final pause = recorder.checkpoint(2);
      final finish = recorder.finish(SessionStatus.completed, 60);
      final duplicate = recorder.finish(SessionStatus.stopped, 60);
      final latePause = recorder.checkpoint(60);
      expect(writes, isEmpty);
      gate.complete();
      await Future.wait([pause, finish, duplicate, latePause]);
      expect(writes.map((h) => h.status), [
        SessionStatus.stopped,
        SessionStatus.completed,
      ]);
      expect(writes.map((h) => h.sessionId).toSet(), hasLength(1));
      expect(events, ['focus_session_completed']);
    },
  );

  test('checkpoint failure does not prevent later completion', () async {
    final events = <String>[];
    var writes = 0;
    final recorder = FocusSessionRecorder(
      focusMinutes: 1,
      saveHistory: (_) async {
        if (++writes == 1) throw StateError('disk failed');
      },
      logEvent: (name, {parameters}) async => events.add(name),
    );
    await expectLater(recorder.checkpoint(2), throwsStateError);
    await recorder.finish(SessionStatus.completed, 60);
    expect(writes, 2);
    expect(events, ['focus_session_completed']);
  });

  test('failed terminal storage still attempts only one outcome', () async {
    final events = <String>[];
    final recorder = FocusSessionRecorder(
      focusMinutes: 1,
      saveHistory: (_) async => throw StateError('disk failed'),
      logEvent: (name, {parameters}) async => events.add(name),
    );
    await expectLater(
      recorder.finish(SessionStatus.completed, 60),
      throwsStateError,
    );
    await expectLater(
      recorder.finish(SessionStatus.stopped, 60),
      throwsStateError,
    );
    expect(events, ['focus_session_completed']);
  });

  test('new sessions are distinct even with the same injected clock', () {
    final now = DateTime(2026, 10, 30);
    final first = FocusSessionRecorder(focusMinutes: 1, now: () => now);
    final second = FocusSessionRecorder(focusMinutes: 1, now: () => now);
    expect(first.sessionId, isNot(second.sessionId));
  });
}
