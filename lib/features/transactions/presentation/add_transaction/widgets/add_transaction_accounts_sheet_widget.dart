import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class AddTransactionAccountsSheetWidget extends StatelessWidget {
  const AddTransactionAccountsSheetWidget({super.key, this.excludedAccount});

  /// Account that cannot be selected (e.g. the "other" account in transfer)
  final Object? excludedAccount;

  static bool _isSameAccount(Object selected, Object excluded) {
    if (selected is WalletModel && excluded is WalletModel) {
      return selected.id == excluded.id;
    }
    if (selected is GoalModel && excluded is GoalModel) {
      return selected.id == excluded.id;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
        bottom: AppSizing.bottomPadding,
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModalSheetTitleWidget(title: context.l10n.chooseAccount),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Text(
            context.l10n.yourWallets,
            style: AppTextStyles.listTileTitle(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          Flexible(
            child: SingleChildScrollView(
              child: WalletVerticalListWidget(
                autoLoad: true,
                shrinkWrap: true,
                cardStyle: CategoryCardStyle.filled,
                onWalletSelected: (wallet) {
                  if (excludedAccount != null &&
                      _isSameAccount(wallet, excludedAccount!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.cannotSelectSameAccount),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop(wallet);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          Text(
            context.l10n.yourGoals,
            style: AppTextStyles.listTileTitle(context),
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          Flexible(
            child: SingleChildScrollView(
              child: GoalsListWidget(
                autoLoad: true,
                shrinkWrap: true,
                onGoalSelected: (goal) {
                  if (excludedAccount != null &&
                      _isSameAccount(goal, excludedAccount!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.cannotSelectSameAccount),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop(goal);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
