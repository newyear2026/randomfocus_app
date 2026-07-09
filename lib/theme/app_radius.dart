import 'package:flutter/material.dart';

class AppRadius {
  static const double input = 12;
  static const double badge = 14;
  static const double tile = 16;
  static const double card = 18;
  static const double cardLarge = 20;
  static const double dialog = 28;
  static const double button = 30;
  static const double heroButton = 36;

  static BorderRadius get inputBorder => BorderRadius.circular(input);
  static BorderRadius get tileBorder => BorderRadius.circular(tile);
  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get largeCardBorder => BorderRadius.circular(cardLarge);
  static BorderRadius get dialogBorder => BorderRadius.circular(dialog);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get heroButtonBorder => BorderRadius.circular(heroButton);
}
