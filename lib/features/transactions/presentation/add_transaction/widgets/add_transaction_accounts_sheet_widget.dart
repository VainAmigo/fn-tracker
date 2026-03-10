import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AddTransactionAccountsSheetWidget extends StatelessWidget {
  const AddTransactionAccountsSheetWidget({super.key});

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
          TitledSection(
            title: 'Your wallets',
            children: [
              WalletVerticalListWidget(
                autoLoad: true,
                shrinkWrap: true,
                cardStyle: CategoryCardStyle.filled,
                onWalletSelected: (wallet) {
                  Navigator.of(context).pop(wallet);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          TitledSection(
            title: 'Your goals',
            children: [
              GoalsListWidget(
                autoLoad: true,
                onGoalSelected: (goal) {
                  Navigator.of(context).pop(goal);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
