import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => _buildTheme(AppColors.dark, Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(AppColors.light, Brightness.light);

  static ThemeData _buildTheme(AppColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Lexend',
      scaffoldBackgroundColor: colors.shadeBlack,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primaryGreen,
        onPrimary: colors.shadeBlack,
        secondary: colors.primaryGreenLight,
        onSecondary: colors.shadeBlack,
        surface: colors.lightGray,
        onSurface: colors.white,
        error: colors.error,
        onError: colors.white,
      ),
      extensions: [colors],

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colors.shadeBlack,
        foregroundColor: colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.white,
        ),
        iconTheme: IconThemeData(color: colors.white),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: colors.lightGray,
        elevation: 0,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(colors.primaryGreen),
          foregroundColor: WidgetStatePropertyAll(colors.shadeBlack),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Lexend',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStatePropertyAll(
            ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(colors.white),
          side: WidgetStatePropertyAll(
            BorderSide(color: colors.lightGray, width: 1.5),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Lexend',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          shape: WidgetStatePropertyAll(
            ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(colors.primaryGreen),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.lightGray,
        hintStyle: TextStyle(
          fontFamily: 'Lexend',
          color: colors.textHint,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Lexend',
          color: colors.textSecondary,
        ),
        prefixIconColor: colors.textMuted,
        suffixIconColor: colors.textMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.primaryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colors.error,
            width: 1.5,
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.shadeBlack,
        selectedItemColor: colors.primaryGreen,
        unselectedItemColor: colors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.shadeBlack,
        indicatorColor: colors.primaryGreen.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Lexend',
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: colors.lightGray,
        selectedColor: colors.primaryGreen.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 13,
          color: colors.white,
        ),
        side: BorderSide.none,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.cardDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colors.lightGray,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.white,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 0.5,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primaryGreen,
        foregroundColor: colors.shadeBlack,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primaryGreen,
        unselectedLabelColor: colors.textMuted,
        indicatorColor: colors.primaryGreen,
        labelStyle: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        textColor: colors.white,
        iconColor: colors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.lightGray,
        contentTextStyle: TextStyle(
          fontFamily: 'Lexend',
          color: colors.white,
        ),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
