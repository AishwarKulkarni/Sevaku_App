import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  // Primary
  final Color primaryGreen;
  final Color primaryGreenLight;
  final Color primaryGreenDark;

  // Backgrounds
  final Color shadeBlack; // naming kept for compatibility, acts as main bg
  final Color darkBackground;

  // Surfaces
  final Color lightGray; // acts as main surface color
  final Color cardDark;
  final Color surfaceLight;
  final Color divider;

  // Text
  final Color white; // acts as primary text color
  final Color textSecondary;
  final Color textMuted;
  final Color textHint;

  // Status
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // Ratings
  final Color starYellow;

  // Gradients
  final LinearGradient primaryGradient;
  final LinearGradient darkGradient;
  final LinearGradient cardGradient;

  const AppColors({
    required this.primaryGreen,
    required this.primaryGreenLight,
    required this.primaryGreenDark,
    required this.shadeBlack,
    required this.darkBackground,
    required this.lightGray,
    required this.cardDark,
    required this.surfaceLight,
    required this.divider,
    required this.white,
    required this.textSecondary,
    required this.textMuted,
    required this.textHint,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.starYellow,
    required this.primaryGradient,
    required this.darkGradient,
    required this.cardGradient,
  });

  // Dark Theme Colors
  static const AppColors dark = AppColors(
    primaryGreen: Color(0xFF38E078),
    primaryGreenLight: Color(0xFF5EFFA0),
    primaryGreenDark: Color(0xFF1DB954),
    shadeBlack: Color(0xFF141414),
    darkBackground: Color(0xFF0A0A0A),
    lightGray: Color(0xFF292929),
    cardDark: Color(0xFF1E1E1E),
    surfaceLight: Color(0xFF333333),
    divider: Color(0xFF3A3A3A),
    white: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B0B0),
    textMuted: Color(0xFF808080),
    textHint: Color(0xFF5A5A5A),
    success: Color(0xFF38E078),
    warning: Color(0xFFFFA726),
    error: Color(0xFFEF5350),
    info: Color(0xFF42A5F5),
    starYellow: Color(0xFFFFD700),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF38E078), Color(0xFF5EFFA0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    darkGradient: LinearGradient(
      colors: [Color(0xFF141414), Color(0xFF1A1A2E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFF292929), Color(0xFF1F1F1F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Light Theme Colors
  static const AppColors light = AppColors(
    primaryGreen: Color(0xFF1DB954), // Darker green for contrast
    primaryGreenLight: Color(0xFF38E078),
    primaryGreenDark: Color(0xFF128C3A),
    shadeBlack: Color(0xFFF8F9FA), // Off-white for main background
    darkBackground: Color(0xFFE9ECEF), // Slightly darker background
    lightGray: Color(0xFFFFFFFF), // White for cards/surfaces
    cardDark: Color(0xFFF1F3F5),
    surfaceLight: Color(0xFFE9ECEF),
    divider: Color(0xFFDEE2E6),
    white: Color(0xFF212529), // Dark slate for primary text
    textSecondary: Color(0xFF495057),
    textMuted: Color(0xFF868E96),
    textHint: Color(0xFFADB5BD),
    success: Color(0xFF1DB954),
    warning: Color(0xFFF57C00),
    error: Color(0xFFD32F2F),
    info: Color(0xFF1976D2),
    starYellow: Color(0xFFFFC107),
    primaryGradient: LinearGradient(
      colors: [Color(0xFF1DB954), Color(0xFF38E078)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    darkGradient: LinearGradient(
      colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  @override
  AppColors copyWith({
    Color? primaryGreen,
    Color? primaryGreenLight,
    Color? primaryGreenDark,
    Color? shadeBlack,
    Color? darkBackground,
    Color? lightGray,
    Color? cardDark,
    Color? surfaceLight,
    Color? divider,
    Color? white,
    Color? textSecondary,
    Color? textMuted,
    Color? textHint,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? starYellow,
    LinearGradient? primaryGradient,
    LinearGradient? darkGradient,
    LinearGradient? cardGradient,
  }) {
    return AppColors(
      primaryGreen: primaryGreen ?? this.primaryGreen,
      primaryGreenLight: primaryGreenLight ?? this.primaryGreenLight,
      primaryGreenDark: primaryGreenDark ?? this.primaryGreenDark,
      shadeBlack: shadeBlack ?? this.shadeBlack,
      darkBackground: darkBackground ?? this.darkBackground,
      lightGray: lightGray ?? this.lightGray,
      cardDark: cardDark ?? this.cardDark,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      divider: divider ?? this.divider,
      white: white ?? this.white,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textHint: textHint ?? this.textHint,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      starYellow: starYellow ?? this.starYellow,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      darkGradient: darkGradient ?? this.darkGradient,
      cardGradient: cardGradient ?? this.cardGradient,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      primaryGreen: Color.lerp(primaryGreen, other.primaryGreen, t)!,
      primaryGreenLight: Color.lerp(primaryGreenLight, other.primaryGreenLight, t)!,
      primaryGreenDark: Color.lerp(primaryGreenDark, other.primaryGreenDark, t)!,
      shadeBlack: Color.lerp(shadeBlack, other.shadeBlack, t)!,
      darkBackground: Color.lerp(darkBackground, other.darkBackground, t)!,
      lightGray: Color.lerp(lightGray, other.lightGray, t)!,
      cardDark: Color.lerp(cardDark, other.cardDark, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      white: Color.lerp(white, other.white, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      starYellow: Color.lerp(starYellow, other.starYellow, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      darkGradient: LinearGradient.lerp(darkGradient, other.darkGradient, t)!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
    );
  }
}

// Extension to make it easier to access colors from context
extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}
