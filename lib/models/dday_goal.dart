import 'package:flutter/widgets.dart';

/// A calendar date, independent of time-of-day and UTC offset.
class DDayGoal {
  DDayGoal({required String name, required DateTime targetDate})
    : name = name.trim(),
      targetDate = DateTime(targetDate.year, targetDate.month, targetDate.day) {
    if (this.name.isEmpty ||
        this.name.characters.length > 40 ||
        RegExp(r'[\x00-\x1f\x7f]').hasMatch(this.name)) {
      throw ArgumentError('Use a goal name with 1–40 characters');
    }
    if (targetDate.year < 1900 || targetDate.year > 2200) {
      throw ArgumentError('Unsupported goal date');
    }
  }

  final String name;
  final DateTime targetDate;

  int daysRemaining(DateTime today) {
    // UTC here represents calendar components, not a conversion of local time.
    // Local-midnight differences can be 23/25 hours across daylight saving.
    return DateTime.utc(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
  }

  String countdown(DateTime today) {
    final days = daysRemaining(today);
    if (days == 0) return 'D-Day';
    return days > 0 ? 'D-$days' : 'D+${-days}';
  }

  Map<String, Object> toJson() => {
    'version': 1,
    'name': name,
    'date':
        '${targetDate.year.toString().padLeft(4, '0')}-'
        '${targetDate.month.toString().padLeft(2, '0')}-'
        '${targetDate.day.toString().padLeft(2, '0')}',
  };

  factory DDayGoal.fromJson(Object? value) {
    if (value is! Map ||
        value['version'] != 1 ||
        value['name'] is! String ||
        value['date'] is! String) {
      throw const FormatException('Invalid goal');
    }
    final date = value['date'] as String;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      throw const FormatException('Invalid goal date');
    }
    final parts = date.split('-').map(int.parse).toList();
    final parsed = DateTime(parts[0], parts[1], parts[2]);
    if (parsed.year != parts[0] ||
        parsed.month != parts[1] ||
        parsed.day != parts[2]) {
      throw const FormatException('Invalid calendar date');
    }
    return DDayGoal(name: value['name'] as String, targetDate: parsed);
  }
}
