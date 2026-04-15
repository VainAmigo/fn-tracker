import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:flutter/material.dart';

/// Содержимое модального окна настроек темы.
class SettingsThemeWidget extends StatelessWidget {
  const SettingsThemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: AppSizing.bottomPadding,
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(
            title: context.l10n.appTheme,
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          TitledSection(
            title: context.l10n.themeMode,
            children: [
              SettingsThemeModeWidget(),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          TitledSection(
            title: context.l10n.theme,
            children: [
              const SettingsDynamicColorWidget(),
              const SizedBox(height: AppSizing.spaceBtwElements),
              SettingsAppThemeModeWidget(),
            ],
          ),
        ],
      ),
    );
  }
}
