/// Палитра цветов приложения.
enum AppPalette {
  mintGreen,
  nordicFrost,
  terracottaEarth,
}

extension AppPaletteX on AppPalette {
  String get label {
    switch (this) {
      case AppPalette.mintGreen:
        return 'Мятная зелень';
      case AppPalette.nordicFrost:
        return 'Северный иней';
      case AppPalette.terracottaEarth:
        return 'Терракотовая земля';
    }
  }
}
