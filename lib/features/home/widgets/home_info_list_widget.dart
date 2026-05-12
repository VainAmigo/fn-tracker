import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class HomeInfoListWidget extends StatelessWidget {
  const HomeInfoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitledSection(
            title: context.l10n.wallets,
            action: PrimaryButton(
              text: context.l10n.settings,
              onPressed: () => HomeWalletsSettingsSheet.show(context),
              size: PrimaryButtonSize.xSmall,
              fullWidth: false,
              rounded: true,
            ),
            children: [
              const HomeWalletsStripWidget(),
              const SizedBox(height: AppSizing.spaceBtwElements),
            ],
          ),
          TitledSection(
            title: context.l10n.quickCategories,
            action: PrimaryButton(
              text: context.l10n.settings,
              onPressed: () => QuickCategoriesSettingsSheet.show(context),
              size: PrimaryButtonSize.xSmall,
              fullWidth: false,
              rounded: true,
            ),
            children: [const QuickCategoriesWidget()],
          ),
          TitledSection(
            title: context.l10n.lastTransactions,
            action: PrimaryButton(
              text: context.l10n.viewAll,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.transactions),
              size: PrimaryButtonSize.xSmall,
              fullWidth: false,
              rounded: true,
            ),
            children: [
              LastTransactionsListWidget(),
              const SizedBox(height: AppSizing.spaceBtwElements),
            ],
          ),
          PrimaryButton(
            text: context.l10n.edit,
            size: PrimaryButtonSize.xSmall,
          ),
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }
}
