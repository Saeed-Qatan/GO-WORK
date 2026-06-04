import 'package:flutter/material.dart';

import 'app_palette.dart';

AppBarTheme appAppBarTheme(AppPalette palette) {
  return AppBarTheme(
    backgroundColor: palette.background,
    foregroundColor: palette.textPrimary,
    surfaceTintColor: palette.background,
    elevation: 0,
    scrolledUnderElevation: 0,
  );
}
