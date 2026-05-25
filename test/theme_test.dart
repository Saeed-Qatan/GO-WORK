import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/theme/app_theme.dart';
import 'package:gowork/theme/app_shadows.dart';

void main() {
  group('Theme & Colors Tests', () {
    test('AppColors should have correct brand colors', () {
      expect(AppColors.primary, const Color(0xFF2962FF));
      expect(AppColors.secondary, const Color(0xFF0039CB));
    });

    test('AppTheme lightTheme should have correct color scheme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.primaryColor, AppColors.primary);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.error, AppColors.error);
    });

    test('AppTheme should use Cairo font', () {
      final theme = AppTheme.lightTheme;
      // We check if the elevated button theme uses Cairo as explicitly defined
      expect(
        theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.fontFamily,
        'Cairo',
      );
    });

    test('AppShadows should return valid BoxShadow lists', () {
      expect(AppShadows.softGlow.isNotEmpty, true);
      expect(AppShadows.cardShadow.isNotEmpty, true);
      expect(AppShadows.floatingShadow.isNotEmpty, true);
      expect(AppShadows.insetShadow.isNotEmpty, true);
    });
  });
}
