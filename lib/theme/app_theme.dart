/// ============================================================
/// FILE: app_theme.dart
/// PURPOSE: Central design system — colors, typography, spacing,
///          decorations, and the Material [ThemeData] for the app.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Holds all brand and semantic color constants for the PDX app.
/// No state — values are compile-time constants used across widgets.
abstract final class AppColors {
  static const Color primaryGreen = Color(0xFF00704A);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color statusOnTime = Color(0xFF00874A);
  static const Color statusDelayed = Color(0xFFE8A020);
  static const Color statusCancelled = Color(0xFFD0021B);
  static const Color bottomNavBackground = Color(0xFFFFFFFF);
  static const Color bottomNavSelected = Color(0xFF00704A);
  static const Color bottomNavUnselected = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFE0E0E0);

  // Shadow tint used on cards — black at 6% opacity
  static const Color cardShadow = Color(0x0F000000);
}

/// Standard spacing values used for padding and layout rhythm.
/// Base unit is 16px per the PDX design system.
abstract final class AppSpacing {
  static const double base = 16;
  static const EdgeInsets screenHorizontal =
      EdgeInsets.symmetric(horizontal: base);
}

/// Typography helpers that return Inter [TextStyle] instances.
/// Each method accepts a [color] so callers can apply semantic tints.
abstract final class AppTypography {
  /// Returns Inter 24px Bold — used for large section headings.
  /// [color] sets the text color.
  static TextStyle headingLarge(Color color) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  /// Returns Inter 18px SemiBold — used for screen titles and subheadings.
  /// [color] sets the text color.
  static TextStyle headingMedium(Color color) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.35,
      );

  /// Returns Inter 14px Regular — default body copy style.
  /// [color] sets the text color.
  static TextStyle body(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.45,
      );

  /// Returns Inter 12px Regular — used for captions and nav labels.
  /// [color] sets the text color.
  static TextStyle caption(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  /// Returns Inter 16px Bold with letter spacing — used for flight numbers.
  /// [color] sets the text color.
  static TextStyle flightNumber(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
        height: 1.3,
      );

  /// Returns Inter 16px SemiBold — used on primary and secondary buttons.
  /// [color] sets the text color.
  static TextStyle buttonPrimary(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.25,
      );
}

/// Shared decoration constants and helpers for cards and buttons.
abstract final class AppDecorations {
  static const double cardRadius = 12;
  static const double buttonRadius = 12;
  static const double buttonHeight = 52;

  /// Builds a standard PDX card [BoxDecoration] with rounded corners and shadow.
  /// [color] overrides the default surface color when provided.
  /// Returns a [BoxDecoration] ready to use on a [Container].
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: AppColors.cardShadow,
            offset: Offset(0, 2),
          ),
        ],
      );
}

/// Factory for the app's single [ThemeData] instance.
/// Manages no runtime state — [light] is a computed getter.
abstract final class AppTheme {
  /// Builds the light-mode [ThemeData] with Inter font, PDX colors,
  /// and pre-configured card, input, button, and nav bar themes.
  /// Returns the complete theme used by [MaterialApp].
  static ThemeData get light {
    // Base Inter text theme tinted with primary text color
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.divider,
      ),
      dividerColor: AppColors.divider,
      textTheme: textTheme.copyWith(
        headlineLarge: AppTypography.headingLarge(AppColors.textPrimary),
        titleMedium: AppTypography.headingMedium(AppColors.textPrimary),
        bodyMedium: AppTypography.body(AppColors.textPrimary),
        bodySmall: AppTypography.caption(AppColors.textSecondary),
        labelLarge: AppTypography.buttonPrimary(AppColors.background),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.background,
        centerTitle: true,
        titleTextStyle: AppTypography.headingMedium(AppColors.background),
        iconTheme: const IconThemeData(color: AppColors.background),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
        ),
        shadowColor: AppColors.cardShadow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: 14,
        ),
        hintStyle: AppTypography.body(AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.background,
          minimumSize: const Size(double.infinity, AppDecorations.buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
          ),
          textStyle: AppTypography.buttonPrimary(AppColors.background),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          minimumSize: const Size(double.infinity, AppDecorations.buttonHeight),
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.buttonRadius),
          ),
          textStyle: AppTypography.buttonPrimary(AppColors.primaryGreen),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bottomNavBackground,
        selectedItemColor: AppColors.bottomNavSelected,
        unselectedItemColor: AppColors.bottomNavUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
    );
  }
}
