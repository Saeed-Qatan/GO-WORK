import 'package:flutter/material.dart';

import 'app_palette.dart';

ElevatedButtonThemeData appElevatedButtonTheme(AppPalette palette) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: palette.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
    ),
  );
}
