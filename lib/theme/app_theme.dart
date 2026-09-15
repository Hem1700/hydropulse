import 'package:flutter/material.dart';

class AppTheme {
  // Nordic Slate Palette (Matte Dark Mode)
  static const Color nordicBg = Color(0xFF1A1C22);
  static const Color nordicCard = Color(0xFF242831);
  static const Color nordicCardSubtle = Color(0xFF2B303C);
  static const Color nordicTextPrimary = Color(0xFFF1F3F5);
  static const Color nordicTextSecondary = Color(0xFF8E9AA8);
  static const Color nordicWater = Color(0xFF7093B3); // Powdery Fjord Blue
  static const Color nordicFocusArc = Color(0xFFE9ECEF); // Bone White
  static const Color nordicBreak = Color(0xFF7A9A85); // Muted Sage

  // Compat aliases — old color names still referenced in screens/widgets
  static const Color primaryAqua = nordicWater;
  static const Color darkTextSecondary = nordicTextSecondary;
  static const Color lightTextSecondary = ceramicTextSecondary;
  static const Color darkCard = nordicCard;
  static const Color lightCard = ceramicCard;
  // Accent compat colors (formerly neon — now muted equivalents)
  static const Color softAmber = ceramicTerracotta;       // warm amber → terracotta
  static const Color focusPurple = nordicWater;           // focus arc → fjord blue
  static const Color breakGreen = nordicBreak;            // break → sage

  // Warm Ceramic Zen Palette (Organic Light Mode)
  static const Color ceramicBg = Color(0xFFF8F6F0); // Oatmeal Linen
  static const Color ceramicCard = Color(0xFFEAE5DB); // Soft Clay
  static const Color ceramicCardSubtle = Color(0xFFDFD9CD);
  static const Color ceramicTextPrimary = Color(0xFF262B28); // Earthy Slate
  static const Color ceramicTextSecondary = Color(0xFF5C665F);
  static const Color ceramicWater = Color(0xFF7A9A85); // Japanese Sage Green
  static const Color ceramicFocusArc = Color(0xFF3A423D); // Charcoal
  static const Color ceramicTerracotta = Color(0xFFC48B71); // Terracotta Accent

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: nordicBg,
    primaryColor: nordicWater,
    colorScheme: const ColorScheme.dark(
      primary: nordicWater,
      secondary: nordicBreak,
      surface: nordicCard,
      error: Color(0xFFE06C75),
    ),
    cardColor: nordicCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: nordicTextPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: nordicTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: nordicCard,
      selectedItemColor: nordicWater,
      unselectedItemColor: nordicTextSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: nordicWater,
      inactiveTrackColor: nordicCardSubtle,
      thumbColor: nordicWater,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: ceramicBg,
    primaryColor: ceramicWater,
    colorScheme: const ColorScheme.light(
      primary: ceramicWater,
      secondary: ceramicTerracotta,
      surface: ceramicCard,
      error: Color(0xFFE06C75),
    ),
    cardColor: ceramicCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: ceramicTextPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: ceramicTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ceramicCard,
      selectedItemColor: ceramicWater,
      unselectedItemColor: ceramicTextSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: ceramicWater,
      inactiveTrackColor: ceramicCardSubtle,
      thumbColor: ceramicWater,
    ),
  );
}
