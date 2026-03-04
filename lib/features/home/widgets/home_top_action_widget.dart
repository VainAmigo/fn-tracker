import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';

class HomeTopActionWidget extends StatelessWidget {
  const HomeTopActionWidget({super.key, required this.totalExpense});

  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: AppSizing.spaceBtwItems,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      today.formatMonthDay,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                text: 'Deposit',
                icon: Icons.add,
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRouter.addTransaction,
                ),
                size: PrimaryButtonSize.medium,
                paddingStyle: PrimaryButtonPaddingStyle.slim,
                rounded: true,
                fullWidth: false,
                iconOnly: true,
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          AmountWithSignWidget(
            amount: totalExpense,
            preset: AmountTextPreset.large,
          ),
        ],
      ),
    );
  }
}
