# Timer session history and analytics

Stop pauses the current phase. Start resumes it. Reset or leaving the timer
abandons an unfinished focus session; reaching the focus deadline completes it.

## History

- Stop saves a checkpoint under the current session ID. For compatibility with
  existing history, the checkpoint uses `SessionStatus.stopped`.
- Repeated stops and final completion replace that session's entry instead of
  appending duplicates. Other sessions and the existing 2,000-entry cap remain.
- Reset finalizes the old session and allocates a distinct ID for the next one.
- Per-session writes and history-list saves are serialized. A delayed checkpoint
  cannot overwrite the final state or lose a concurrent session save.
- Controls are disabled while a pause/reset is saving. Save failures are reported
  without leaving the controls stuck.

## Event contract

| Event | Meaning after this fix | Parameters |
| --- | --- | --- |
| `focus_timer_started` | Every transition to running: first start, resume, and automatic break start. This existing meaning is unchanged. | `phase`: `focus` or `break`; `focus_minutes` |
| `focus_session_completed` | One terminal outcome when focus reaches its deadline; no event for break completion. | `focus_minutes`, `elapsed_seconds` |
| `focus_session_stopped` | One terminal outcome when an unfinished focus session with at least one elapsed second is reset or abandoned. Stop alone no longer sends this event. | `focus_minutes`, `elapsed_seconds` |

A pause checkpoint does not finalize analytics. Completing after any number of
pauses produces one completed history entry and one completed-event attempt, with
no stopped-event attempt for that session. A local write failure no longer
suppresses the terminal-event attempt. SDK/server delivery remains the telemetry
sink's responsibility; this does not promise exactly-once delivery by GA4.

Elapsed seconds exclude paused time. Start counts still include resumes and
breaks, so do not divide terminal-event counts by all start events as a session
completion rate. Segment pre-fix/post-fix analysis by the deployed app version:
`focus_session_stopped` previously also counted a pause. The existing events do
not carry a session ID or a start/resume distinction.

## Background and restart limits

A live timer uses a deadline and catches up on resume, including a return after
both focus and break deadlines. Scheduled notifications themselves do not emit
analytics events. Process-kill recovery is not implemented: after reopening, a
persisted pause checkpoint remains in history, but the active timer is not
restored. An OS kill may prevent a terminal-event attempt, and no stopped event
is inferred from a checkpoint on the next launch. Dispose persistence remains
best effort. Historical analytics and prior stopped records are not rewritten.

## Offline verification

`TimerPage` accepts an injectable clock and event sink. Regression tests use
in-memory preferences, fake alerts/wakelock, and an event list; they do not
initialize Firebase or launch the production app.

The regression was first run against the original session logic (with only test
seams added) and failed: Stop -> Start -> finish left `SessionStatus.stopped`
instead of `completed`. It passes after the fix.

Run:

```sh
flutter test --no-pub test/timer_session_events_test.dart test/focus_session_recorder_test.dart test/timer_session_persistence_test.dart test/timer_completion_flow_test.dart test/history_retention_test.dart
flutter test --no-pub
flutter analyze --no-pub
```

Coverage includes normal focus/break, repeated pauses, reset, running/paused
exit, background return before/after deadlines, checkpoint/finalization races,
storage failures, history upserts, and a fresh page loaded from persisted data.
The fresh-page test documents the restart limitation; it is not a device-level
OS process-kill or notification-delivery test.

## Proposed GA4 definitions (not applied)

Register event-scoped `phase` for the existing string values `focus`/`break`,
then filter by the RandomFocus stream and `focus_timer_started`. `result` belongs
to Sobrita's `first_expense` analysis (`saved`/`skipped`/`snoozed`); RandomFocus's
timer does not send it. Optional event-scoped numeric metrics are `focus_minutes`
(minutes) and `elapsed_seconds` (seconds). No GA4 settings were changed.
