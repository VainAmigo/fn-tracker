import 'package:flutter/material.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

class AddTransactionCategorySheetWidget extends StatelessWidget {
  const AddTransactionCategorySheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
        bottom: AppSizing.bottomPadding,
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModalSheetTitleWidget(title: 'Choose category'),
          const SizedBox(height: AppSizing.spaceBtwElements),

          Flexible(
            child: SingleChildScrollView(
              child: CategoryListWidget(
                autoLoad: true,
                shrinkWrap: true,
                cardStyle: CategoryCardStyle.filled,
                dismissible: false,
                onCategorySelected: (category) {
                  Navigator.of(context).pop(category);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
