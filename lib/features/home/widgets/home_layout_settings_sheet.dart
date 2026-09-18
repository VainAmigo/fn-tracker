import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Настройка порядка и видимости блоков главного экрана.
/// Оформление как [QuickCategoriesSettingsSheet], [FinanceTabOrderSettingsSheet], [HomeWalletsSettingsSheet].
class HomeLayoutSettingsSheet extends StatelessWidget {
  const HomeLayoutSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: false,
      child: const HomeLayoutSettingsSheet(),
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
            title: context.l10n.homeLayoutSettingsTitle,
            subtitle: context.l10n.homeLayoutSettingsSubtitle,
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          BlocBuilder<HomeLayoutSettingsCubit, HomeLayoutSettingsState>(
            builder: (context, layoutState) {
              final order = layoutState.sectionOrder;
              return TitledSection(
                title: context.l10n.homeLayoutOrderSectionTitle,
                children: [
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: order.length,
                    onReorder: (oldI, newI) {
                      context
                          .read<HomeLayoutSettingsCubit>()
                          .reorderSections(oldI, newI);
                    },
                    itemBuilder: (context, index) {
                      final sectionIndex = order[index];
                      final section = HomeSection.values[sectionIndex];
                      final visible =
                          layoutState.isSectionVisible(section);
                      final radius = radiusForIndex(index, order.length);

                      return Padding(
                        key: ValueKey<int>(sectionIndex),
                        padding: const EdgeInsets.only(
                          bottom: AppSizing.spaceBtwItemsExtra,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppSizing.borderRadius12,
                            ),
                          ),
                          child: CategoryCard(
                            title: section.label(context),
                            subtitle: context.l10n.homeLayoutShowOnHome,
                            leading: Container(
                              padding: const EdgeInsets.all(
                                AppSizing.spaceBtwItems,
                              ),
                              decoration: BoxDecoration(
                                color: visible
                                    ? colorScheme.primary
                                        .withValues(alpha: 0.12)
                                    : colorScheme.secondary
                                        .withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(
                                  AppSizing.borderRadius8,
                                ),
                              ),
                              child: Icon(
                                _sectionIcon(section),
                                size: AppSizing.iconSizeM,
                                color: visible
                                    ? colorScheme.primary
                                    : colorScheme.onSecondary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  visible
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: visible
                                      ? colorScheme.primary
                                      : colorScheme.onSecondary,
                                  size: AppSizing.iconSizeM,
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: colorScheme.onSecondary,
                                      size: AppSizing.iconSizeL,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              context
                                  .read<HomeLayoutSettingsCubit>()
                                  .setSectionVisible(section, !visible);
                            },
                            radius: radius,
                          ),
                        ),
                      );
                    },
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

IconData _sectionIcon(HomeSection section) {
  return switch (section) {
    HomeSection.wallets => Icons.account_balance_wallet_outlined,
    HomeSection.quickCategories => Icons.bolt_rounded,
    HomeSection.lastTransactions => Icons.receipt_long_rounded,
  };
}
