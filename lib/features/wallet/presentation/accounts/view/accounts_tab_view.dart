import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AccountsTabWidget extends StatelessWidget {
  const AccountsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitledSection(
            title: 'Wallets',
            action: PrimaryButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.createWallet);
              },
              text: 'Create wallet',
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
            children: [WalletsListWidget(autoLoad: true)],
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          TitledSection(
            title: 'Your goals',
            action: PrimaryButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRouter.createGoal),
              text: 'New goal',
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
            children: [GoalListWithTotalWidget(autoLoad: true, shrinkWrap: true)],
          ),
        ],
      ),
    );
  }
}
