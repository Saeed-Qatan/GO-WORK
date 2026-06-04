import 'package:flutter/material.dart';

import 'app_palette.dart';

InputDecorationTheme appInputDecorationTheme(AppPalette palette) {
  return InputDecorationTheme(
    filled: true,
    fillColor: palette.inputBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: palette.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: palette.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: palette.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: palette.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: palette.error, width: 2),
    ),
    hintStyle: TextStyle(color: palette.textHint, fontSize: 14),
    labelStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
    prefixIconColor: palette.textSecondary,
  );
}
