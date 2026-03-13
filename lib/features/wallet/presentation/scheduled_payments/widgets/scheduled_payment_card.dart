import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:fn_tracker/features/wallet/data/models/scheduled_payment_model.dart';

/// Карточка планового платежа.
/// Icon, Name, Frequency, Next payment, Amount.
class ScheduledPaymentCard extends StatelessWidget {
  const ScheduledPaymentCard({
    super.key,
    required this.payment,
    this.onTap,
    this.radius = CardRadius.single,
  });

  final ScheduledPaymentModel payment;
  final VoidCallback? onTap;
  final CardRadius radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shade = findShadeById(payment.colorId);
    final iconData = findIconById(payment.iconId);
    final color = shade?.color ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizing.defaultPadding),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: borderRadiusFor(
            radius,
            mainRadius: AppSizing.borderRadius16,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: AppSizing.heightS,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(
                      AppSizing.borderRadius8,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Icon(
                      iconData?.icon ?? Icons.payments,
                      size: AppSizing.iconSizeS,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizing.spaceBtwElements),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.name,
                        style: AppTextStyles.text16w400(context),
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                      Text(
                        _formatFrequency(payment),
                        style: AppTextStyles.text12w400(context),
                      ),
                    ],
                  ),
                ),
                Text(
                  AmountFormatter.format(payment.amount),
                  style: AppTextStyles.text16w400(context),
                ),
              ],
            ),
            const SizedBox(height: AppSizing.spaceBtwItems),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: AppSizing.iconSizeXS,
                  color: colorScheme.onSecondary,
                ),
                const SizedBox(width: AppSizing.spaceBtwItemsExtra),
                Text(
                  'Следующий платёж: ${payment.nextDate.formatDotDate}',
                  style: AppTextStyles.text12w400(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFrequency(ScheduledPaymentModel p) {
    switch (p.frequency) {
      case ScheduledPaymentFrequency.once:
        return 'Один раз';
      case ScheduledPaymentFrequency.daily:
        return 'Ежедневно';
      case ScheduledPaymentFrequency.weekly:
        return 'Еженедельно';
      case ScheduledPaymentFrequency.monthly:
        return 'Ежемесячно';
      case ScheduledPaymentFrequency.yearly:
        return 'Ежегодно';
    }
  }
}
