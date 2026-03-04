import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppThemes {
  /// Возвращает светлую или тёмную тему для выбранной палитры.
  static ThemeData themeFor(AppPalette palette, Brightness brightness) {
    switch (palette) {
      case AppPalette.mintGreen:
        return brightness == Brightness.light ? mintGreenLight : mintGreenDark;
      case AppPalette.sunsetBerry:
        return brightness == Brightness.light ? sunsetBerryLight : sunsetBerryDark;
      case AppPalette.nordicFrost:
        return brightness == Brightness.light ? nordicFrostLight : nordicFrostDark;
      case AppPalette.terracottaEarth:
        return brightness == Brightness.light ? terracottaEarthLight : terracottaEarthDark;
    }
  }

  static ThemeData mintGreenLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Color(0xFFFFFFFF),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF13EC5B),
      onPrimary: Color(0xFF111813),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF111813),
      secondary: Color(0xFFDBE6DF),
      onSecondary: Color(0xFF5B866A),
      tertiary: Color(0xFF13EC5B),
    ),
  );

  static ThemeData mintGreenDark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF102216),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF13EC5B),
      onPrimary: Color(0xFF102216),
      surface: Color(0xFF102216),
      onSurface: Color(0xFFFFFFFF),
      secondary: Color(0xFF1C2D22),
      onSecondary: Color(0xFF98A7BD),
      tertiary: Color(0xFF13EC5B),
    ),
  );

  static ThemeData sunsetBerryLight = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFFFFFFF),
    colorScheme: ColorScheme.light(
      primary: Color(0xFFFF7549),
      onPrimary: Color(0xFFFFFCFB),
      surface: Color(0xFFFFF9F5),
      onSurface: Color(0xFF4A1D3D),
      secondary: Color(0xFFF6EDEB),
      onSecondary: Color(0xFFBCAAB2),
      tertiary: Color(0xFFD7005A),
    ),
  );

    static ThemeData sunsetBerryDark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1C0D18),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFFF845D),
      onPrimary: Color(0xFFFFFFFF),
      surface: Color(0xFF1C0D18),
      onSurface: Color(0xFFE8E2DD), 
      secondary: Color(0xFF2C1E28),
      onSecondary: Color(0xFF675D61),
      tertiary: Color(0xFFFF2E80),
    ),
  );

  static ThemeData nordicFrostLight = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF0F4F8),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF69C2F5 ),
      onPrimary: Color(0xFFFFFFFF),
      surface: Color(0xFFF0F4F8),
      onSurface: Color(0xFF2D3748),
      secondary: Color(0xFFE5EFF9), 
      onSecondary: Color(0xFFB1BAC7),
      tertiary: Color(0xFF3BC9DB),
    ),
  );
  
  static ThemeData nordicFrostDark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1A202C),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF53C5E9),
      onPrimary: Color(0xFF181521),
      surface: Color(0xFF1A202C),
      onSurface: Color(0xFFFFFFFF),
      secondary: Color(0xFF242C3A), 
      onSecondary: Color(0xFF565D67),
      tertiary: Color(0xFF3BC9DB),
    ),
  );

  static ThemeData terracottaEarthLight = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF7F2E9),
    colorScheme: ColorScheme.light(
      primary: Color(0xFFDE775C),
      onPrimary: Color(0xFFFFFFFF),
      surface: Color(0xFFF7F2E9),
      onSurface: Color(0xFF4A3728),
      secondary: Color(0xFFEEE8DF), 
      onSecondary: Color(0xFFB8AFA4),
      tertiary: Color(0xFFDF7457),
    ),
  );

  static ThemeData terracottaEarthDark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF2D241E),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFCD6F4E),
      onPrimary: Color(0xFFF5EFE6),
      surface: Color(0xFF2D241E),
      onSurface: Color(0xFFF5EFE6),
      secondary: Color(0xFF372F29), 
      onSecondary: Color(0xFF6A6257),
      tertiary: Color(0xFF8A9A5B),
    ),
  );
}
