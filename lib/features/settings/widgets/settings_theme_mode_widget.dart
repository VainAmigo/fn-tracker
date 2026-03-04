import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Виджет выбора режима темы для раздела настроек.
class SettingsThemeModeWidget extends StatelessWidget {
  const SettingsThemeModeWidget({super.key});

  static const _segments = [
    SegmentItem<AppThemeMode>(
      value: AppThemeMode.system,
      label: 'System',
      icon: Icons.palette_outlined,
    ),
    SegmentItem<AppThemeMode>(
      value: AppThemeMode.dark,
      label: 'Dark',
      icon: Icons.dark_mode_outlined,
    ),
    SegmentItem<AppThemeMode>(
      value: AppThemeMode.light,
      label: 'Light',
      icon: Icons.light_mode_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return SegmentedControl<AppThemeMode>(
      segments: _segments,
      selectedValue: themeProvider.state.themeMode,
      onChanged: (mode) {
        themeProvider.setState((s) => s.copyWith(themeMode: mode));
      },
    );
  }
}
