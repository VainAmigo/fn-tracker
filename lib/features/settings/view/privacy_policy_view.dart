import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.privacyPolicy)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabTitleWidget(
                title: 'Настройте вашу приватность',
                subtitle: 'Управление вашими данными и настройками приватности',
              ),
              const SizedBox(height: AppSizing.spaceBtwSections),
              TitledSection(
                title: 'Сохранение данных',
                children: [
                  _privacyCard(
                    context,
                    'Локально',
                    'Ваши данные хранятся только на вашем устройстве',
                    'Данные хранятся в памяти устройства при удалении приложения все данные будут патеряны',
                    true,
                    CardRadius.first,
                    () {},
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                  _privacyCard(
                    context,
                    'В облаке',
                    'Ваши данные хранятся в облаке и доступны с любого устройства',
                    'Все ваши данные хранятся в зашифрованном виде. Вы можете удалить их в любое время.',
                    false,
                    CardRadius.last,
                    () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
              Text(
                'При переключении между режимами хранения данных, данные не переносятся между режимами',
                style: AppTextStyles.text12w400(context),
              ),

              const SizedBox(height: AppSizing.spaceBtwSections),
              TitledSection(
                title: 'Удаление данных',
                children: [
                  PrimaryButton(
                    text: 'Удалить данные',
                    onPressed: () =>
                        showDeleteDataConfirmationModalSheet(context),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  PrimaryButton(
                    text: 'Удалить аккаунт',
                    onPressed: () =>
                        showDeleteAccountConfirmationDialog(context),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _privacyCard(
    BuildContext context,
    String title,
    String subtitle,
    String content,
    bool isSelected,
    CardRadius radius,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizing.defaultPadding,
        vertical: AppSizing.spaceBtwItems,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        borderRadius: borderRadiusFor(radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: AppTextStyles.text12w400(context).copyWith(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.text20w600(context).copyWith(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          if (content.isNotEmpty && isSelected) ...[
            const SizedBox(height: AppSizing.spaceBtwItems),
            Text(
              content,
              style: AppTextStyles.text14w400(context).copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<bool?> showDeleteAccountConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить аккаунт?'),
        content: Text('Вы уверены, что хотите удалить аккаунт?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<bool?> showDeleteDataConfirmationModalSheet(BuildContext context) {
    return AppBottomSheet.showFittedModalBottomSheet<bool>(
      context,
      child: Container(
        padding: const EdgeInsets.only(
          bottom: AppSizing.bottomPadding,
          left: AppSizing.defaultPadding,
          right: AppSizing.defaultPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModalSheetTitleWidget(title: 'Удаление данных'),
            const SizedBox(height: AppSizing.spaceBtwSections),

            /// selectable cards for deleting data
            /// which type of data to delete
            /// and select all data to delete
            PrimaryButton(
              text: 'Удалить',
              onPressed: () => Navigator.of(context).pop(true),
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ],
        ),
      ),
    );
  }
}
