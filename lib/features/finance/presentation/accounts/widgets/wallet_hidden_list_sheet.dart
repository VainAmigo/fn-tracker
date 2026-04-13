import 'package:flutter/material.dart';
import 'package:fn_tracker/features/features.dart';

class WalletHiddenListSheet extends StatelessWidget {
  const WalletHiddenListSheet({
    super.key,
    required this.wallets,
    required this.onWalletSelected,
    required this.onDefaultChanged,
    this.onChangePin,
  });

  final List<WalletModel> wallets;
  final void Function(WalletModel wallet) onWalletSelected;
  final void Function(WalletModel wallet) onDefaultChanged;
  final VoidCallback? onChangePin;

  @override
  Widget build(BuildContext context) {
    return HiddenCardsSheet<WalletModel>(
      title: 'Скрытые карточки',
      items: wallets,
      itemBuilder: (wallet) => WalletCardWidget(
        wallet: wallet,
        onDefaultChanged: () => onDefaultChanged(wallet),
        isEnabled: true,
      ),
      onItemTap: onWalletSelected,
      onChangePin: onChangePin,
    );
  }
}
