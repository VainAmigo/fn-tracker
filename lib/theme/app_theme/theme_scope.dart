import 'app_palette.dart';
import 'app_theme.dart';
import 'app_theme_mode.dart';

/// Состояние темы приложения: режим (система/светлая/тёмная) и палитра.
class AppThemeState {
  const AppThemeState({
    this.themeMode = AppThemeMode.system,
    this.palette = AppThemes.defaultPalette,
    this.preferDynamicColor = true,
  });

  final AppThemeMode themeMode;
  final AppPalette palette;

  /// На Android 12+ использовать [ColorScheme] из обоев (Material You), если доступен.
  final bool preferDynamicColor;

  AppThemeState copyWith({
    AppThemeMode? themeMode,
    AppPalette? palette,
    bool? preferDynamicColor,
  }) {
    return AppThemeState(
      themeMode: themeMode ?? this.themeMode,
      palette: palette ?? this.palette,
      preferDynamicColor: preferDynamicColor ?? this.preferDynamicColor,
    );
  }
}
