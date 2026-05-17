import 'package:flutter/material.dart';

class BrandColors {
  BrandColors._();

  // Primary
  static const Color primaryGreen = Color(0xFF38E078);
  static const Color primaryGreenLight = Color(0xFF5EFFA0);
  static const Color primaryGreenDark = Color(0xFF1DB954);

  // Backgrounds
  static const Color shadeBlack = Color(0xFF141414);
  static const Color darkBackground = Color(0xFF0A0A0A);

  // Surfaces
  static const Color lightGray = Color(0xFF292929);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF333333);
  static const Color divider = Color(0xFF3A3A3A);

  // Text
  static const Color white = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF808080);
  static const Color textHint = Color(0xFF5A5A5A);

  // Status
  static const Color success = Color(0xFF38E078);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // Ratings
  static const Color starYellow = Color(0xFFFFD700);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [shadeBlack, Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [lightGray, Color(0xFF1F1F1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
