import 'package:flutter/material.dart';

import 'app_palette.dart';

CardThemeData appCardTheme(AppPalette palette) {
  return CardThemeData(
    color: palette.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: palette.border, width: 1),
    ),
  );
}
