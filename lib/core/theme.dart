import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xFF0B1D2A),

    // ================= TEXT =================
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ),

    // ================= COLORS =================
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00E5FF),
      secondary: Color(0xFF00C853),
      surface: Color(0xFF122B3A),
    ),

    // ================= CARD =================
    cardTheme: CardThemeData(
  color: Colors.white.withValues(alpha: 0.05),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
),

    // ================= BUTTON =================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00E5FF),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    // ================= INPUT =================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),

      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

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
          color: Color(0xFF00E5FF),
          width: 1.2,
        ),
      ),

      hintStyle: const TextStyle(color: Colors.white54),
    ),

    // ================= APP BAR =================
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F2027),
      elevation: 0,
      centerTitle: true,
    ),

    // ================= ICON =================
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),

    // ================= DIVIDER =================
    dividerColor: Colors.white12,
  );
}