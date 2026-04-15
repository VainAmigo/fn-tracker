import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletDetailsModalSheetWidget extends StatelessWidget {
  const WalletDetailsModalSheetWidget({
    super.key,
    required this.wallet,
    required this.onEdit,
    this.onDefaultChanged,
    required this.onHideAmountChanged,
    required this.onHideWalletChanged,
  });

  final WalletModel wallet;
  final VoidCallback onEdit;
  final VoidCallback? onDefaultChanged;
  final void Function(bool hideAmount) onHideAmountChanged;
  final Future<void> Function(bool isHidden) onHideWalletChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(
            title: context.l10n.walletDetails,
            action: PrimaryButton(
              text: context.l10n.edit,
              onPressed: onEdit,
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          WalletCardWidget(
            wallet: wallet,
            onDefaultChanged: onDefaultChanged,
            isEnabled: true,
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          SwitchListTile(
            title: Text(
              context.l10n.hideAmount,
              style: AppTextStyles.text16w400(context),
            ),
            value: wallet.hideAmount,
            onChanged: (_) => onHideAmountChanged(!wallet.hideAmount),
          ),
          SwitchListTile(
            title: Text(
              context.l10n.hideWallet,
              style: AppTextStyles.text16w400(context),
            ),
            subtitle: Text(
              context.l10n.hideWalletSubtitle,
              style: AppTextStyles.text14w400(context),
            ),
            value: wallet.isHidden,
            onChanged: (_) => onHideWalletChanged(!wallet.isHidden),
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          PrimaryButton(
            text: context.l10n.history,
            icon: Icons.history,
            size: PrimaryButtonSize.xSmall,
            rounded: true,
            backgroundColor: colorScheme.tertiary.withValues(alpha: 0.3),
            foregroundColor: colorScheme.tertiary,
            onPressed: () => Navigator.of(context).pushNamed(
              AppRouter.transactionsById,
              arguments: {'idType': TransactionIdType.wallet, 'id': wallet.id},
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: AppSizing.spaceBtwItemsExtra,
            children: [
              BlocListener<WalletCubit, WalletsState>(
                listenWhen: (prev, curr) =>
                    curr is WalletsLoaded || curr is WalletsError,
                listener: (context, state) {
                  if (state is WalletsLoaded) {
                    Navigator.of(context).pop();
                  }
                  if (state is WalletsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: PrimaryButton(
                  text: context.l10n.delete,
                  icon: Icons.delete,
                  iconOnly: true,
                  fullWidth: false,
                  size: PrimaryButtonSize.large,
                  paddingStyle: PrimaryButtonPaddingStyle.slim,
                  rounded: true,
                  onPressed: () async {
                    final result = await showDeleteEntityDialog(
                      context,
                      title: context.l10n.deleteWalletTitle,
                      message:
                          '${context.l10n.deleteWalletMessage} «${wallet.name}»? ${context.l10n.deleteWalletMessageHint}',
                    );
                    if (!context.mounted || result == null || result == DeleteEntityResult.cancel) return;
                    context.read<WalletCubit>().deleteWallet(
                          walletId: wallet.id!,
                          deleteTransactions:
                              result == DeleteEntityResult.deleteFull,
                        );
                  },
                ),
              ),
              Flexible(
                child: PrimaryButton(
                  text: context.l10n.deposit,
                  icon: Icons.add,
                  size: PrimaryButtonSize.large,
                  rounded: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).pushNamed(AppRouter.addTransaction, arguments: wallet);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }
}
