import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primaryAqua = Color(0xFF00E5FF);
  static const Color deepWater = Color(0xFF0077B6);
  static const Color focusPurple = Color(0xFF8A4FFF);
  static const Color breakGreen = Color(0xFF00E676);
  static const Color softAmber = Color(0xFFFFB703);

  // Dark palette
  static const Color darkBg = Color(0xFF090D16);
  static const Color darkCard = Color(0xFF131B2C);
  static const Color darkCardHover = Color(0xFF1B273E);
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFF8B9BB4);

  // Light palette
  static const Color lightBg = Color(0xFFF4F7FB);
  static const Color lightCard = Colors.white;
  static const Color lightCardHover = Color(0xFFE8EEF5);
  static const Color lightTextPrimary = Color(0xFF0D1B2A);
  static const Color lightTextSecondary = Color(0xFF5B6B82);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: primaryAqua,
    colorScheme: const ColorScheme.dark(
      primary: primaryAqua,
      secondary: focusPurple,
      surface: darkCard,
      error: Color(0xFFFF5252),
    ),
    cardColor: darkCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: darkTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCard,
      selectedItemColor: primaryAqua,
      unselectedItemColor: darkTextSecondary,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryAqua,
      inactiveTrackColor: darkCardHover,
      thumbColor: primaryAqua,
      overlayColor: primaryAqua.withValues(alpha: 0.2),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: primaryAqua,
    colorScheme: const ColorScheme.light(
      primary: primaryAqua,
      secondary: focusPurple,
      surface: lightCard,
      error: Color(0xFFFF5252),
    ),
    cardColor: lightCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: lightTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightCard,
      selectedItemColor: primaryAqua,
      unselectedItemColor: lightTextSecondary,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryAqua,
      inactiveTrackColor: lightCardHover,
      thumbColor: primaryAqua,
      overlayColor: primaryAqua.withValues(alpha: 0.2),
    ),
  );
}
