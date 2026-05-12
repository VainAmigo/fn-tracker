import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';

/// Открытие шитов кошелька (главная и вкладка «Счета»).
abstract final class WalletSheetFlow {
  static void openWalletDetails(BuildContext context, WalletModel wallet) {
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: WalletDetailsModalSheetWidget(
        wallet: wallet,
        onEdit: () => Navigator.of(context).pushNamed(
          AppRouter.updateWallet,
          arguments: wallet,
        ),
        onDefaultChanged: () => context.read<WalletCubit>().updateWallet(
              wallet: wallet.copyWith(isDefault: !wallet.isDefault),
            ),
        onHideAmountChanged: (hide) => context.read<WalletCubit>().updateWallet(
              wallet: wallet.copyWith(hideAmount: hide),
            ),
        onHideWalletChanged: (hidden) async {
          final cubit = context.read<WalletCubit>();
          if (hidden && !await ensurePinWhenHiding(context)) return;
          if (!context.mounted) return;
          cubit.updateWallet(
            wallet: wallet.copyWith(
              isHidden: hidden,
              isDefault: hidden ? false : wallet.isDefault,
            ),
          );
        },
      ),
    );
  }

  static Future<void> openHiddenWallets(BuildContext context) async {
    final walletCubit = context.read<WalletCubit>();
    final result = await SensitiveUnlockCoordinator.verifyForSensitiveAction(
      context,
    );
    if (result != true || !context.mounted) return;

    final hiddenWallets =
        walletCubit.currentWallets.where((w) => w.isHidden).toList();

    if (!context.mounted) return;
    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: WalletHiddenListSheet(
        wallets: hiddenWallets,
        onWalletSelected: (w) => openWalletDetails(context, w),
        onDefaultChanged: (w) => context.read<WalletCubit>().updateWallet(
              wallet: w.copyWith(isDefault: !w.isDefault),
            ),
        onChangePin: () => changePin(context),
      ),
    );
  }

  static Future<void> changePin(BuildContext context) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pinSuccessfullyChanged)),
      );
    }
  }

  static Future<bool> ensurePinWhenHiding(BuildContext context) async {
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
}
