import 'package:flutter/material.dart';

class AppShadows {
  static List<BoxShadow> card(Color color) => [
    BoxShadow(
      color: color,
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> button(Color color) => [
    BoxShadow(
      color: color,
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> iconBadge(Color color) => [
    BoxShadow(
      color: color,
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> statBadge(Color color) => [
    BoxShadow(
      color: color,
      blurRadius: 10,
      spreadRadius: 1,
      offset: const Offset(0, 3),
    ),
  ];
}
