import 'package:flutter/material.dart';

import 'app_palette.dart';

SwitchThemeData appSwitchTheme(AppPalette palette) {
  return SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? palette.primary
          : palette.textHint,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? palette.primary.withValues(alpha: 0.28)
          : palette.border,
    ),
  );
}
