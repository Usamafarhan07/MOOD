import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Global Theme Mode State
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  // Light Brand Colors
  static const Color primary = Color(0xFF442A22); // Dark Golden Brown
  static const Color secondary = Color(0xFFA04022); // Terracotta Drift start
  static const Color secondaryContainer = Color(0xFFFE8763); // Terracotta Drift end
  static const Color background = Color(0xFFFCF9F4); // Warm Cream
  static const Color surfaceContainerLow = Color(0xFFF6F3EE);
  static const Color surfaceContainerHigh = Color(0xFFEBE8E3);
  static const Color outlineVariant = Color(0xFFD4C3BE); // For ghost borders

  // Dark Brand Colors
  static const Color darkPrimary = Color(0xFFFCF9F4); // Warm Cream
  static const Color darkSecondary = Color(0xFFFE8763); // Terracotta Drift end
  static const Color darkBackground = Color(0xFF16100E); // Near black brown
  static const Color darkSurfaceContainerLow = Color(0xFF231B19);
  static const Color darkSurfaceContainerHigh = Color(0xFF2F2421);
  static const Color darkOutlineVariant = Color(0xFF4E3A35);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        surface: background,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerHigh: surfaceContainerHigh,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _buildTextTheme(false),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: darkBackground,
        secondary: darkSecondary,
        surface: darkBackground,
        surfaceContainerLow: darkSurfaceContainerLow,
        surfaceContainerHigh: darkSurfaceContainerHigh,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: _buildTextTheme(true),
    );
  }

  static TextTheme _buildTextTheme(bool isDark) {
    final baseTheme = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme;
    final textColor = isDark ? darkPrimary : primary;
    
    // Noto Serif for headlines and display
    final notoSerif = GoogleFonts.notoSerifTextTheme(baseTheme).copyWith(
      displayLarge: GoogleFonts.notoSerif(
        fontSize: 56,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.02 * 56, // -0.02em
        color: textColor,
      ),
      headlineSmall: GoogleFonts.notoSerif(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );

    // Manrope for body and UI
    final manrope = GoogleFonts.manropeTextTheme(baseTheme).copyWith(
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        color: textColor,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4, // 0.1em
        color: textColor,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2, // 0.1em
        color: textColor,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );

    return notoSerif.merge(manrope);
  }
}
