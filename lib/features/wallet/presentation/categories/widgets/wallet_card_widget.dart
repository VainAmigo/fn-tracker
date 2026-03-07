import 'package:flutter/material.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget({super.key, required this.wallet});

  final WalletModel wallet;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shade = findShadeById(wallet.colorId);
    final icon = findIconById(wallet.iconId);
    final color = shade?.color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: AppSizing.heightXS,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Icon(
                    icon?.icon ?? Icons.category,
                    size: AppSizing.iconSizeS,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: AppSizing.spaceBtwItems),
              Expanded(
                child: Text(
                  wallet.name,
                  style: AppTextStyles.listTileTitle(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            wallet.balance.toString(),
            style: AppTextStyles.listTileTitle(
              context,
            ).copyWith(color: colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }
}
