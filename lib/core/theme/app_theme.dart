import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Centralized [ThemeData] builder.
///
/// Currently mirrors the inline theme that used to live in `main.dart`.
/// Add typography, button styles, and dark-mode variants here as they are
/// designed.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      fontFamily: 'Inter',
      scaffoldBackgroundColor: kScaffold,
      colorScheme: ColorScheme.fromSeed(seedColor: kHijauTua),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
