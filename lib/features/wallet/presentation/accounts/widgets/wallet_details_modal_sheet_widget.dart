import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletDetailsModalSheetWidget extends StatelessWidget {
  const WalletDetailsModalSheetWidget({
    super.key,
    required this.wallet,
    required this.onEdit,
  });

  final WalletModel wallet;
  final VoidCallback onEdit;

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
            title: 'Wallet details',
            action: PrimaryButton(
              text: 'Edit',
              onPressed: onEdit,
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          WalletCardWidget(wallet: wallet),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          PrimaryButton(
            text: 'History',
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
                listener: (context, state) {
                  if (state is WalletsLoaded) {
                    Navigator.of(context).pop();
                  }
                },
                child: PrimaryButton(
                  text: 'Delete',
                  icon: Icons.delete,
                  iconOnly: true,
                  fullWidth: false,
                  size: PrimaryButtonSize.large,
                  paddingStyle: PrimaryButtonPaddingStyle.slim,
                  rounded: true,
                  onPressed: () {
                    context.read<WalletCubit>().deleteWallet(
                      walletId: wallet.id!,
                    );
                  },
                ),
              ),
              Flexible(
                child: PrimaryButton(
                  text: 'Deposit',
                  icon: Icons.add,
                  size: PrimaryButtonSize.large,
                  rounded: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(
                      AppRouter.addTransaction,
                      arguments: wallet,
                    );
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
