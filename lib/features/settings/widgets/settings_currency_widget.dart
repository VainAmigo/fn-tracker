import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/app_theme.dart';

/// Содержимое модального окна настроек валюты и форматов.
class SettingsCurrencyWidget extends StatelessWidget {
  const SettingsCurrencyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final currentCurrency = currencyProvider.currency;

    return Container(
      padding: const EdgeInsets.only(
        bottom: AppSizing.bottomPadding,
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(
            title: 'Currency and formats',
            subtitle: 'Select your currency and number format',
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          Column(
            children: [
              ...Currency.availableCurrencies.asMap().entries.map((entry) {
                final index = entry.key;
                final currency = entry.value;
                final isFirst = index == 0;
                final isLast = index == Currency.availableCurrencies.length - 1;
                final isSelected = currentCurrency.code == currency.code;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : AppSizing.spaceBtwElementsExtra,
                  ),
                  child: ListTile(
                    onTap: () {
                      currencyProvider.setCurrency(currency);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: isFirst
                            ? Radius.circular(AppSizing.borderRadius12)
                            : Radius.circular(AppSizing.borderRadius4),
                        bottom: isLast
                            ? Radius.circular(AppSizing.borderRadius12)
                            : Radius.circular(AppSizing.borderRadius4),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    tileColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    leading: Icon(
                      Icons.attach_money,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSecondary,
                    ),
                    title: Text(
                      '${currency.symbol} ${currency.name} (${currency.code})',
                      style: AppTextStyles.listTileTitle(
                        context,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      _formatPreview(currency),
                      style: AppTextStyles.listTileSubtitle(context,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPreview(Currency currency) {
    final formatter = CurrencyFormatter(currency);
    return formatter.format(123456.78);
  }
}
