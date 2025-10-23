import 'package:flutter/material.dart';

class AppTheme {
  // Typography
  static const TextStyle baseTextStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
  );
  // Primary
  static const Color primaryLight = Color(0xFF4F46E5); 
  static const Color primaryDark = Color(0xFF818CF8);  

  // Accent
  static const Color accentLight = Color(0xFFFFC107); 
  static const Color accentDark = Color(0xFFFFD54F);  

  // Surface
  static const Color surfaceLight = Color(0xFFFAFAFA); 
  static const Color surfaceDark = Color(0xFF212121);  

  // Text
  static const Color textLight = Colors.black87;
  static const Color textDark = Colors.white70;

  //Light Theme
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Roboto',

    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: accentLight,
      surface: surfaceLight,
      onSurface: textLight,
    ),

    scaffoldBackgroundColor: surfaceLight,

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
    ),

    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: baseTextStyle,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),

      filled: true,
      fillColor: surfaceLight,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: baseTextStyle.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentLight,
      foregroundColor: Colors.black,
    ),

  );

  // Dark
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',

    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: accentDark,
      surface: surfaceDark,
      onSurface: textDark,
    ),

    scaffoldBackgroundColor: surfaceDark,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
    ),

    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: baseTextStyle,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: baseTextStyle.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentDark,
      foregroundColor: Colors.black,
    ),
  );

  // Animations
  static const Duration heroToDetail = Duration(milliseconds: 300);
  static const Curve heroCurve = Curves.easeInOut;

  static const Duration addLog = Duration(milliseconds: 200);
  static const Curve addLogCurve = Curves.easeOut;

  static const Duration scrollDown = Duration(milliseconds: 120);
  static const Curve scrollDownCurve = Curves.easeOutBack;

  static const Duration completeReminder = Duration(milliseconds: 150);
  static const Curve completeCurve = Curves.easeOut;
}