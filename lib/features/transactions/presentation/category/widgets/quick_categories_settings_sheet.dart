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
          BlocBuilder<QuickCategoriesSettingsCubit,
              QuickCategoriesSettingsState>(
            builder: (context, settingsState) {
              final currentMode = settingsState.displayMode;
              final modes = QuickCategoriesDisplayMode.values;
              return Column(
                children: [
                  ...List.generate(modes.length, (index) {
                    final mode = modes[index];
                    final isSelected = mode == currentMode;
                    final radius = radiusForIndex(index, modes.length);
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSizing.spaceBtwItemsExtra,
                      ),
                      child: CategoryCard(
                        title: mode.label,
                        subtitle: mode.description,
                        leading: Icon(
                          mode == QuickCategoriesDisplayMode.recent
                              ? Icons.history_rounded
                              : Icons.push_pin_rounded,
                          size: AppSizing.iconSizeM,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: AppSizing.iconSizeM,
                              )
                            : null,
                        onTap: () {
                          context
                              .read<QuickCategoriesSettingsCubit>()
                              .setDisplayMode(mode);
                        },
                        radius: radius,
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  PrimaryButton(
                    text: 'Manage pinned categories',
                    icon: Icons.push_pin_outlined,
                    rounded: true,
                    backgroundColor: Colors.transparent,
                    foregroundColor: colorScheme.primary,
                    onPressed:
                        settingsState.displayMode ==
                            QuickCategoriesDisplayMode.pinned
                        ? () {
                            Navigator.of(context).pop();
                            QuickCategoriesPinSheet.show(context);
                          }
                        : null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
