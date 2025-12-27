import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Enhanced with more vibrant colors
  // Accent / Brand
  // Primary brand color (blue)
  static const Color primaryTeal = Color(0xFF1E88E5); // Blue 600
  static const Color primaryIndigo = Color(0xFF3F51B5); // Richer indigo
  static const Color backgroundColor = Color(
    0xFFF5F7FA,
  ); // Subtle light gray with blue tint
  static const Color cardBackground = Color(0xFFFFFFFF); // Clean white
  static const Color textPrimary = Color(
    0xFF1A202C,
  ); // Deeper text for better contrast
  static const Color textSecondary = Color(0xFF718096);

  // Accent Colors for UI elements
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentGreen = Color(0xFF4CAF50);

  // Event Colors - More vibrant and distinguishable
  static const Color examRed = Color(0xFFE53935); // Brighter red
  static const Color assignmentOrange = Color(
    0xFFFF9800,
  ); // More vibrant orange
  static const Color classTeal = Color(0xFF42A5F5); // Blue 400
  static const Color meetingPurple = Color(0xFF9C27B0); // Purple for meetings
  static const Color deadlineYellow = Color(0xFFFFC107); // Yellow for deadlines

  // Shadow - Enhanced for more depth
  static const Color shadowColor = Color(0x26000000); // Slightly darker shadow

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.light,
        background: backgroundColor,
        surface: cardBackground,
        primary: primaryTeal,
        secondary: accentBlue,
        tertiary: accentPurple,
      ),
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: GoogleFonts.poppins().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: cardBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        shadowColor: shadowColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 3,
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 3,
        shadowColor: shadowColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: shadowColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // Blend a subtle overlay over the scaffold background for better theming
        fillColor: Color.alphaBlend(
          Colors.black.withOpacity(0.03),
          backgroundColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryTeal, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: examRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryTeal,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 24),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(
        base.textTheme,
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
    );
  }

  static ThemeData get darkTheme {
    // Dark theme colors
    const darkBackground = Color(0xFF0B1218);
    const darkSurface = Color(0xFF121A24);
    const darkTextPrimary = Color(0xFFFFFFFF);
    const darkTextSecondary = Color(0xFFCCCCCC);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.dark,
        background: darkBackground,
        surface: darkSurface,
        primary: primaryTeal,
        secondary: accentBlue,
        tertiary: accentPurple,
        onBackground: darkTextPrimary,
        onSurface: darkTextPrimary,
      ),
      scaffoldBackgroundColor: darkBackground,
      fontFamily: GoogleFonts.poppins().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 3,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.4),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.black,
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.4),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // Avoid flat grey; blend a soft overlay over dark background
        fillColor: Color.alphaBlend(
          Colors.white.withOpacity(0.05),
          darkBackground,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryTeal, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: examRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: darkTextSecondary.withOpacity(0.7)),
        labelStyle: const TextStyle(
          color: darkTextSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryTeal,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        selectedIconTheme: IconThemeData(size: 26),
        unselectedIconTheme: IconThemeData(size: 24),
      ),
      dividerColor: const Color(0xFF3A3A3A),
      iconTheme: const IconThemeData(color: darkTextPrimary, size: 24),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(
        base.textTheme,
      ).apply(bodyColor: darkTextPrimary, displayColor: darkTextPrimary),
    );
  }
}
