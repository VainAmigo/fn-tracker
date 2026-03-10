import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

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
                  Navigator.of(
                    context,
                  ).pushNamed(AppRouter.updateCategory, arguments: category);
                },
                autoLoad: true,
                shrinkWrap: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
