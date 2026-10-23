import 'dart:math';

/// Immutable integer percentages. Every valid configuration totals exactly 100.
class DurationWeights {
  DurationWeights(Map<int, int> weights)
    : weights = Map.unmodifiable(
        Map.fromEntries(
          weights.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
        ),
      ) {
    if (weights.isEmpty ||
        weights.keys.any((m) => !choices.contains(m)) ||
        weights.values.any((w) => w < 0 || w > 100) ||
        weights.values.fold(0, (a, b) => a + b) != 100) {
      throw ArgumentError('Choose supported durations totaling 100%');
    }
  }
  static const choices = [25, 30, 45, 50, 60, 90];
  final Map<int, int> weights;
  List<int> get durations => weights.keys.toList(growable: false);

  factory DurationWeights.equal(Iterable<int> durations) =>
      DurationWeights.normalized({for (final m in durations) m: 1});

  factory DurationWeights.normalized(Map<int, int> raw) {
    if (raw.isEmpty ||
        raw.keys.any((m) => !choices.contains(m)) ||
        raw.values.any((w) => w < 0) ||
        raw.values.every((w) => w == 0)) {
      throw ArgumentError('Invalid weights');
    }
    return DurationWeights(_distribute(raw, 100));
  }

  static Map<int, int> _distribute(Map<int, int> raw, int total) {
    final keys = raw.keys.toList()..sort();
    final sum = raw.values.fold(0, (a, b) => a + b);
    final source = sum == 0 ? {for (final key in keys) key: 1} : raw;
    final divisor = sum == 0 ? keys.length : sum;
    final result = {
      for (final key in keys) key: source[key]! * total ~/ divisor,
    };
    final ranked = [...keys]
      ..sort((a, b) {
        final compare = (source[b]! * total % divisor).compareTo(
          source[a]! * total % divisor,
        );
        return compare == 0 ? a.compareTo(b) : compare;
      });
    final remainder = total - result.values.fold(0, (a, b) => a + b);
    for (var i = 0; i < remainder; i++) {
      result[ranked[i]] = result[ranked[i]]! + 1;
    }
    return result;
  }

  DurationWeights withWeight(int minutes, int percent) {
    if (!weights.containsKey(minutes) || percent < 0 || percent > 100) {
      throw ArgumentError('Invalid probability');
    }
    if (weights.length == 1) return this;
    final others = Map<int, int>.from(weights)..remove(minutes);
    return DurationWeights({
      ..._distribute(others, 100 - percent),
      minutes: percent,
    });
  }

  DurationWeights withSelected(int minutes, bool selected) {
    if (!choices.contains(minutes)) throw ArgumentError('Unsupported duration');
    if (selected == weights.containsKey(minutes)) return this;
    if (selected) {
      final share = (100 / (weights.length + 1)).round();
      return DurationWeights({
        ..._distribute(weights, 100 - share),
        minutes: share,
      });
    }
    if (weights.length == 1) throw StateError('Keep at least one duration');
    final others = Map<int, int>.from(weights)..remove(minutes);
    return DurationWeights(_distribute(others, 100));
  }

  int draw(Random random) {
    final ticket = random.nextInt(100);
    var cumulative = 0;
    for (final entry in weights.entries) {
      cumulative += entry.value;
      if (ticket < cumulative) return entry.key;
    }
    throw StateError('Invalid random result');
  }

  Map<String, int> toJson() => {
    for (final e in weights.entries) '${e.key}': e.value,
  };
  factory DurationWeights.fromJson(Object? json) {
    if (json is! Map) throw const FormatException('Invalid configuration');
    try {
      return DurationWeights({
        for (final e in json.entries)
          int.parse(e.key as String): e.value as int,
      });
    } catch (_) {
      throw const FormatException('Invalid configuration');
    }
  }
}

class FocusPreset {
  FocusPreset({
    required this.id,
    required String name,
    required this.configuration,
  }) : name = name.trim() {
    if (id.isEmpty ||
        this.name.isEmpty ||
        this.name.length > 40 ||
        RegExp(r'[\x00-\x1f]').hasMatch(this.name)) {
      throw ArgumentError('Invalid preset name');
    }
  }
  final String id;
  final String name;
  final DurationWeights configuration;
  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'weights': configuration.toJson(),
  };
  factory FocusPreset.fromJson(Object? value) {
    if (value is! Map) throw const FormatException('Invalid preset');
    return FocusPreset(
      id: value['id'] as String,
      name: value['name'] as String,
      configuration: DurationWeights.fromJson(value['weights']),
    );
  }
}
