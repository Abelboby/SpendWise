import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color navy = Color(0xFF222831); // Dark navy/almost black
  static const Color darkGrey = Color(0xFF393E46); // Dark grey
  static const Color accent = Color(0xFF00ADB5); // Teal/turquoise
  static const Color lightGrey = Color(0xFFEEEEEE); // Light grey/almost white

  // Theme configurations
  static final realTheme = ColorScheme.fromSeed(
    seedColor: navy,
    primary: navy,
    secondary: accent,
    tertiary: darkGrey,
    surface: lightGrey,
  );

  static final fakeTheme = ColorScheme.fromSeed(
    seedColor: darkGrey,
    primary: darkGrey,
    secondary: accent,
    tertiary: navy,
    surface: lightGrey,
  );

  // Card colors
  static final realCardColor = navy.withAlpha(13);
  static final fakeCardColor = darkGrey.withAlpha(13);

  // Text colors
  static const realTextColor = navy;
  static const fakeTextColor = darkGrey;
}

extension ColorWithValues on Color {
  /// Returns a copy of this color with the given opacity (0.0-1.0) using withAlpha for precision.
  Color withValues(double opacity) {
    return withAlpha((opacity * 255).round());
  }
}
