import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/brand_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Lexend',
      scaffoldBackgroundColor: BrandColors.shadeBlack,
      colorScheme: const ColorScheme.dark(
        primary: BrandColors.primaryGreen,
        onPrimary: BrandColors.shadeBlack,
        secondary: BrandColors.primaryGreenLight,
        onSecondary: BrandColors.shadeBlack,
        surface: BrandColors.lightGray,
        onSurface: BrandColors.white,
        error: BrandColors.error,
        onError: BrandColors.white,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: BrandColors.shadeBlack,
        foregroundColor: BrandColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: BrandColors.white,
        ),
        iconTheme: IconThemeData(color: BrandColors.white),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: BrandColors.lightGray,
        elevation: 0,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(BrandColors.primaryGreen),
          foregroundColor: WidgetStatePropertyAll(BrandColors.shadeBlack),
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
          foregroundColor: const WidgetStatePropertyAll(BrandColors.white),
          side: const WidgetStatePropertyAll(
            BorderSide(color: BrandColors.lightGray, width: 1.5),
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
          foregroundColor: const WidgetStatePropertyAll(BrandColors.primaryGreen),
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
        fillColor: BrandColors.lightGray,
        hintStyle: const TextStyle(
          fontFamily: 'Lexend',
          color: BrandColors.textHint,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Lexend',
          color: BrandColors.textSecondary,
        ),
        prefixIconColor: BrandColors.textMuted,
        suffixIconColor: BrandColors.textMuted,
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
          borderSide: const BorderSide(
            color: BrandColors.primaryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: BrandColors.error,
            width: 1.5,
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BrandColors.shadeBlack,
        selectedItemColor: BrandColors.primaryGreen,
        unselectedItemColor: BrandColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Lexend',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BrandColors.shadeBlack,
        indicatorColor: BrandColors.primaryGreen.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(
            fontFamily: 'Lexend',
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: BrandColors.lightGray,
        selectedColor: BrandColors.primaryGreen.withValues(alpha: 0.2),
        labelStyle: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 13,
          color: BrandColors.white,
        ),
        side: BorderSide.none,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BrandColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: BrandColors.lightGray,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: BrandColors.white,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: BrandColors.divider,
        thickness: 0.5,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BrandColors.primaryGreen,
        foregroundColor: BrandColors.shadeBlack,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: BrandColors.primaryGreen,
        unselectedLabelColor: BrandColors.textMuted,
        indicatorColor: BrandColors.primaryGreen,
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
      listTileTheme: const ListTileThemeData(
        textColor: BrandColors.white,
        iconColor: BrandColors.textSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BrandColors.lightGray,
        contentTextStyle: const TextStyle(
          fontFamily: 'Lexend',
          color: BrandColors.white,
        ),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
