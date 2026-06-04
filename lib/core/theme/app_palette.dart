import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color inputBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color success;
  final Color successBackground;
  final Color error;
  final Color errorBackground;
  final Color warning;
  final Color warningBackground;
  final Color info;
  final Color infoBackground;
  final Color border;
  final Color divider;

  const AppPalette({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.inputBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.success,
    required this.successBackground,
    required this.error,
    required this.errorBackground,
    required this.warning,
    required this.warningBackground,
    required this.info,
    required this.infoBackground,
    required this.border,
    required this.divider,
  });

  static const light = AppPalette(
    primary: Color(0xFF2962FF),
    secondary: Color(0xFF0039CB),
    background: Color(0xFFF8F9FA),
    surface: Colors.white,
    inputBackground: Color(0xFFF1F3F5),
    textPrimary: Color(0xFF1E1E1E),
    textSecondary: Color(0xFF6C757D),
    textHint: Color(0xFFAFAFAF),
    success: Color(0xFF2E7D32),
    successBackground: Color(0xFFE8F5E9),
    error: Color(0xFFD32F2F),
    errorBackground: Color(0xFFFFEBEE),
    warning: Color(0xFFED6C02),
    warningBackground: Color(0xFFFFF3E0),
    info: Color(0xFF0288D1),
    infoBackground: Color(0xFFE1F5FE),
    border: Color(0xFFE0E0E0),
    divider: Color(0xFFEEEEEE),
  );

  static const dark = AppPalette(
    primary: Color(0xFF82A4FF),
    secondary: Color(0xFFADC2FF),
    background: Color(0xFF101318),
    surface: Color(0xFF181D24),
    inputBackground: Color(0xFF222933),
    textPrimary: Color(0xFFF3F6FA),
    textSecondary: Color(0xFFB4BECC),
    textHint: Color(0xFF7C8797),
    success: Color(0xFF81C784),
    successBackground: Color(0xFF17351F),
    error: Color(0xFFEF9A9A),
    errorBackground: Color(0xFF3D1818),
    warning: Color(0xFFFFB74D),
    warningBackground: Color(0xFF3D2A12),
    info: Color(0xFF64B5F6),
    infoBackground: Color(0xFF123047),
    border: Color(0xFF323B47),
    divider: Color(0xFF28303A),
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? inputBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? success,
    Color? successBackground,
    Color? error,
    Color? errorBackground,
    Color? warning,
    Color? warningBackground,
    Color? info,
    Color? infoBackground,
    Color? border,
    Color? divider,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      inputBackground: inputBackground ?? this.inputBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      success: success ?? this.success,
      successBackground: successBackground ?? this.successBackground,
      error: error ?? this.error,
      errorBackground: errorBackground ?? this.errorBackground,
      warning: warning ?? this.warning,
      warningBackground: warningBackground ?? this.warningBackground,
      info: info ?? this.info,
      infoBackground: infoBackground ?? this.infoBackground,
      border: border ?? this.border,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBackground: Color.lerp(
        successBackground,
        other.successBackground,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBackground: Color.lerp(
        warningBackground,
        other.warningBackground,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

class AppColors {
  AppColors._();

  static AppPalette _activePalette = AppPalette.light;

  static void usePalette(AppPalette palette) {
    _activePalette = palette;
  }

  static void useDarkTheme(bool enabled) {
    _activePalette = enabled ? AppPalette.dark : AppPalette.light;
  }

  static Color get primary => _activePalette.primary;
  static Color get secondary => _activePalette.secondary;
  static Color get background => _activePalette.background;
  static Color get surface => _activePalette.surface;
  static Color get inputBackground => _activePalette.inputBackground;
  static Color get textPrimary => _activePalette.textPrimary;
  static Color get textSecondary => _activePalette.textSecondary;
  static Color get textHint => _activePalette.textHint;
  static Color get success => _activePalette.success;
  static Color get successBackground => _activePalette.successBackground;
  static Color get error => _activePalette.error;
  static Color get errorBackground => _activePalette.errorBackground;
  static Color get warning => _activePalette.warning;
  static Color get warningBackground => _activePalette.warningBackground;
  static Color get info => _activePalette.info;
  static Color get infoBackground => _activePalette.infoBackground;
  static Color get border => _activePalette.border;
  static Color get divider => _activePalette.divider;
}

extension AppThemeContext on BuildContext {
  AppPalette get palette {
    return Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
  }
}
