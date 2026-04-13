import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class CategoriesTabView extends StatelessWidget {
  const CategoriesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitledSection(
            title: 'Categories',
            action: PrimaryButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.createCategory);
              },
              text: 'Create category',
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
            children: [
              CategoryListWidget(
                onCategorySelected: (category) {
                  _onCategorySelected(context, category);
                },
                autoLoad: true,
                shrinkWrap: true,
              ),
            ],
          ),
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }

  void _onCategorySelected(BuildContext context, CategoryModel category) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: CategoriesDetailModalSheetWidget(
        category: category,
        onEdit: () => Navigator.of(
          context,
        ).pushNamed(AppRouter.updateCategory, arguments: category),
      ),
    );
  }
}
