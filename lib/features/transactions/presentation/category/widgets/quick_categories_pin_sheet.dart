import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class QuickCategoriesPinSheet extends StatefulWidget {
  const QuickCategoriesPinSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: false,
      child: const QuickCategoriesPinSheet(),
    );
  }

  @override
  State<QuickCategoriesPinSheet> createState() =>
      _QuickCategoriesPinSheetState();
}

class _QuickCategoriesPinSheetState extends State<QuickCategoriesPinSheet> {
  final Set<String> _pinnedIds = {};
  List<String> _pinnedOrder = [];
  bool _initialized = false;
  bool _isSaving = false;

  void _initFromCategories(
    List<CategoryModel> categories,
    List<String> storedOrder,
  ) {
    if (_initialized) return;
    _initialized = true;
    for (final c in categories) {
      if (c.isQuick == true) {
        _pinnedIds.add(c.categoryId);
      }
    }
    _pinnedOrder = List.from(storedOrder);
    _pinnedOrder.removeWhere((id) => !_pinnedIds.contains(id));
    for (final c in categories) {
      if (c.isQuick == true && !_pinnedOrder.contains(c.categoryId)) {
        _pinnedOrder.add(c.categoryId);
      }
    }
  }

  void _reorderPinned(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final id = _pinnedOrder.removeAt(oldIndex);
      _pinnedOrder.insert(newIndex, id);
    });
  }

  Future<void> _onSave(BuildContext context) async {
    setState(() => _isSaving = true);

    final categoriesCubit = context.read<CategoriesCubit>();
    final settingsCubit = context.read<QuickCategoriesSettingsCubit>();
    final navigator = Navigator.of(context);

    try {
      final categoriesState = categoriesCubit.state;
      final categories = switch (categoriesState) {
        CategoriesLoaded s => s.categories,
        _ => <CategoryModel>[],
      };

      for (final category in categories) {
        final shouldBePinned = _pinnedIds.contains(category.categoryId);
        if (category.isQuick != shouldBePinned) {
          await categoriesCubit.updateCategory(
            categoryModel: CategoryModel(
              categoryId: category.categoryId,
              name: category.name,
              colorId: category.colorId,
              iconId: category.iconId,
              limitValue: category.limitValue,
              createdAt: category.createdAt,
              isQuick: shouldBePinned,
            ),
          );
        }
      }

      await settingsCubit.setPinnedOrder(_pinnedOrder);
      navigator.pop();
    } catch (_) {
      if (context.mounted) setState(() => _isSaving = false);
    }
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
            title: context.l10n.pinnedCategories,
            subtitle: context.l10n.selectCategoriesToShowInQuickAccess,
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

                        _initFromCategories(
                          categories,
                          settingsState.pinnedOrder,
                        );

                        if (categories.isEmpty) {
                          return Center(
                            child: Text(
                              context.l10n.createCategoriesFirst,
                              style: AppTextStyles.listTileSubtitle(context),
                            ),
                          );
                        }

                        final categoryMap = {
                          for (final c in categories) c.categoryId: c,
                        };
                        final pinnedCategories = _pinnedOrder
                            .where((id) => categoryMap.containsKey(id))
                            .map((id) => categoryMap[id]!)
                            .toList();
                        final unpinnedCategories = categories
                            .where((c) => !_pinnedIds.contains(c.categoryId))
                            .toList();

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (pinnedCategories.isNotEmpty) ...[
                                Text(
                                  context.l10n.pinned,
                                  style: AppTextStyles.sectionTitle(context),
                                ),
                                const SizedBox(height: AppSizing.spaceBtwItems),
                                ReorderableListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  buildDefaultDragHandles: false,
                                  itemCount: pinnedCategories.length,
                                  onReorder: _reorderPinned,
                                  itemBuilder: (context, index) {
                                    final category = pinnedCategories[index];
                                    final radius = radiusForIndex(
                                      index,
                                      pinnedCategories.length,
                                    );
                                    return KeyedSubtree(
                                      key: ValueKey(category.categoryId),
                                      child: _buildCategoryCard(
                                        context: context,
                                        category: category,
                                        isPinned: true,
                                        showDragHandle: true,
                                        reorderIndex: index,
                                        radius: radius,
                                        onTap: () {
                                          setState(() {
                                            _pinnedIds.remove(
                                              category.categoryId,
                                            );
                                            _pinnedOrder.remove(
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
                              if (unpinnedCategories.isNotEmpty) ...[
                                Text(
                                  context.l10n.available,
                                  style: AppTextStyles.sectionTitle(context),
                                ),
                                const SizedBox(height: AppSizing.spaceBtwItems),
                                ...unpinnedCategories.map(
                                  (category) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSizing.spaceBtwItemsExtra,
                                    ),
                                    child: _buildCategoryCard(
                                      context: context,
                                      category: category,
                                      isPinned: false,
                                      showDragHandle: false,
                                      radius: radiusForIndex(
                                        unpinnedCategories.indexOf(category),
                                        unpinnedCategories.length,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _pinnedIds.add(category.categoryId);
                                          _pinnedOrder.add(category.categoryId);
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

  Widget _buildCategoryCard({
    required BuildContext context,
    required CategoryModel category,
    required bool isPinned,
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

    if (isPinned) {
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
