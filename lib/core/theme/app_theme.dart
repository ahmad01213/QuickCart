import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _tajawalTextTheme(TextTheme base) {
    return GoogleFonts.tajawalTextTheme(base).copyWith(
      displayLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
      displaySmall: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w500),
      bodySmall: GoogleFonts.tajawal(fontWeight: FontWeight.w500),
      labelLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.tajawal(fontWeight: FontWeight.w500),
    );
  }

  static const Color _primary = Color(0xFFFE5823);
  static const Color _primaryLight = Color(0xFFFF8A5C);
  static const Color _surface = Color(0xFFF8FAFC);
  static const Color _error = Color(0xFFDC2626);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: _primary,
        primaryContainer: _primaryLight,
        surface: _surface,
        error: _error,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF0F172A),
        onError: Colors.white,
      ),
      textTheme: _tajawalTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.tajawal(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }
}
