import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:fn_tracker/features/finance/data/models/scheduled_payment_model.dart';

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

  bool get _isUrgent {
    final today = DateTime.now();
    final d = payment.nextDate;
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      return true;
    }
    final tomorrow = today.add(const Duration(days: 1));
    return d.year == tomorrow.year &&
        d.month == tomorrow.month &&
        d.day == tomorrow.day;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shade = findShadeById(payment.colorId);
    final iconData = findIconById(payment.iconId);
    final color = shade?.color ?? colorScheme.primary;
    final borderColor =
        _isUrgent ? colorScheme.primary.withValues(alpha: 0.5) : null;

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
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
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
                        _formatFrequency(payment, context),
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
                // Цветовая индикация срочности — подсветка карточки, если платёж сегодня/завтра (например, оранжевый/красный акцент).
                Text(
                  '${context.l10n.nextPayment}: ${payment.nextDate.formatDotDate}',
                  style: AppTextStyles.text12w400(context),
                ),
                const Spacer(),
                if (payment.isPaused)
                  Text(
                    context.l10n.paused,
                    style: AppTextStyles.text12w400(context).copyWith(
                      color: colorScheme.onSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFrequency(ScheduledPaymentModel p, dynamic context) {
    switch (p.frequency) {
      case ScheduledPaymentFrequency.oneTime:
        return context.l10n.once;
      case ScheduledPaymentFrequency.monthly:
        return context.l10n.monthly;
      case ScheduledPaymentFrequency.yearly:
        return context.l10n.yearly;
    }
  }
}
