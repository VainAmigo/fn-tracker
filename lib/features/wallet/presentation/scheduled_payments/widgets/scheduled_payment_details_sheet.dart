import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'scheduled_payment_card.dart';

class ScheduledPaymentDetailsSheet extends StatelessWidget {
  const ScheduledPaymentDetailsSheet({
    super.key,
    required this.payment,
    required this.onEdit,
    this.onPause,
    this.onDelete,
    this.onCreatePaymentNow,
  });

  final ScheduledPaymentModel payment;
  final VoidCallback onEdit;
  final VoidCallback? onPause;
  final VoidCallback? onDelete;
  final VoidCallback? onCreatePaymentNow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(
            title: 'Плановый платёж',
            action: PrimaryButton(
              text: 'Редактировать',
              onPressed: () {
                Navigator.of(context).pop();
                onEdit();
              },
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          ScheduledPaymentCard(payment: payment),
          const SizedBox(height: AppSizing.spaceBtwElements),
          _InfoRow(
            label: 'Автосоздание транзакции',
            value: payment.autoCreateTransaction ? 'Да' : 'Нет',
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: AppSizing.spaceBtwItemsExtra,
            children: [
              PrimaryButton(
                text: 'Приостановить',
                icon: Icons.pause,
                iconOnly: true,
                onPressed: onPause,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
                foregroundColor: colorScheme.primary,
                size: PrimaryButtonSize.large,
                paddingStyle: PrimaryButtonPaddingStyle.slim,
                rounded: true,
                fullWidth: false,
              ),
              PrimaryButton(
                text: 'Удалить',
                onPressed: onDelete,
                size: PrimaryButtonSize.large,
                paddingStyle: PrimaryButtonPaddingStyle.slim,
                backgroundColor: colorScheme.error.withValues(alpha: 0.3),
                foregroundColor: colorScheme.error,
                icon: Icons.delete,
                iconOnly: true,
                rounded: true,
                fullWidth: false,
              ),
              Expanded(
                child: PrimaryButton(
                  text: payment.type == ScheduledPaymentType.regularIncome
                      ? 'Зачислить'
                      : 'Оплатить',
                  size: PrimaryButtonSize.large,
                  onPressed: onCreatePaymentNow,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizing.spaceBtwItems),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.text14w400(context)),
          Text(value, style: AppTextStyles.text14w400(context)),
        ],
      ),
    );
  }
}
