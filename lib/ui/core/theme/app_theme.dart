import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Matrix Digital Rain Color Palette
class AppColors {
  AppColors._();
  static const Color vampireBlack = Color(0xFF0D0208);
  static const Color darkGreen = Color(0xFF003B00);
  static const Color mediumGreen = Color(0xFF008F11);
  static const Color brightGreen = Color(0xFF00FF41);
}

/// Application theme configuration.
///
/// Provides Material 3 themes for both light and dark modes.
class AppTheme {
  /// Private constructor to prevent instantiation.
  AppTheme._();

  /// Light theme configuration.
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brightGreen,
      brightness: Brightness.light,
      surface: AppColors.vampireBlack,
      primary: AppColors.brightGreen,
    );

    return _buildTheme(colorScheme);
  }

  /// Dark theme configuration.
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brightGreen,
      brightness: Brightness.dark,
      surface: AppColors.vampireBlack,
      primary: AppColors.brightGreen,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    // Premium Typography: Outfit for headlines, Inter for body
    final baseTextTheme = GoogleFonts.interTextTheme();
    final headlineTheme = GoogleFonts.outfitTextTheme();

    final textTheme = baseTextTheme
        .copyWith(
          displayLarge: headlineTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
          ),
          displayMedium: headlineTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
          displaySmall: headlineTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineLarge: headlineTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: headlineTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: headlineTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          titleLarge: headlineTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleMedium: headlineTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          titleSmall: headlineTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: colorScheme.primary, width: 2),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        labelStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
