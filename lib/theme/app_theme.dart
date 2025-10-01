import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF10B981);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color textLight = Color(0xFF374151);
  static const Color textDark = Color(0xFFF3F4F6);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return base
        .copyWith(
          displayLarge: GoogleFonts.inter(
              fontSize: 57, fontWeight: FontWeight.bold, color: textColor),
          displayMedium: GoogleFonts.inter(
              fontSize: 45, fontWeight: FontWeight.bold, color: textColor),
          displaySmall: GoogleFonts.inter(
              fontSize: 36, fontWeight: FontWeight.bold, color: textColor),
          headlineLarge: GoogleFonts.inter(
              fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
          headlineMedium: GoogleFonts.inter(
              fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
          headlineSmall: GoogleFonts.inter(
              fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
          titleLarge: GoogleFonts.inter(
              fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
          titleMedium: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
          titleSmall: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
          bodyLarge: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.normal, color: textColor),
          bodyMedium: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.normal, color: textColor),
          bodySmall: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.normal, color: textColor),
          labelLarge: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
          labelMedium: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
          labelSmall: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
        )
        .apply(
          bodyColor: textColor,
          displayColor: textColor,
        );
  }

  static final ThemeData lightTheme = ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textLight,
        error: error,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: textLight),
        titleTextStyle:
            _buildTextTheme(ThemeData.light().textTheme, textLight).titleLarge,
      ),
      textTheme: _buildTextTheme(ThemeData.light().textTheme, textLight),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: const Color.fromARGB(13, 0, 0, 0), // Replaced withOpacity
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));

  static final ThemeData darkTheme = ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: Color(0xFF1F2937),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
        error: error,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle:
            _buildTextTheme(ThemeData.dark().textTheme, textDark).titleLarge,
      ),
      textTheme: _buildTextTheme(ThemeData.dark().textTheme, textDark),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1F2937),
        shadowColor: const Color.fromARGB(51, 0, 0, 0), // Replaced withOpacity
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF374151),
        contentTextStyle: const TextStyle(color: textDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
}
