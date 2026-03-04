import 'app_palette.dart';
import 'app_theme_mode.dart';

/// Состояние темы приложения: режим (система/светлая/тёмная) и палитра.
class AppThemeState {
  const AppThemeState({
    this.themeMode = AppThemeMode.system,
    this.palette = AppPalette.mintGreen,
  });

  final AppThemeMode themeMode;
  final AppPalette palette;

  AppThemeState copyWith({
    AppThemeMode? themeMode,
    AppPalette? palette,
  }) {
    return AppThemeState(
      themeMode: themeMode ?? this.themeMode,
      palette: palette ?? this.palette,
    );
  }
}
