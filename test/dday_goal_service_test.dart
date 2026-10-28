import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/dday_goal.dart';
import 'package:my_first_app/services/dday_goal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'package:timezone/timezone.dart' as tz;

class _GoalPreferences implements SharedPreferences {
  String? value;
  final otherValues = <String, Object>{};
  bool succeeds = true;
  bool removesSucceed = true;
  Completer<void>? gate;
  int reloads = 0;

  @override
  String? getString(String key) =>
      key == DDayGoalService.storageKey ? value : otherValues[key] as String?;
  @override
  Object? get(String key) =>
      key == DDayGoalService.storageKey ? value : otherValues[key];
  @override
  Future<bool> setString(String key, String value) async {
    await gate?.future;
    if (!succeeds) return false;
    if (key == DDayGoalService.storageKey) {
      this.value = value;
    } else {
      otherValues[key] = value;
    }
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    if (!succeeds || !removesSucceed) return false;
    if (key == DDayGoalService.storageKey) {
      value = null;
    } else {
      otherValues.remove(key);
    }
    return true;
  }

  @override
  Future<void> reload() async => reloads++;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('countdown uses calendar dates, including today and overdue goals', () {
    final goal = DDayGoal(name: 'Exam', targetDate: DateTime(2026, 11, 22, 20));
    expect(goal.countdown(DateTime(2026, 10, 23, 23, 59)), 'D-30');
    expect(goal.countdown(DateTime(2026, 11, 22, 0, 1)), 'D-Day');
    expect(goal.countdown(DateTime(2026, 11, 23)), 'D+1');
    final leap = DDayGoal(name: 'Leap day', targetDate: DateTime(2028, 3, 1));
    expect(leap.countdown(DateTime(2028, 2, 28)), 'D-2');
  });

  test('DST and timezone offsets cannot shorten a calendar day', () {
    timezone.initializeTimeZones();
    final location = tz.getLocation('America/New_York');
    final today = tz.TZDateTime(location, 2026, 3, 8);
    final tomorrow = tz.TZDateTime(location, 2026, 3, 9);
    expect(tomorrow.difference(today).inHours, 23);
    final goal = DDayGoal(name: 'Exam', targetDate: tomorrow);
    expect(goal.countdown(today), 'D-1');
    expect(goal.countdown(tz.TZDateTime(location, 2026, 3, 9, 23)), 'D-Day');
  });

  test('storage validates names and rejects overflowing calendar dates', () {
    for (final name in ['', '   ', 'a' * 41, 'bad\nname']) {
      expect(
        () => DDayGoal(name: name, targetDate: DateTime(2026, 11, 22)),
        throwsArgumentError,
      );
    }
    expect(
      () => DDayGoal.fromJson({
        'version': 1,
        'name': 'Exam',
        'date': '2026-02-30',
      }),
      throwsFormatException,
    );
    final goal = DDayGoal(name: ' Exam ', targetDate: DateTime(2026, 11, 22));
    expect(DDayGoal.fromJson(goal.toJson()).name, 'Exam');
    expect(goal.toJson()['date'], '2026-11-22');
    expect(
      DDayGoal(name: '🍅' * 40, targetDate: goal.targetDate).name,
      '🍅' * 40,
    );
  });

  test('save, edit and delete survive service recreation', () async {
    final disk = _GoalPreferences();
    final service = DDayGoalService(loadPreferences: () async => disk);
    addTearDown(service.dispose);
    await service.load();
    expect(service.goal, isNull);
    await service.save(name: ' Exam ', targetDate: DateTime(2026, 11, 22));
    final restored = DDayGoalService(loadPreferences: () async => disk);
    addTearDown(restored.dispose);
    await restored.load();
    expect(restored.goal!.name, 'Exam');
    expect(restored.goal!.targetDate, DateTime(2026, 11, 22));
    await restored.save(name: 'Project', targetDate: DateTime(2026, 12, 1));
    expect(jsonDecode(disk.value!)['name'], 'Project');
    await restored.delete();
    final empty = DDayGoalService(loadPreferences: () async => disk);
    addTearDown(empty.dispose);
    await empty.load();
    expect(empty.goal, isNull);
    expect(disk.value, isNull);
  });

