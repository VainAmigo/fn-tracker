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
            children: [
              WalletsListWidget(
                autoLoad: true,
                onWalletSelected: (wallet) =>
                    _onWalletSelected(context, wallet),
              ),
            ],
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
            children: [
              GoalListWithTotalWidget(
                autoLoad: true,
                shrinkWrap: true,
                onGoalSelected: (goal) => _onGoalSelected(context, goal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onWalletSelected(BuildContext context, WalletModel wallet) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: WalletDetailsModalSheetWidget(
        wallet: wallet,
        onEdit: () => _onUpdateWallet(context, wallet),
      ),
    );
  }

  void _onUpdateWallet(BuildContext context, WalletModel wallet) {
    Navigator.of(context).pushNamed(AppRouter.updateWallet, arguments: wallet);
  }

  void _onGoalSelected(BuildContext context, GoalModel goal) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: GoalDetailsModalSheetWidget(
        goal: goal,
        onEdit: () => _onUpdateGoal(context, goal),
      ),
    );
  }

  void _onUpdateGoal(BuildContext context, GoalModel goal) {
    Navigator.of(context).pushNamed(AppRouter.updateGoal, arguments: goal);
  }
}
