/// Progress toward collecting seven focus days.
///
/// A day is a calendar date in the device's local zone, stored as `yyyy-MM-dd`
/// and counted at most once. Days do not have to be consecutive and there is
/// no deadline, so progress only grows: a missed day costs nothing. Once the
/// badge is earned the value is frozen, which is what keeps the reward from
/// being granted twice.
class FocusChallenge {
  FocusChallenge({required Iterable<String> countedDays, String? badgeEarnedOn})
    : this._(_normalize(countedDays), badgeEarnedOn);

  FocusChallenge._(List<String> countedDays, String? badgeEarnedOn)
    : countedDays = List.unmodifiable(countedDays),
      // Seven days without an earn date can only come from a value written by
      // an interrupted upgrade. Treat the last counted day as the earn date
      // rather than letting the badge sit unawarded forever.
      badgeEarnedOn =
          badgeEarnedOn ??
          (countedDays.length >= goalDays ? countedDays.last : null);

  static const int goalDays = 7;

  static final FocusChallenge empty = FocusChallenge(countedDays: const []);

  /// Counted days as `yyyy-MM-dd`, ascending and without duplicates.
  final List<String> countedDays;

  /// The day the badge was earned, or `null` while the challenge is running.
  final String? badgeEarnedOn;

  int get progress => countedDays.length;

  bool get isComplete => badgeEarnedOn != null;

  bool countsDay(String dayKey) => countedDays.contains(dayKey);

  /// The same challenge with [dayKey] counted.
  ///
  /// Returns `this` when the day is already counted or the badge is earned, so
  /// callers can record every completed session without checking first.
  FocusChallenge withDay(String dayKey) {
    if (isComplete || countsDay(dayKey)) return this;
    if (!isDateKey(dayKey)) {
      throw ArgumentError.value(dayKey, 'dayKey', 'Expected yyyy-MM-dd');
    }
    final next = [...countedDays, dayKey];
    // The badge belongs to the day that completed the set, which is not
    // necessarily the latest date if the device clock moved backwards.
    return FocusChallenge(
      countedDays: next,
      badgeEarnedOn: next.length >= goalDays ? dayKey : null,
    );
  }

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static final RegExp _dateKeyPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static bool isDateKey(Object? value) {
    if (value is! String || !_dateKeyPattern.hasMatch(value)) return false;
    final parts = value.split('-').map(int.parse).toList();
    final parsed = DateTime(parts[0], parts[1], parts[2]);
    return parsed.year == parts[0] &&
        parsed.month == parts[1] &&
        parsed.day == parts[2];
  }

  /// Sorted, deduplicated and capped at [goalDays]; the challenge never needs
  /// to remember more days than it takes to finish.
  static List<String> _normalize(Iterable<String> days) {
    for (final day in days) {
      if (!isDateKey(day)) {
        throw ArgumentError.value(day, 'countedDays', 'Expected yyyy-MM-dd');
      }
    }
    final unique = days.toSet().toList()..sort();
    return unique.length > goalDays ? unique.sublist(0, goalDays) : unique;
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'days': countedDays,
    'badgeEarnedOn': badgeEarnedOn,
  };

  factory FocusChallenge.fromJson(Object? value) {
    if (value is! Map || value['version'] != 1 || value['days'] is! List) {
      throw const FormatException('Invalid challenge');
    }
    final days = (value['days'] as List).map((day) {
      if (!isDateKey(day)) {
        throw const FormatException('Invalid challenge day');
      }
      return day as String;
    });
    final earnedOn = value['badgeEarnedOn'];
    if (earnedOn != null && !isDateKey(earnedOn)) {
      throw const FormatException('Invalid badge date');
    }
    return FocusChallenge(
      countedDays: days,
      badgeEarnedOn: earnedOn as String?,
    );
  }
}
