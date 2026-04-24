import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF442A22); // Dark Golden Brown
  static const Color secondary = Color(0xFFA04022); // Terracotta Drift start
  static const Color secondaryContainer = Color(0xFFFE8763); // Terracotta Drift end
  static const Color background = Color(0xFFFCF9F4); // Warm Cream
  static const Color surfaceContainerLow = Color(0xFFF6F3EE);
  static const Color surfaceContainerHigh = Color(0xFFEBE8E3);
  static const Color outlineVariant = Color(0xFFD4C3BE); // For ghost borders

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: background,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerHigh: surfaceContainerHigh,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _buildTextTheme(),
    );
  }

  static TextTheme _buildTextTheme() {
    final baseTheme = ThemeData.light().textTheme;
    
    // Noto Serif for headlines and display
    final notoSerif = GoogleFonts.notoSerifTextTheme(baseTheme).copyWith(
      displayLarge: GoogleFonts.notoSerif(
        fontSize: 56,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.02 * 56, // -0.02em
        color: primary,
      ),
      headlineSmall: GoogleFonts.notoSerif(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );

    // Manrope for body and UI
    final manrope = GoogleFonts.manropeTextTheme(baseTheme).copyWith(
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        color: primary,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        color: primary,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4, // 0.1em
        color: primary,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2, // 0.1em
        color: primary,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
    );

    return notoSerif.merge(manrope);
  }
}
