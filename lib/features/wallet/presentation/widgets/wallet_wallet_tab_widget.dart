import 'package:flutter/material.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletWalletTabWidget extends StatelessWidget {
  const WalletWalletTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet',
            style: AppTextStyles.tabTitle(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}
