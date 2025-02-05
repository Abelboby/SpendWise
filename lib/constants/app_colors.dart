import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color navy = Color(0xFF26355D); // #26355D - Dark blue for real mode
  static const Color purple = Color(0xFFAF47D2); // #AF47D2 - Purple for accents
  static const Color orange = Color(0xFFFF8F00); // #FF8F00 - Orange for fake mode
  static const Color yellow = Color(0xFFFFDB00); // #FFDB00 - Yellow for highlights

  // Theme configurations
  static final realTheme = ColorScheme.fromSeed(
    seedColor: navy,
    primary: navy,
    secondary: purple,
    tertiary: yellow,
  );

  static final fakeTheme = ColorScheme.fromSeed(
    seedColor: orange,
    primary: orange,
    secondary: yellow,
    tertiary: purple,
  );

  // Card colors
  static final realCardColor = navy.withOpacity(0.05);
  static final fakeCardColor = orange.withOpacity(0.05);

  // Text colors
  static const realTextColor = navy;
  static const fakeTextColor = orange;
}
