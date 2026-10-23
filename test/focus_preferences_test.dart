import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/duration_weights.dart';
import 'package:my_first_app/services/focus_preferences.dart';
import 'package:my_first_app/services/pro_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_pro_store.dart';

class MemoryPreferences implements SharedPreferences {
  final values = <String, String>{};
  bool writesSucceed = true;
  int reloads = 0;
  @override
  Future<void> reload() async {
    reloads++;
  }

  @override
  String? getString(String key) => values[key];
  @override
  Future<bool> setString(String key, String value) async {
    if (!writesSucceed) return false;
    values[key] = value;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeProStore store;
  late ProService pro;
  late MemoryPreferences disk;
  late FocusPreferences preferences;
  final study = DurationWeights({25: 50, 45: 30, 60: 20});
  setUp(() async {
    store = FakeProStore(owned: true);
    pro = ProService.forTesting(store);
    await pro.initialize();
    disk = MemoryPreferences();
    preferences = FocusPreferences(
      entitlement: pro,
      loadPreferences: () async => disk,
    );
    await preferences.load();
  });
  tearDown(() async {
    preferences.dispose();
    pro.dispose();
    await store.dispose();
  });

  test('named presets and active weights survive service recreation', () async {
    await preferences.savePreset(name: ' Study ', configuration: study);
    final id = preferences.presets.single.id;
    await preferences.apply(id);
    final reloaded = FocusPreferences(
      entitlement: pro,
      loadPreferences: () async => disk,
    );
    await reloaded.load();
    expect(reloaded.presets.single.name, 'Study');
    expect(reloaded.activeId, id);
    expect(reloaded.current.weights, study.weights);
    reloaded.dispose();
  });
  test(
    'editing active preset updates current weights; deletion keeps the current selection',
    () async {
      await preferences.savePreset(name: 'Study', configuration: study);
      final id = preferences.presets.single.id;
      await preferences.apply(id);
      final work = DurationWeights({30: 50, 50: 50});
      await preferences.savePreset(id: id, name: 'Work', configuration: work);
      expect(preferences.current.weights, work.weights);
      await preferences.delete(id);
      expect(preferences.presets, isEmpty);
      expect(preferences.activeId, isNull);
      expect(preferences.current.weights, work.weights);
      await expectLater(
        preferences.savePreset(
          id: id,
          name: 'Stale editor',
          configuration: study,
        ),
        throwsStateError,
      );
    },
  );
  test('invalid or duplicate names never overwrite existing presets', () async {
    await preferences.savePreset(name: 'Study', configuration: study);
    final saved = disk.values[FocusPreferences.storageKey];
    for (final name in ['', ' study ', 'a' * 41, 'bad\nname']) {
      await expectLater(
        preferences.savePreset(name: name, configuration: study),
        throwsArgumentError,
      );
    }
    expect(disk.values[FocusPreferences.storageKey], saved);
    expect(preferences.presets, hasLength(1));
  });
  test(
    'failed persistence leaves memory and disk unchanged and later save recovers',
    () async {
      await preferences.saveCurrent(study);
      final old = disk.values[FocusPreferences.storageKey];
      disk.writesSucceed = false;
      await expectLater(
        preferences.saveCurrent(DurationWeights({90: 100})),
        throwsStateError,
      );
      expect(preferences.current.weights, study.weights);
      expect(disk.values[FocusPreferences.storageKey], old);
      disk.writesSucceed = true;
      await preferences.saveCurrent(DurationWeights({90: 100}));
      expect(preferences.current.weights, {90: 100});
    },
  );
  test('serialized concurrent saves retain both changes', () async {
    await Future.wait([
      preferences.saveCurrent(study),
      preferences.savePreset(
        name: 'Work',
        configuration: DurationWeights({30: 50, 50: 50}),
      ),
    ]);
    expect(preferences.current.weights, study.weights);
    expect(preferences.presets.single.name, 'Work');
  });
  test('free state cannot apply/edit/delete but retains saved data', () async {
    await preferences.savePreset(name: 'Study', configuration: study);
    final id = preferences.presets.single.id;
    final old = disk.values[FocusPreferences.storageKey];
    store.emit(
      const ProStoreResult(ProPurchaseState.ready, verifiedEntitlement: false),
    );
    await expectLater(preferences.apply(id), throwsStateError);
    await expectLater(preferences.saveCurrent(study), throwsStateError);
    await expectLater(preferences.delete(id), throwsStateError);
    expect(disk.values[FocusPreferences.storageKey], old);
    expect(preferences.presets.single.name, 'Study');
  });
  test(
    'invalid/all-zero persisted weights are skipped while valid records survive',
    () async {
      disk.values[FocusPreferences.storageKey] = jsonEncode({
        'version': 1,
        'current': {'25': 0},
        'activeId': 'invalid',
        'presets': [
          FocusPreset(
            id: 'valid',
            name: 'Study',
            configuration: study,
          ).toJson(),
          {
            'id': 'invalid',
            'name': 'Broken',
            'weights': {'25': 0},
          },
        ],
      });
      final reloaded = FocusPreferences(
        entitlement: pro,
        loadPreferences: () async => disk,
      );
      await reloaded.load();
      expect(reloaded.hadInvalidData, true);
      expect(reloaded.presets.single.id, 'valid');
      expect(reloaded.activeId, isNull);
      expect(reloaded.current.weights.values.reduce((a, b) => a + b), 100);
      reloaded.dispose();
    },
  );
  test('unknown schema stays intact and load can retry after repair', () async {
    disk.values[FocusPreferences.storageKey] = '{"version":99,"presets":[]}';
    final reloaded = FocusPreferences(
      entitlement: pro,
      loadPreferences: () async => disk,
    );
    await expectLater(reloaded.load(), throwsFormatException);
    expect(
      disk.values[FocusPreferences.storageKey],
      '{"version":99,"presets":[]}',
    );
    disk.values.remove(FocusPreferences.storageKey);
    await reloaded.load();
    expect(reloaded.isLoaded, true);
    reloaded.dispose();
  });
}
