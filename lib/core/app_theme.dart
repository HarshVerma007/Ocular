import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ATLAS Theme — Dark hacker aesthetic: black + neon green.
class AppTheme {
  AppTheme._();

  // ─── Core ────────────────────────────────────────────────────────
  static const Color green = Color(0xFF00FF41);          // Matrix green
  static const Color greenDim = Color(0xFF00CC33);
  static const Color greenMuted = Color(0xFF00AA2A);
  static const Color greenGlow = Color(0x3300FF41);
  static const Color greenSubtle = Color(0x1A00FF41);
  static const Color alert = Color(0xFFFF3333);          // Neon alert red
  static const Color alertSubtle = Color(0x33FF3333);


  // ─── Backgrounds ─────────────────────────────────────────────────
  static const Color black = Color(0xFF000000);
  static const Color bg = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceLight = Color(0xFF1C1C1C);
  static const Color card = Color(0xFF1A1A1A);

  // ─── Text ────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textDim = Color(0xFF555555);

  // ─── Borders ─────────────────────────────────────────────────────
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderGreen = Color(0x4D00FF41);

  // ─── Text Styles (monospace for hacker feel) ─────────────────────
  static TextStyle get displayLarge => GoogleFonts.jetBrainsMono(
    fontSize: 32, fontWeight: FontWeight.w800, color: green,
    letterSpacing: 2.0, height: 1.2,
  );

  static TextStyle get titleLarge => GoogleFonts.jetBrainsMono(
    fontSize: 16, fontWeight: FontWeight.w600, color: green,
    letterSpacing: 0.5,
  );

  static TextStyle get titleMedium => GoogleFonts.jetBrainsMono(
    fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.jetBrainsMono(
    fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary,
  );

  static TextStyle get bodyMedium => GoogleFonts.jetBrainsMono(
    fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.jetBrainsMono(
    fontSize: 11, fontWeight: FontWeight.w400, color: textDim,
  );

  static TextStyle get labelMedium => GoogleFonts.jetBrainsMono(
    fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.jetBrainsMono(
    fontSize: 10, fontWeight: FontWeight.w500, color: textDim,
  );

  // ─── Theme Data ──────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: green,
        secondary: greenDim,
        surface: surface,
        onPrimary: black,
        onSecondary: black,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: titleLarge,
        iconTheme: const IconThemeData(color: green),
      ),
    );
  }
}
