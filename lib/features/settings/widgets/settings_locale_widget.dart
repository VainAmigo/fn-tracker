import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Содержимое модального окна выбора языка.
class SettingsLocaleWidget extends StatelessWidget {
  const SettingsLocaleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentCode = localeProvider.currentLanguageCode;

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
            title: 'Language',
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
          Column(
            children: [
              ...AppLocalizationHelper.locales.asMap().entries.map((entry) {
                final index = entry.key;
                final locale = entry.value;
                final isFirst = index == 0;
                final isLast =
                    index == AppLocalizationHelper.locales.length - 1;
                final isSelected = currentCode == locale.languageCode;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : AppSizing.spaceBtwElementsExtra,
                  ),
                  child: ListTile(
                    onTap: () {
                      localeProvider.setLocale(locale);
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
                      Icons.language,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSecondary,
                    ),
                    title: Text(
                      AppLocalizationHelper.getName(locale.languageCode),
                      style: AppTextStyles.listTileTitle(
                        context,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      locale.languageCode.toUpperCase(),
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
}
