import 'package:flutter/material.dart';

import 'appbar_theme.dart';
import 'elevated_button_theme.dart';
import 'card_theme.dart';
import 'input_theme.dart';
import 'app_palette.dart';
import 'switch_theme.dart';
import 'text_theme.dart';

class LightTheme {
  LightTheme._();

  static ThemeData get theme {
    const palette = AppPalette.light;

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      primaryColor: palette.primary,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: Brightness.light,
        primary: palette.primary,
        secondary: palette.secondary,
        surface: palette.surface,
        error: palette.error,
      ),
      fontFamily: 'Cairo',
      extensions: const [palette],
      textTheme: appTextTheme(palette),
      appBarTheme: appAppBarTheme(palette),
      inputDecorationTheme: appInputDecorationTheme(palette),
      elevatedButtonTheme: appElevatedButtonTheme(palette),
      cardTheme: appCardTheme(palette),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      switchTheme: appSwitchTheme(palette),
    );
  }
}
