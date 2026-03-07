import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class HomeInfoListWidget extends StatelessWidget {
  const HomeInfoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BudgetStatWidget(),
          TitledSection(
            title: 'Last Transactions',
            action: PrimaryButton(
              text: 'View All',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.transactions),
              size: PrimaryButtonSize.xSmall,
              fullWidth: false,
              rounded: true,
            ),
            children: [
              LastTransactionsListWidget(),
              const SizedBox(height: AppSizing.spaceBtwElements),
            ],
          ),
        ],
      ),
    );
  }
}
