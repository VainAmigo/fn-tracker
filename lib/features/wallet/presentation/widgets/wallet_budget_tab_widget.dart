import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletBudgetTabWidget extends StatelessWidget {
  const WalletBudgetTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget',
            style: AppTextStyles.tabTitle(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}
