import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF003580);
  static const primaryLight = Color(0xFF0071C2);
  static const accent = Color(0xFFFEBB02);
  static const background = Color(0xFFF4F6F9);
  static const surface = Colors.white;
  static const text = Color(0xFF1A1A1A);
  static const muted = Color(0xFF687786);
  static const border = Color(0xFFE1E7EC);
  static const success = Color(0xFF008009);
  static const successBg = Color(0xFFE6F4E6);
  static const warning = Color(0xFFB76E00);
  static const warningBg = Color(0xFFFDF0DB);
  static const danger = Color(0xFFC0392B);
  static const dangerBg = Color(0xFFFCE9E7);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.primaryLight,
    surface: AppColors.surface,
    error: AppColors.danger,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      labelStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.text,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.muted,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(fontWeight: FontWeight.w700),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.primary,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineLarge:
          GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium:
          GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(fontSize: 16),
      bodyMedium: GoogleFonts.inter(fontSize: 14),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );
}
