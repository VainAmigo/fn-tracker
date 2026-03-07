import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
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
    } else {
      _nameController = TextEditingController();
      _limit = null;
      _selectedIcon = categoryIconGroups[0].icons.first;
      _selectedShade = categoryColorPalettes[0].shades.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;
    final colorScheme = Theme.of(context).colorScheme;
    final categoriesState = context.watch<CategoriesCubit>().state;
    final isLoading = categoriesState is CategoryCreating ||
        categoriesState is CategoryUpdating;
    final isDeleting = categoriesState is CategoryDeleting;

    return MultiBlocListener(
      listeners: [
        BlocListener<CategoriesCubit, CategoriesState>(
          listener: (context, state) {
            if (state is CategoryCreateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Category created successfully')),
              );
              Navigator.of(context).pop();
            }
            if (state is CategoryCreateError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
        ),
        BlocListener<CategoriesCubit, CategoriesState>(
          listener: (context, state) {
            if (state is CategoryUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Category updated successfully')),
              );
              Navigator.of(context).pop();
            }
            if (state is CategoryUpdateError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
        ),
        BlocListener<CategoriesCubit, CategoriesState>(
          listener: (context, state) {
            if (state is CategoryDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Category deleted successfully')),
              );
              Navigator.of(context).pop();
            }
            if (state is CategoryDeleteError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Update Category' : 'Create Category'),
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
                          label: 'Category name',
                          hintText: 'e.g. Groceries',
                          controller: _nameController,
                        ),
                        CategoryCard(
                          title: _limit ?? 'no limit',
                          subtitle: 'Monthly limit',
                          leading: Icon(
                            Icons.data_usage_rounded,
                            color: colorScheme.onSecondary,
                          ),
                          onTap: () =>
                              _openLimitSheet(context, currency, _limit),
                        ),
                        CreateCategoryIconPickerWidget(
                          selectedIcon: _selectedIcon,
                          selectedColor: _selectedShade.color,
                          onIconSelected: (icon) =>
                              setState(() => _selectedIcon = icon),
                        ),
                        CreateCategoryColorPickerWidget(
                          selectedShade: _selectedShade,
                          onShadeSelected: (shade) =>
                              setState(() => _selectedShade = shade),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                if (_isEditing) ...[
                  PrimaryButton(
                    text: 'Delete',
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.3),
                    foregroundColor: colorScheme.primary,
                    size: PrimaryButtonSize.small,
                    rounded: true,
                    onPressed:
                        isLoading || isDeleting ? null : _deleteCategory,
                    isLoading: isDeleting,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                ],
                PrimaryButton(
                  text: _isEditing ? 'Update' : 'Create',
                  onPressed:
                      isLoading || isDeleting ? null : _submitCategory,
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

  void _openLimitSheet(
      BuildContext context, Currency currency, String? limit) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.defaultPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AmountInputWidget(
              initialAmount: limit ?? '',
              currency: currency,
              onAmountChanged: (amount) {
                setState(() {
                  _limit = amount;
                });
              },
            ),
            PrimaryButton(
              text: 'Save',
              onPressed: () {
                Navigator.of(context).pop();
              },
              size: PrimaryButtonSize.medium,
            ),
            const SizedBox(height: AppSizing.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  void _deleteCategory() {
    context.read<CategoriesCubit>().deleteCategory(
          categoryId: widget.category!.categoryId,
        );
  }

  void _submitCategory() {
    final name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    final double? limitValue =
        _limit != null && _limit!.isNotEmpty ? double.parse(_limit!) : null;

    if (_isEditing) {
      final category = CategoryModel(
        categoryId: widget.category!.categoryId,
        name: name,
        colorId: _selectedShade.id,
        iconId: _selectedIcon.id,
        limitValue: limitValue,
        createdAt: widget.category!.createdAt,
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
