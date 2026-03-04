import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Провайдер для управления темой приложения.
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _paletteKey = 'theme_palette';

  AppThemeState _state = const AppThemeState();

  ThemeProvider() {
    _loadTheme();
  }

  AppThemeState get state => _state;

  ThemeMode get themeMode {
    switch (_state.themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Загрузить тему из SharedPreferences.
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_themeModeKey);
      final paletteStr = prefs.getString(_paletteKey);

      AppThemeMode? mode;
      if (modeStr != null) {
        for (final m in AppThemeMode.values) {
          if (m.toString() == modeStr) {
            mode = m;
            break;
          }
        }
      }

      AppPalette? palette;
      if (paletteStr != null) {
        for (final p in AppPalette.values) {
          if (p.toString() == paletteStr) {
            palette = p;
            break;
          }
        }
      }

      if (mode != null || palette != null) {
        _state = _state.copyWith(
          themeMode: mode ?? _state.themeMode,
          palette: palette ?? _state.palette,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Обновить состояние темы.
  Future<void> setState(AppThemeState Function(AppThemeState) update) async {
    final newState = update(_state);
    if (_state.themeMode == newState.themeMode &&
        _state.palette == newState.palette) {
      return;
    }

    _state = newState;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _state.themeMode.toString());
      await prefs.setString(_paletteKey, _state.palette.toString());
    } catch (_) {}
  }
}
