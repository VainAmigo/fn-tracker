import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Виджет выбора режима темы для раздела настроек.
class SettingsThemeModeWidget extends StatelessWidget {
  const SettingsThemeModeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = context.l10n;
    final segments = [
      SegmentItem<AppThemeMode>(
        value: AppThemeMode.system,
        label: l10n.system,
        icon: Icons.palette_outlined,
      ),
      SegmentItem<AppThemeMode>(
        value: AppThemeMode.dark,
        label: l10n.dark,
        icon: Icons.dark_mode_outlined,
      ),
      SegmentItem<AppThemeMode>(
        value: AppThemeMode.light,
        label: l10n.light,
        icon: Icons.light_mode_outlined,
      ),
    ];

    return SegmentedControl<AppThemeMode>(
      segments: segments,
      selectedValue: themeProvider.state.themeMode,
      onChanged: (mode) {
        themeProvider.setState((s) => s.copyWith(themeMode: mode));
      },
    );
  }
}
