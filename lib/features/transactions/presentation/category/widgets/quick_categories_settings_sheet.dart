import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class QuickCategoriesSettingsSheet extends StatelessWidget {
  const QuickCategoriesSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: false,
      child: const QuickCategoriesSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizing.defaultPadding,
        bottom: AppSizing.bottomPadding,
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          ModalSheetTitleWidget(
            title: 'Quick Categories',
            subtitle: 'Choose how categories are displayed on the home screen',
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          BlocBuilder<
            QuickCategoriesSettingsCubit,
            QuickCategoriesSettingsState
          >(
            builder: (context, settingsState) {
              final currentMode = settingsState.displayMode;
              final modes = QuickCategoriesDisplayMode.values;
              final widgetSources = WidgetCategoriesSource.values;
              return Column(
                children: [
                  ...List.generate(modes.length, (index) {
                    final mode = modes[index];
                    return _buildSelectableSettingsCard(
                      context: context,
                      title: mode.label,
                      subtitle: mode.description,
                      icon: mode == QuickCategoriesDisplayMode.recent
                          ? Icons.history_rounded
                          : Icons.push_pin_rounded,
                      isSelected: mode == currentMode,
                      radius: radiusForIndex(index, modes.length),
                      onTap: () {
                        context
                            .read<QuickCategoriesSettingsCubit>()
                            .setDisplayMode(mode);
                      },
                      onSettingsTap: () {
                        Navigator.of(context).pop();
                        QuickCategoriesPinSheet.show(context);
                      },
                      showSettings: mode == QuickCategoriesDisplayMode.pinned,
                    );
                  }),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  TitledSection(
                    title: 'Home screen widget source',
                    children: [
                      ...List.generate(widgetSources.length, (index) {
                        final source = widgetSources[index];
                        return _buildSelectableSettingsCard(
                          context: context,
                          title: source.label,
                          subtitle: source.description,
                          icon: source == WidgetCategoriesSource.system
                              ? Icons.auto_awesome_rounded
                              : Icons.tune_rounded,
                          isSelected: source == settingsState.widgetSource,
                          radius: radiusForIndex(index, widgetSources.length),
                          onTap: () {
                            context
                                .read<QuickCategoriesSettingsCubit>()
                                .setWidgetSource(source);
                          },
                          onSettingsTap: () {
                            Navigator.of(context).pop();
                            QuickWidgetCategoriesSheet.show(context);
                          },
                          showSettings: source == WidgetCategoriesSource.custom,
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableSettingsCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required CardRadius radius,
    required VoidCallback onTap,
    required VoidCallback onSettingsTap,
    bool showSettings = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizing.spaceBtwItemsExtra),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: AppSizing.spaceBtwItemsExtra,
        children: [
          Expanded(
            child: CategoryCard(
              title: title,
              subtitle: subtitle,
              leading: Icon(
                icon,
                size: AppSizing.iconSizeM,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSecondary,
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.primary,
                      size: AppSizing.iconSizeM,
                    )
                  : null,
              onTap: onTap,
              radius: showSettings ? CardRadius.withSettingsLast : radius,
            ),
          ),
          if (showSettings) ...[
            Container(
              width: AppSizing.heightM,
              height: AppSizing.heightM,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppSizing.borderRadius4),
                  topLeft: Radius.circular(AppSizing.borderRadius4),
                  bottomRight: Radius.circular(AppSizing.borderRadius12),
                  bottomLeft: Radius.circular(AppSizing.borderRadius4),
                ),
              ),
              child: InkWell(
                onTap: isSelected ? onSettingsTap : null,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppSizing.borderRadius4),
                  topLeft: Radius.circular(AppSizing.borderRadius4),
                  bottomRight: Radius.circular(AppSizing.borderRadius12),
                  bottomLeft: Radius.circular(AppSizing.borderRadius4),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSecondary,
                  size: AppSizing.iconSizeM,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
