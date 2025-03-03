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
    background: lightGrey,
    surface: Colors.white,
  );

  static final fakeTheme = ColorScheme.fromSeed(
    seedColor: darkGrey,
    primary: darkGrey,
    secondary: accent,
    tertiary: navy,
    background: lightGrey,
    surface: Colors.white,
  );

  // Card colors
  static final realCardColor = navy.withOpacity(0.05);
  static final fakeCardColor = darkGrey.withOpacity(0.05);

  // Text colors
  static const realTextColor = navy;
  static const fakeTextColor = darkGrey;
}
