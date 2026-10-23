import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/duration_weights.dart';

class TicketRandom implements Random {
  TicketRandom(this.ticket);
  final int ticket;
  @override
  int nextInt(int max) {
    expect(max, 100);
    return ticket;
  }

  @override
  bool nextBool() => throw UnimplementedError();
  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  test('all 100 tickets implement the exact 50/30/20 probabilities', () {
    final weights = DurationWeights({25: 50, 45: 30, 60: 20});
    final counts = <int, int>{};
    for (var ticket = 0; ticket < 100; ticket++) {
      final minutes = weights.draw(TicketRandom(ticket));
      counts[minutes] = (counts[minutes] ?? 0) + 1;
    }
    expect(counts, {25: 50, 45: 30, 60: 20});
  });
  test('zero weights are never selected, including boundary ticket zero', () {
    final weights = DurationWeights({25: 0, 45: 100, 60: 0});
    expect(weights.draw(TicketRandom(0)), 45);
    expect(weights.draw(TicketRandom(99)), 45);
  });
  test('equalize six choices deterministically totals 100', () {
    final weights = DurationWeights.equal(DurationWeights.choices);
    expect(weights.weights.values.toList(), [17, 17, 17, 17, 16, 16]);
  });
  test(
    'adjusting a weight preserves ratios and redistributes all-zero others',
    () {
      final weights = DurationWeights({25: 50, 45: 30, 60: 20});
      expect(weights.withWeight(25, 80).weights, {25: 80, 45: 12, 60: 8});
      expect(weights.withWeight(25, 100).withWeight(25, 40).weights, {
        25: 40,
        45: 30,
        60: 30,
      });
      for (var percent = 0; percent <= 100; percent++) {
        expect(
          weights
              .withWeight(45, percent)
              .weights
              .values
              .reduce((a, b) => a + b),
          100,
        );
      }
    },
  );
  test(
    'selection supports single duration and does not remove the last choice',
    () {
      final single = DurationWeights({25: 100});
      expect(single.withWeight(25, 0).weights, {25: 100});
      expect(single.withSelected(45, true).weights, {25: 50, 45: 50});
      expect(single.withSelected(45, true).withSelected(25, false).weights, {
        45: 100,
      });
      expect(() => single.withSelected(25, false), throwsStateError);
    },
  );
  test(
    'invalid, unsupported, all-zero and non-100 configurations are rejected',
    () {
      for (final raw in <Map<int, int>>[
        {},
        {25: 0},
        {25: -1, 45: 101},
        {20: 100},
        {25: 99},
      ]) {
        expect(() => DurationWeights(raw), throwsArgumentError);
      }
      expect(
        () => DurationWeights.normalized({25: 0, 45: 0}),
        throwsArgumentError,
      );
      expect(() => DurationWeights.fromJson({'25': 0}), throwsFormatException);
      expect(
        () => DurationWeights.fromJson({'25': '100'}),
        throwsFormatException,
      );
    },
  );
  test(
    'configuration is immutable and round-trips without changing tickets',
    () {
      final raw = {25: 50, 45: 30, 60: 20};
      final weights = DurationWeights(raw);
      raw[25] = 0;
      expect(weights.weights[25], 50);
      expect(() => weights.weights[25] = 0, throwsUnsupportedError);
      expect(
        DurationWeights.fromJson(weights.toJson()).weights,
        weights.weights,
      );
    },
  );
}
