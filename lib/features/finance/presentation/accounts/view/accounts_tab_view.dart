import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
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
            title: context.l10n.wallets,
            action: PrimaryButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.createWallet);
              },
              text: context.l10n.createWallet,
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
            children: [
              WalletsListWidget(
                autoLoad: true,
                onWalletSelected: (wallet) =>
                    WalletSheetFlow.openWalletDetails(context, wallet),
                onHiddenCardsSelected: () =>
                    WalletSheetFlow.openHiddenWallets(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          TitledSection(
            title: context.l10n.yourGoals,
            action: PrimaryButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRouter.createGoal),
              text: context.l10n.newGoal,
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
            children: [
              GoalListWithTotalWidget(
                autoLoad: true,
                shrinkWrap: true,
                onGoalSelected: (goal) => _onGoalSelected(context, goal),
                onHiddenCardsSelected: () => _onHiddenGoalsSelected(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }

  void _onGoalSelected(BuildContext context, GoalModel goal) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: GoalDetailsModalSheetWidget(
        goal: goal,
        onEdit: () => _onUpdateGoal(context, goal),
        onHideAmountChanged: (hide) =>
            _onHideGoalAmountChanged(context, goal, hide),
        onHideGoalChanged: (hidden) =>
            _onHideGoalChanged(context, goal, hidden),
      ),
    );
  }

  void _onHideGoalAmountChanged(
    BuildContext context,
    GoalModel goal,
    bool hide,
  ) {
    context.read<GoalsCubit>().updateGoal(
      goal: goal.copyWith(hideAmount: hide),
    );
  }

  Future<void> _onHideGoalChanged(
    BuildContext context,
    GoalModel goal,
    bool isHidden,
  ) async {
    final cubit = context.read<GoalsCubit>();
    if (isHidden && !await WalletSheetFlow.ensurePinWhenHiding(context)) return;
    cubit.updateGoal(goal: goal.copyWith(isHidden: isHidden));
  }

  Future<void> _onHiddenGoalsSelected(BuildContext context) async {
    final goalsCubit = context.read<GoalsCubit>();
    final result = await SensitiveUnlockCoordinator.verifyForSensitiveAction(
      context,
    );
    if (result != true || !context.mounted) return;

    final hiddenGoals =
        goalsCubit.currentGoals.where((g) => g.isHidden).toList();

    if (!context.mounted) return;
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: GoalHiddenListSheet(
        goals: hiddenGoals,
        onGoalSelected: (goal) => _onGoalSelected(context, goal),
        onChangePin: () => WalletSheetFlow.changePin(context),
      ),
    );
  }

  void _onUpdateGoal(BuildContext context, GoalModel goal) {
    Navigator.of(context).pushNamed(AppRouter.updateGoal, arguments: goal);
  }
}
