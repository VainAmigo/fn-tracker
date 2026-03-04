/// Палитра цветов приложения.
enum AppPalette {
  mintGreen,
  sunsetBerry,
  nordicFrost,
  terracottaEarth,
}

extension AppPaletteX on AppPalette {
  String get label {
    switch (this) {
      case AppPalette.mintGreen:
        return 'Мятная зелень';
      case AppPalette.sunsetBerry:
        return 'Закатная ягода';
      case AppPalette.nordicFrost:
        return 'Северный иней';
      case AppPalette.terracottaEarth:
        return 'Терракотовая земля';
    }
  }
}
