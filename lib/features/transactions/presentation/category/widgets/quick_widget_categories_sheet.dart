import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class QuickWidgetCategoriesSheet extends StatefulWidget {
  const QuickWidgetCategoriesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: false,
      child: const QuickWidgetCategoriesSheet(),
    );
  }

  @override
  State<QuickWidgetCategoriesSheet> createState() =>
      _QuickWidgetCategoriesSheetState();
}

class _QuickWidgetCategoriesSheetState
    extends State<QuickWidgetCategoriesSheet> {
  final Set<String> _selectedIds = {};
  List<String> _selectedOrder = [];
  bool _initialized = false;
  bool _isSaving = false;

  void _init(List<CategoryModel> categories, List<String> storedOrder) {
    if (_initialized) return;
    _initialized = true;
    final ids = categories.map((c) => c.categoryId).toSet();
    _selectedOrder = List.from(storedOrder.where(ids.contains));
    _selectedIds.addAll(_selectedOrder);
  }

  void _reorderSelected(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final id = _selectedOrder.removeAt(oldIndex);
      _selectedOrder.insert(newIndex, id);
    });
  }

  Future<void> _onSave(BuildContext context) async {
    setState(() => _isSaving = true);
    await context.read<QuickCategoriesSettingsCubit>().setCustomWidgetOrder(
      _selectedOrder,
    );
    if (!context.mounted) return;
    Navigator.of(context).pop();
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
            title: context.l10n.widgetCategories,
            subtitle: context.l10n.selectCustomCategoriesForTheHomeScreenWidget,
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Flexible(
            child:
                BlocBuilder<
                  QuickCategoriesSettingsCubit,
                  QuickCategoriesSettingsState
                >(
                  builder: (context, settingsState) {
                    return BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, categoriesState) {
                        final categories = switch (categoriesState) {
                          CategoriesLoaded s => s.categories,
                          _ => <CategoryModel>[],
                        };
                        _init(categories, settingsState.customWidgetOrder);
                        final categoryMap = {
                          for (final c in categories) c.categoryId: c,
                        };
                        final selectedCategories = _selectedOrder
                            .where(categoryMap.containsKey)
                            .map((id) => categoryMap[id]!)
                            .toList();
                        final unselectedCategories = categories
                            .where((c) => !_selectedIds.contains(c.categoryId))
                            .toList();

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (selectedCategories.isNotEmpty) ...[
                                Text(
                                  context.l10n.pinned,
                                  style: AppTextStyles.sectionTitle(context),
                                ),
                                const SizedBox(height: AppSizing.spaceBtwItems),
                                ReorderableListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  buildDefaultDragHandles: false,
                                  itemCount: selectedCategories.length,
                                  onReorder: _reorderSelected,
                                  itemBuilder: (context, index) {
                                    final category = selectedCategories[index];
                                    return KeyedSubtree(
                                      key: ValueKey(category.categoryId),
                                      child: _buildCategoryCard(
                                        context: context,
                                        category: category,
                                        isSelected: true,
                                        showDragHandle: true,
                                        reorderIndex: index,
                                        radius: radiusForIndex(
                                          index,
                                          selectedCategories.length,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedIds.remove(
                                              category.categoryId,
                                            );
                                            _selectedOrder.remove(
                                              category.categoryId,
                                            );
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(
                                  height: AppSizing.spaceBtwElements,
                                ),
                              ],
                              if (unselectedCategories.isNotEmpty) ...[
                                Text(
                                  context.l10n.available,
                                  style: AppTextStyles.sectionTitle(context),
                                ),
                                const SizedBox(height: AppSizing.spaceBtwItems),
                                ...unselectedCategories.map(
                                  (category) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSizing.spaceBtwItemsExtra,
                                    ),
                                    child: _buildCategoryCard(
                                      context: context,
                                      category: category,
                                      isSelected: false,
                                      showDragHandle: false,
                                      radius: radiusForIndex(
                                        unselectedCategories.indexOf(category),
                                        unselectedCategories.length,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedIds.add(category.categoryId);
                                          _selectedOrder.add(
                                            category.categoryId,
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          PrimaryButton(
            text: context.l10n.save,
            onPressed: _isSaving ? null : () => _onSave(context),
            size: PrimaryButtonSize.medium,
            rounded: true,
            isLoading: _isSaving,
          ),
        ],
      ),
    );
  }
}

extension on _QuickWidgetCategoriesSheetState {
  Widget _buildCategoryCard({
    required BuildContext context,
    required CategoryModel category,
    required bool isSelected,
    required bool showDragHandle,
    int? reorderIndex,
    required CardRadius radius,
    required VoidCallback onTap,
  }) {
    final shade = findShadeById(category.colorId);
    final icon = findIconById(category.iconId);
    final color = shade?.color ?? Colors.grey;
    final colorScheme = Theme.of(context).colorScheme;

    final leading = Container(
      width: AppSizing.heightS,
      height: AppSizing.heightS,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
      ),
      child: Icon(
        icon?.icon ?? Icons.category,
        size: AppSizing.iconSizeM,
        color: color,
      ),
    );

    Widget? trailing;
    if (showDragHandle && reorderIndex != null) {
      trailing = ReorderableDragStartListener(
        index: reorderIndex,
        child: Icon(
          Icons.drag_handle,
          color: colorScheme.onSurfaceVariant,
          size: AppSizing.iconSizeL,
        ),
      );
    }

    final card = CategoryCard(
      title: category.name,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      style: CategoryCardStyle.filled,
      radius: radius,
    );

    if (isSelected) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSizing.spaceBtwItemsExtra),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSizing.borderRadius12),
          ),
          child: card,
        ),
      );
    }
    return card;
  }
}
