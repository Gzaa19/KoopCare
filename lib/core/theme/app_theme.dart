import 'package:flutter/material.dart';

import '../app_colors.dart';

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