  test('failed saves and deletes keep the last committed goal', () async {
    final disk = _GoalPreferences();
    final service = DDayGoalService(loadPreferences: () async => disk);
    addTearDown(service.dispose);
    await service.save(name: 'Exam', targetDate: DateTime(2026, 11, 22));
    disk.succeeds = false;
    await expectLater(
      service.save(name: 'Project', targetDate: DateTime(2026, 12, 1)),
      throwsStateError,
    );
    await expectLater(service.delete(), throwsStateError);
    expect(service.goal!.name, 'Exam');
    expect(disk.reloads, 2);
    disk.succeeds = true;
    await service.save(name: 'Retry', targetDate: DateTime(2026, 12, 1));
    expect(service.goal!.name, 'Retry');
  });

  test('overlapping saves and delete are committed in request order', () async {
    final disk = _GoalPreferences()..gate = Completer<void>();
    final service = DDayGoalService(loadPreferences: () async => disk);
    addTearDown(service.dispose);
    final first = service.save(
      name: 'Exam',
      targetDate: DateTime(2026, 11, 22),
    );
    final second = service.save(
      name: 'Work',
      targetDate: DateTime(2026, 12, 1),
    );
    final deletion = service.delete();
    disk.gate!.complete();
    await Future.wait([first, second, deletion]);
    expect(service.goal, isNull);
    expect(disk.value, isNull);
  });

  test('a failed load can retry without overwriting stored data', () async {
    final disk = _GoalPreferences()..value = '{broken';
    final service = DDayGoalService(loadPreferences: () async => disk);
    addTearDown(service.dispose);
    await expectLater(service.load(), throwsFormatException);
    expect(service.isLoaded, false);
    expect(service.needsRecovery, true);
    expect(disk.value, '{broken');
    disk.value = jsonEncode(
      DDayGoal(name: 'Recovered', targetDate: DateTime(2026, 11, 22)).toJson(),
    );
    await service.load();
    expect(service.goal!.name, 'Recovered');
    expect(service.needsRecovery, false);
  });

  test(
    'confirmed recovery backs up the original and preserves other data',
    () async {
      final disk = _GoalPreferences()..value = '{broken';
      disk.otherValues['timer_history'] = 'existing history';
      final service = DDayGoalService(loadPreferences: () async => disk);
      addTearDown(service.dispose);
      await expectLater(service.load(), throwsFormatException);
      await service.resetCorruptGoal();
      expect(
        jsonDecode(disk.getString(DDayGoalService.recoveryBackupKey)!)['value'],
        '{broken',
      );
      expect(disk.otherValues['timer_history'], 'existing history');
      expect(disk.value, isNull);
      expect(service.isLoaded, true);
      expect(service.needsRecovery, false);
      await service.save(name: 'New goal', targetDate: DateTime(2026, 11, 23));
      expect(service.goal!.name, 'New goal');
    },
  );

  test('failed backup or removal never discards the damaged goal', () async {
    final disk = _GoalPreferences()..value = '{broken';
    final service = DDayGoalService(loadPreferences: () async => disk);
    addTearDown(service.dispose);
    await expectLater(service.load(), throwsFormatException);
    disk.succeeds = false;
    await expectLater(service.resetCorruptGoal(), throwsStateError);
    expect(disk.value, '{broken');
    expect(service.needsRecovery, true);
    disk.succeeds = true;
    disk.removesSucceed = false;
    await expectLater(service.resetCorruptGoal(), throwsStateError);
    expect(disk.value, '{broken');
    expect(service.needsRecovery, true);
    disk.removesSucceed = true;
    await service.resetCorruptGoal();
    expect(service.needsRecovery, false);
  });

  test(
    'recovery cannot clear a goal repaired while confirmation was open',
    () async {
      final disk = _GoalPreferences()..value = '{broken';
      final service = DDayGoalService(loadPreferences: () async => disk);
      addTearDown(service.dispose);
      await expectLater(service.load(), throwsFormatException);
      disk.value = jsonEncode(
        DDayGoal(name: 'Repaired', targetDate: DateTime(2026, 11, 23)).toJson(),
      );
      await service.resetCorruptGoal();
      expect(service.goal!.name, 'Repaired');
      expect(disk.getString(DDayGoalService.recoveryBackupKey), isNull);
    },
  );

  test(
    'temporary storage failures remain retryable instead of requesting reset',
    () async {
      var attempts = 0;
      final disk = _GoalPreferences();
      final service = DDayGoalService(
        loadPreferences: () async {
          if (attempts++ == 0) throw StateError('Temporary storage failure');
          return disk;
        },
      );
      addTearDown(service.dispose);
      await expectLater(service.load(), throwsStateError);
      expect(service.needsRecovery, false);
      await service.load();
      expect(service.isLoaded, true);
    },
  );
}
