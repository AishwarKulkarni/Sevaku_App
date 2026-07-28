import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/app_colors.dart';

class AppTypography {
  final AppColors colors;
  static const String _fontFamily = 'Lexend';

  const AppTypography(this.colors);

  // Headings
  TextStyle get headingXL => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.white,
        height: 1.2,
      );

  TextStyle get headingLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colors.white,
        height: 1.3,
      );

  TextStyle get headingMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colors.white,
        height: 1.3,
      );

  TextStyle get headingSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.white,
        height: 1.3,
      );

  // Body
  TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.white,
        height: 1.5,
      );

  TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.white,
        height: 1.5,
      );

  TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.5,
      );

  // Labels
  TextStyle get labelLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.white,
      );

  TextStyle get labelMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      );

  TextStyle get labelSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: colors.textMuted,
      );

  // Special
  TextStyle get buttonText => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.shadeBlack,
      );

  TextStyle get caption => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: colors.textMuted,
      );

  TextStyle get price => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colors.primaryGreen,
      );

  TextStyle get rating => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.starYellow,
      );
}

// Extension to make it easier to access typography from context
extension AppTypographyExtension on BuildContext {
  AppTypography get typography => AppTypography(colors);
}
