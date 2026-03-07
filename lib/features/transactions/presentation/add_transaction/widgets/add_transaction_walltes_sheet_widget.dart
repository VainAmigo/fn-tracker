import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class AddTransactionWalletsSheetWidget extends StatelessWidget {
  const AddTransactionWalletsSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
        bottom: AppSizing.bottomPadding,
      ),
      width: double.infinity,
      height: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose wallet',
            style: AppTextStyles.modalSheetTitle(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Expanded(
            child: WalletVerticalListWidget(
              autoLoad: true,
              cardStyle: CategoryCardStyle.filled,
              onWalletSelected: (wallet) {
                Navigator.of(context).pop(wallet);
              },
            ),
          ),
        ],
      ),
    );
  }
}
