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
                    _onWalletSelected(context, wallet),
                onHiddenCardsSelected: () => _onHiddenCardsSelected(context),
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

  void _onWalletSelected(BuildContext context, WalletModel wallet) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: WalletDetailsModalSheetWidget(
        wallet: wallet,
        onEdit: () => _onUpdateWallet(context, wallet),
        onDefaultChanged: () => _onDefaultChanged(context, wallet),
        onHideAmountChanged: (hide) =>
            _onHideAmountChanged(context, wallet, hide),
        onHideWalletChanged: (hidden) =>
            _onHideWalletChanged(context, wallet, hidden),
      ),
    );
  }

  void _onHideAmountChanged(
    BuildContext context,
    WalletModel wallet,
    bool hide,
  ) {
    context.read<WalletCubit>().updateWallet(
      wallet: wallet.copyWith(hideAmount: hide),
    );
  }

  Future<void> _onHideWalletChanged(
    BuildContext context,
    WalletModel wallet,
    bool isHidden,
  ) async {
    final cubit = context.read<WalletCubit>();
    if (isHidden && !await _ensurePinWhenHiding(context)) return;
    cubit.updateWallet(
      wallet: wallet.copyWith(
        isHidden: isHidden,
        isDefault: isHidden ? false : wallet.isDefault,
      ),
    );
  }

  Future<void> _onHiddenCardsSelected(BuildContext context) async {
    final walletCubit = context.read<WalletCubit>();
    final result = await _showHiddenCardsPasswordSheet(context);
    if (result != true || !context.mounted) return;

    final hiddenWallets = walletCubit.currentWallets
        .where((w) => w.isHidden)
        .toList();

    if (!context.mounted) return;
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: WalletHiddenListSheet(
        wallets: hiddenWallets,
        onWalletSelected: (wallet) => _onWalletSelected(context, wallet),
        onDefaultChanged: (wallet) => _onDefaultChanged(context, wallet),
        onChangePin: () => _onChangePin(context),
      ),
    );
  }

  Future<void> _onChangePin(BuildContext context) async {
    final result = await ChangePinFormModalSheet.show(
      context,
      title: context.l10n.changePin,
      onSubmit: (currentPin, newPin) async {
        return HiddenWalletsService.instance.changePin(
          currentPin: currentPin,
          newPin: newPin,
        );
      },
    );
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.pinSuccessfullyChanged)));
    }
  }

  void _onDefaultChanged(BuildContext context, WalletModel wallet) {
    context.read<WalletCubit>().updateWallet(
      wallet: wallet.copyWith(isDefault: !wallet.isDefault),
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
    if (isHidden && !await _ensurePinWhenHiding(context)) return;
    cubit.updateGoal(goal: goal.copyWith(isHidden: isHidden));
  }

  Future<bool> _ensurePinWhenHiding(BuildContext context) async {
    final hasPin = await HiddenWalletsService.instance.hasPin;
    if (hasPin) return true;
    if (!context.mounted) return false;
    final result = await PasswordFormModalSheet.show(
      context,
      title: context.l10n.setPin,
      subtitle: context.l10n.pinRequiredForHiddenCards,
      isSetMode: true,
      submitLabel: context.l10n.setPin,
      confirmLabel: context.l10n.setPin,
      onSubmit: (pin) async {
        await HiddenWalletsService.instance.setPin(pin);
        return true;
      },
    );
    return result == true;
  }

  Future<void> _onHiddenGoalsSelected(BuildContext context) async {
    final goalsCubit = context.read<GoalsCubit>();
    final result = await _showHiddenCardsPasswordSheet(context);
    if (result != true || !context.mounted) return;

    final hiddenGoals =
        goalsCubit.currentGoals.where((g) => g.isHidden).toList();

    if (!context.mounted) return;
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: GoalHiddenListSheet(
        goals: hiddenGoals,
        onGoalSelected: (goal) => _onGoalSelected(context, goal),
        onChangePin: () => _onChangePin(context),
      ),
    );
  }

  Future<bool?> _showHiddenCardsPasswordSheet(BuildContext context) {
    return PasswordFormModalSheet.show(
      context,
      title: context.l10n.hiddenCards,
      subtitle: context.l10n.enterPinToView,
      submitLabel: context.l10n.open,
      onSubmit: (pin) async {
        final valid = await HiddenWalletsService.instance.verifyPin(pin);
        if (!valid) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.invalidPin)),
            );
          }
          return false;
        }
        return true;
      },
    );
  }

  void _onUpdateGoal(BuildContext context, GoalModel goal) {
    Navigator.of(context).pushNamed(AppRouter.updateGoal, arguments: goal);
  }
}
