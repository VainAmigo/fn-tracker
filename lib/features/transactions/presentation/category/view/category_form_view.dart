import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class CategoryFormView extends StatefulWidget {
  const CategoryFormView({super.key, this.category});

  final CategoryModel? category;

  @override
  State<CategoryFormView> createState() => _CategoryFormViewState();
}

class _CategoryFormViewState extends State<CategoryFormView> {
  late CategoryIcon _selectedIcon;
  late CategoryShade _selectedShade;
  late TextEditingController _nameController;
  late String? _limit;
  bool _isSubmitting = false;
  bool _isDeleting = false;
  bool _defaultsInitialized = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    if (category != null) {
      _nameController = TextEditingController(text: category.name);
      _limit = category.limitValue?.toString();
      _selectedIcon = findIconById(category.iconId)!;
      _selectedShade = findShadeById(category.colorId)!;
      _defaultsInitialized = true;
    } else {
      _nameController = TextEditingController();
      _limit = null;
      _selectedIcon = categoryIconGroups[0].icons.first;
      _selectedShade = categoryColorPalettes[0].shades.first;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultsInitialized) {
      _defaultsInitialized = true;
      final usedIds = _collectUsedIds(context);
      _selectedIcon = firstUnusedIcon(usedIds.iconIds);
      _selectedShade = firstUnusedShade(usedIds.colorIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  ({Set<String> colorIds, Set<String> iconIds}) _collectUsedIds(
    BuildContext context,
  ) {
    final wallets = context.read<WalletCubit>().currentWallets;
    final categories = context.read<CategoriesCubit>().currentCategories;

    final editingId = widget.category?.categoryId;

    final usedColorIds = <String>{};
    final usedIconIds = <String>{};

    for (final w in wallets) {
      usedColorIds.add(w.colorId);
      usedIconIds.add(w.iconId);
    }
    for (final c in categories) {
      if (c.categoryId == editingId) continue;
      usedColorIds.add(c.colorId);
      usedIconIds.add(c.iconId);
    }

    return (colorIds: usedColorIds, iconIds: usedIconIds);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoriesState = context.watch<CategoriesCubit>().state;
    final isLoading = _isSubmitting && categoriesState is CategoriesLoading;
    final usedIds = _collectUsedIds(context);

    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (!_isSubmitting) return;
        if (state is CategoriesLoaded || state is CategoriesEmpty) {
          _isSubmitting = false;
          final message = _isDeleting
              ? context.l10n.categoryDeleted
              : _isEditing
                  ? context.l10n.categoryUpdatedSuccessfully
                  : context.l10n.categoryCreatedSuccessfully;
          _isDeleting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          Navigator.of(context).pop();
        }
        if (state is CategoriesError) {
          _isSubmitting = false;
          _isDeleting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? context.l10n.updateCategory : context.l10n.createCategory),
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizing.defaultPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSizing.spaceBtwElements,
                      children: [
                        const SizedBox(height: AppSizing.spaceBtwElements),
                        _buildPreview(context),
                        CustomTextFormField(
                          label: context.l10n.categoryName,
                          controller: _nameController,
                        ),
                        FormCardWidget(
                          title: _limit ?? context.l10n.noLimit,
                          subtitle: context.l10n.monthlyLimit,
                          icon: Icon(
                            Icons.data_usage_rounded,
                            color: colorScheme.onSecondary,
                          ),
                          onTap: () =>
                              _openLimitSheet(context, _limit),
                        ),
                        CreateCategoryIconPickerWidget(
                          selectedIcon: _selectedIcon,
                          selectedColor: _selectedShade.color,
                          onIconSelected: (icon) =>
                              setState(() => _selectedIcon = icon),
                          usedIconIds: usedIds.iconIds,
                        ),
                        CreateCategoryColorPickerWidget(
                          selectedShade: _selectedShade,
                          onShadeSelected: (shade) =>
                              setState(() => _selectedShade = shade),
                          usedColorIds: usedIds.colorIds,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                if (_isEditing) ...[
                  PrimaryButton(
                    text: context.l10n.delete,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
                    foregroundColor: colorScheme.primary,
                    size: PrimaryButtonSize.small,
                    rounded: true,
                    onPressed: isLoading ? null : _deleteCategory,
                    isLoading: false,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                ],
                PrimaryButton(
                  text: _isEditing ? context.l10n.update : context.l10n.create,
                  onPressed: isLoading ? null : _submitCategory,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Center(
      child: Container(
        width: AppSizing.heightL,
        height: AppSizing.heightL,
        decoration: BoxDecoration(
          color: _selectedShade.color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
        ),
        child: Icon(
          _selectedIcon.icon,
          size: AppSizing.iconSizeL,
          color: _selectedShade.color,
        ),
      ),
    );
  }

  void _openLimitSheet(BuildContext context, String? limit) {
    final initialAmount = limit != null && limit.isNotEmpty
        ? double.tryParse(limit)
        : null;
    AmountFormModalSheet.show(
      context,
      initialAmount: initialAmount,
      saveLabel: context.l10n.save,
      onSave: (amount) => setState(() => _limit = amount.toString()),
    );
  }

  Future<void> _deleteCategory() async {
    final result = await showDeleteEntityDialog(
      context,
      title: context.l10n.deleteCategoryTitle,
      message:
          '${context.l10n.deleteCategoryMessage} «${widget.category!.name}»? ${context.l10n.deleteCategoryMessageHint}',
    );
    if (!mounted ||
        result == null ||
        result == DeleteEntityResult.cancel) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _isDeleting = true;
    });
    context.read<CategoriesCubit>().deleteCategory(
          categoryId: widget.category!.categoryId,
          deleteTransactions: result == DeleteEntityResult.deleteFull,
        );
  }

  void _submitCategory() {
    final name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.nameIsRequired)));
      return;
    }

    final double? limitValue = _limit != null && _limit!.isNotEmpty
        ? double.parse(_limit!)
        : null;

    setState(() => _isSubmitting = true);

    if (_isEditing) {
      final category = CategoryModel(
        categoryId: widget.category!.categoryId,
        name: name,
        colorId: _selectedShade.id,
        iconId: _selectedIcon.id,
        limitValue: limitValue,
        createdAt: widget.category!.createdAt,
        isQuick: widget.category!.isQuick,
      );
      context.read<CategoriesCubit>().updateCategory(categoryModel: category);
    } else {
      final category = CategoryModel(
        categoryId: '',
        name: name,
        colorId: _selectedShade.id,
        iconId: _selectedIcon.id,
        limitValue: limitValue,
      );
      context.read<CategoriesCubit>().createCategory(categoryModel: category);
    }
  }
}
