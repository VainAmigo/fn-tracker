import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppThemes {
  /// Возвращает светлую или тёмную тему для выбранной палитры.
  static ThemeData themeFor(AppPalette palette, Brightness brightness) {
    switch (palette) {
      case AppPalette.mintGreen:
        return brightness == Brightness.light ? mintGreenLight : mintGreenDark;
      case AppPalette.nordicFrost:
        return brightness == Brightness.light
            ? nordicFrostLight
            : nordicFrostDark;
      case AppPalette.terracottaEarth:
        return brightness == Brightness.light
            ? terracottaEarthLight
            : terracottaEarthDark;
    }
  }

  static ThemeData mintGreenLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
    scaffoldBackgroundColor: Color.fromARGB(255, 212, 238, 223),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF13EC5B),
      contentTextStyle: TextStyle(color: Color(0xFF111813)),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF13EC5B),
      onPrimary: Color(0xFF111813),
      surface: Color.fromARGB(255, 212, 238, 223),
      onSurface: Color(0xFF111813),
      secondary: Color.fromARGB(255, 206, 229, 214),
      onSecondary: Color(0xFF5B866A),
      tertiary: Color(0xFF13EC5B),

      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFEAEA),
      onErrorContainer: Color(0xFF410002),
    ),
  );

  static ThemeData mintGreenDark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF102216),
    appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF13EC5B),
      contentTextStyle: TextStyle(color: Color(0xFF102216)),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF13EC5B),
      onPrimary: Color(0xFF102216),
      surface: Color(0xFF102216),
      onSurface: Color(0xFFFFFFFF),
      secondary: Color(0xFF1C2D22),
      onSecondary: Color.fromARGB(255, 86, 107, 94),
      tertiary: Color(0xFF13EC5B),

      error: Color(0xFFCF6679),
      onError: Color(0xFF1E0000),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFFFDAD6),
    ),
  );

  static ThemeData nordicFrostLight = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF0F4F8),
    appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF69C2F5),
      contentTextStyle: TextStyle(color: Color(0xFFFFFFFF)),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF69C2F5),
      onPrimary: Color(0xFFFFFFFF),
      surface: Color(0xFFF0F4F8),
      onSurface: Color(0xFF2D3748),
      secondary: Color(0xFFD8E4F0),
      onSecondary: Color(0xFF939DAD),
      tertiary: Color(0xFF3BC9DB),

      error: Color(0xFFE53935),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFF410002),
    ),
  );

  static ThemeData nordicFrostDark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1A202C),
    appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF53C5E9),
      contentTextStyle: TextStyle(color: Color(0xFF181521)),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF53C5E9),
      onPrimary: Color(0xFF181521),
      surface: Color(0xFF1A202C),
      onSurface: Color(0xFFFFFFFF),
      secondary: Color(0xFF242C3A),
      onSecondary: Color(0xFF565D67),
      tertiary: Color(0xFF3BC9DB),

      error: Color(0xFFCF6679),
      onError: Color(0xFF1E0000),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFFFDAD6),
    ),
  );

  static ThemeData terracottaEarthLight = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color.fromARGB(255, 215, 204, 182),
    appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFFDE775C),
      contentTextStyle: TextStyle(color: Color(0xFFFFFFFF)),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFFDE775C),
      onPrimary: Color(0xFFFFFFFF),
      surface: Color.fromARGB(255, 215, 204, 182),
      onSurface: Color(0xFF4A3728),
      secondary: Color.fromARGB(255, 225, 213, 194),
      onSecondary: Color(0xFFA1988D),
      tertiary: Color(0xFFDF7457),

      error: Color(0xFFD84315),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFEDE7),
      onErrorContainer: Color(0xFF410002),
    ),
  );

  static ThemeData terracottaEarthDark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF2D241E),
    appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFFCD6F4E),
      contentTextStyle: TextStyle(color: Color(0xFFF5EFE6)),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFCD6F4E),
      onPrimary: Color(0xFFF5EFE6),
      surface: Color(0xFF2D241E),
      onSurface: Color(0xFFF5EFE6),
      secondary: Color(0xFF372F29),
      onSecondary: Color(0xFF6A6257),
      tertiary: Color(0xFF8A9A5B),

      error: Color.fromARGB(255, 248, 97, 80),
      onError: Color(0xFF3B0000),
      errorContainer: Color(0xFF8C2F1B),
      onErrorContainer: Color(0xFFFFDAD4),
    ),
  );
}
