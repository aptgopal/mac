import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF003580);
  static const Color secondaryColor = Color(0xFFFFC107);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color greyLight = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF00C853);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: white,
      error: error,
    ),
    fontFamily: 'Poppins',
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 32),
      displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 28),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: GoogleFonts.poppins(fontSize: 16),
      bodyMedium: GoogleFonts.poppins(fontSize: 14),
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: white,
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),
          cardTheme: CardThemeData(
      elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: greyLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.poppins(color: grey),
      labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      backgroundColor: white,
      selectedItemColor: primaryColor,
      unselectedItemColor: grey,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins'),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, fontFamily: 'Poppins'),
    ),
    scaffoldBackgroundColor: greyLight,
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade200,
      labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
  );
}
