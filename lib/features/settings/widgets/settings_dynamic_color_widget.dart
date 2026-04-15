import 'package:flutter/material.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:provider/provider.dart';

/// Переключатель использования динамических цветов Android 12+ (Material You).
class SettingsDynamicColorWidget extends StatelessWidget {
  const SettingsDynamicColorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(context.l10n.dynamicColorsOfTheDevice),
      subtitle: Text(
        context.l10n.dynamicColorsOfTheDeviceDescription,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      value: themeProvider.state.preferDynamicColor,
      onChanged: (value) {
        themeProvider.setState((s) => s.copyWith(preferDynamicColor: value));
      },
    );
  }
}
