import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class UpdateCategoryView extends StatefulWidget {
  const UpdateCategoryView({super.key, required this.category});

  final CategoryModel category;

  @override
  State<UpdateCategoryView> createState() => _UpdateCategoryViewState();
}

class _UpdateCategoryViewState extends State<UpdateCategoryView> {
  late CategoryIcon _selectedIcon;
  late CategoryShade _selectedShade;
  late TextEditingController _nameController;
  late String? _limit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _limit = widget.category.limitValue?.toString();
    _selectedIcon = findIconById(widget.category.iconId)!;
    _selectedShade = findShadeById(widget.category.colorId)!;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;
    final colorScheme = Theme.of(context).colorScheme;
    final categoriesState = context.watch<CategoriesCubit>().state;
    final isUpdating = categoriesState is CategoryUpdating;
    final isDeleting = categoriesState is CategoryDeleting;

    return BlocListener<CategoriesCubit, CategoriesState>(
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
      child: BlocListener<CategoriesCubit, CategoriesState>(
        listener: (context, state) {
          if (state is CategoryDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Category deleted successfully')),
            );
            Navigator.of(context).pop();
          }
          if (state is CategoryDeleteError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Create Category')),
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
                  PrimaryButton(
                    text: 'Delete',
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
                    foregroundColor: colorScheme.primary,
                    size: PrimaryButtonSize.small,
                    rounded: true,
                    onPressed: isUpdating || isDeleting
                        ? null
                        : () => _deleteCategory(),
                    isLoading: isDeleting,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  PrimaryButton(
                    text: 'Update',
                    onPressed: isUpdating || isDeleting
                        ? null
                        : () => _updateCategory(),
                    isLoading: isUpdating,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwElements),
                ],
              ),
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

  void _openLimitSheet(BuildContext context, Currency currency, String? limit) {
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
      categoryId: widget.category.categoryId,
    );
  }

  void _updateCategory() {
    final name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    final category = CategoryModel(
      categoryId: widget.category.categoryId,
      name: name,
      colorId: _selectedShade.id,
      iconId: _selectedIcon.id,
      limitValue: _limit != null && _limit!.isNotEmpty
          ? double.parse(_limit!)
          : null,
      createdAt: widget.category.createdAt,
    );

    context.read<CategoriesCubit>().updateCategory(categoryModel: category);
  }
}
