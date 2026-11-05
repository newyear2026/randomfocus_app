import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/focus_challenge.dart';
import 'package:my_first_app/services/focus_challenge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ChallengePreferences implements SharedPreferences {
  String? value;
  bool succeeds = true;
  Completer<void>? gate;
  int reloads = 0;

  @override
  String? getString(String key) =>
      key == FocusChallengeService.storageKey ? value : null;

  @override
  Future<bool> setString(String key, String value) async {
    await gate?.future;
    if (!succeeds) return false;
    if (key == FocusChallengeService.storageKey) this.value = value;
    return true;
  }

  @override
  Future<void> reload() async => reloads++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String _encode(List<String> days, {String? earnedOn}) =>
    jsonEncode({'version': 1, 'days': days, 'badgeEarnedOn': earnedOn});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FocusChallenge', () {
    test('counts each calendar day once and keeps days ordered', () {
      final challenge = FocusChallenge(
        countedDays: const ['2026-10-03', '2026-10-01', '2026-10-03'],
      );
      expect(challenge.countedDays, ['2026-10-01', '2026-10-03']);
      expect(challenge.progress, 2);
      expect(challenge.isComplete, isFalse);
    });

    test('dateKey zero-pads month and day', () {
      expect(
        FocusChallenge.dateKey(DateTime(2026, 1, 5, 23, 59)),
        '2026-01-05',
      );
    });

    test('withDay ignores a day already counted', () {
      final challenge = FocusChallenge(countedDays: const ['2026-10-01']);
      expect(identical(challenge.withDay('2026-10-01'), challenge), isTrue);
    });

    test('the seventh day earns the badge and freezes progress', () {
      var challenge = FocusChallenge.empty;
      for (var day = 1; day <= 7; day++) {
        challenge = challenge.withDay(
          '2026-10-${day.toString().padLeft(2, '0')}',
        );
      }
      expect(challenge.progress, 7);
      expect(challenge.isComplete, isTrue);
      expect(challenge.badgeEarnedOn, '2026-10-07');

      // An eighth day must not re-award the badge or grow the stored value.
      final after = challenge.withDay('2026-10-08');
      expect(identical(after, challenge), isTrue);
    });

    test('the badge belongs to the day that completed the set', () {
      var challenge = FocusChallenge(
        countedDays: const [
          '2026-10-02',
          '2026-10-03',
          '2026-10-04',
          '2026-10-05',
          '2026-10-06',
          '2026-10-07',
        ],
      );
      // A device whose clock moved back still earns the badge today.
      challenge = challenge.withDay('2026-10-01');
      expect(challenge.badgeEarnedOn, '2026-10-01');
    });

    test('days do not have to be consecutive', () {
      final challenge = FocusChallenge.empty
          .withDay('2026-10-01')
          .withDay('2026-10-02')
          .withDay('2026-10-20');
      expect(challenge.progress, 3);
    });

    test('json survives a round trip', () {
      final challenge = FocusChallenge(
        countedDays: const ['2026-10-01', '2026-10-02'],
      );
      final restored = FocusChallenge.fromJson(
        jsonDecode(jsonEncode(challenge.toJson())),
      );
      expect(restored.countedDays, challenge.countedDays);
      expect(restored.badgeEarnedOn, isNull);
    });

    test('seven stored days without an earn date still count as earned', () {
      final restored = FocusChallenge.fromJson(
        jsonDecode(
          _encode(const [
            '2026-10-01',
            '2026-10-02',
            '2026-10-03',
            '2026-10-04',
            '2026-10-05',
            '2026-10-06',
            '2026-10-07',
          ]),
        ),
      );
      expect(restored.isComplete, isTrue);
      expect(restored.badgeEarnedOn, '2026-10-07');
    });

    test('unreadable values are rejected rather than guessed at', () {
      expect(() => FocusChallenge.fromJson('nope'), throwsFormatException);
      expect(
        () => FocusChallenge.fromJson({'version': 2, 'days': const []}),
        throwsFormatException,
      );
      expect(
        () => FocusChallenge.fromJson({
          'version': 1,
          'days': const ['2026-13-01'],
        }),
        throwsFormatException,
      );
      expect(
        () => FocusChallenge.fromJson({
          'version': 1,
          'days': const ['2026-02-30'],
        }),
        throwsFormatException,
      );
    });
  });

  group('FocusChallengeService', () {
    late _ChallengePreferences prefs;
    late DateTime clock;
    late FocusChallengeService service;

    FocusChallengeService build() => FocusChallengeService(
      loadPreferences: () async => prefs,
      clock: () => clock,
    );

    setUp(() {
      prefs = _ChallengePreferences();
      clock = DateTime(2026, 10, 28, 9);
      service = build();
    });

    tearDown(() => service.dispose());

    test('starts empty and counts today once per day', () async {
      await service.load();
      expect(service.challenge.progress, 0);

      await service.recordCompletedFocus();
      await service.recordCompletedFocus();
      await service.recordCompletedFocus();
      expect(service.challenge.progress, 1);

      clock = DateTime(2026, 10, 29, 7);
      await service.recordCompletedFocus();
      expect(service.challenge.progress, 2);
      expect(service.challenge.countedDays, ['2026-10-28', '2026-10-29']);
    });

    test('progress is read back by a later instance', () async {
      await service.recordCompletedFocus();
      final next = build();
      addTearDown(next.dispose);
      await next.load();
      expect(next.challenge.countedDays, ['2026-10-28']);
    });

    test('the badge is earned on the seventh day and stops counting', () async {
      for (var day = 1; day <= 9; day++) {
        clock = DateTime(2026, 10, day, 9);
        await service.recordCompletedFocus();
      }
      expect(service.challenge.progress, 7);
      expect(service.challenge.badgeEarnedOn, '2026-10-07');

      final stored = FocusChallenge.fromJson(jsonDecode(prefs.value!));
      expect(stored.countedDays.last, '2026-10-07');
    });

    test('a session a minute before midnight counts for that day', () async {
      clock = DateTime(2026, 10, 28, 23, 59);
      await service.recordCompletedFocus();
      clock = DateTime(2026, 10, 29, 0, 1);
      await service.recordCompletedFocus();
      expect(service.challenge.countedDays, ['2026-10-28', '2026-10-29']);
    });

    test('an unreadable value is reported and never overwritten', () async {
      prefs.value = '{"version":1,"days":["nonsense"]}';
      await expectLater(service.load(), throwsFormatException);
      expect(service.needsRecovery, isTrue);

      await service.recordCompletedFocus();
      expect(prefs.value, '{"version":1,"days":["nonsense"]}');
      expect(service.challenge.progress, 0);
    });

    test('a failed write leaves the previous progress in place', () async {
      await service.recordCompletedFocus();
      final saved = prefs.value;

      prefs.succeeds = false;
      clock = DateTime(2026, 10, 29, 9);
      await expectLater(service.recordCompletedFocus(), throwsStateError);
      expect(prefs.value, saved);
      expect(service.challenge.countedDays, ['2026-10-28']);
      expect(prefs.reloads, greaterThan(0));
    });

    test('overlapping records are serialised, not interleaved', () async {
      final gate = Completer<void>();
      prefs.gate = gate;

      final first = service.recordCompletedFocus();
      clock = DateTime(2026, 10, 29, 9);
      final second = service.recordCompletedFocus();

      gate.complete();
      prefs.gate = null;
      await Future.wait([first, second]);

      expect(service.challenge.countedDays, ['2026-10-28', '2026-10-29']);
    });

    test('listeners are notified when a day is counted', () async {
      await service.load();
      var notifications = 0;
      service.addListener(() => notifications++);

      await service.recordCompletedFocus();
      expect(notifications, 1);

      // The same day again changes nothing, so nothing is published.
      await service.recordCompletedFocus();
      expect(notifications, 1);
    });
  });
}
