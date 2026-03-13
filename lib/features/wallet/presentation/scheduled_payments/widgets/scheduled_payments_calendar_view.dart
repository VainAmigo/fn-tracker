import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:fn_tracker/features/wallet/data/models/scheduled_payment_model.dart';

/// Календарь за месяц с платежами по дням.
/// Месяц и год задаются извне (через [selectedYear] и [selectedMonth]).
class ScheduledPaymentsCalendarView extends StatelessWidget {
  const ScheduledPaymentsCalendarView({
    super.key,
    required this.payments,
    required this.selectedYear,
    required this.selectedMonth,
  });

  final List<ScheduledPaymentModel> payments;
  final int selectedYear;
  final int selectedMonth;

  Map<int, List<ScheduledPaymentModel>> _getPaymentsByDay() {
    final result = <int, List<ScheduledPaymentModel>>{};
    for (final p in payments) {
      final day = p.nextDate.day;
      final month = p.nextDate.month;
      final year = p.nextDate.year;
      if (month == selectedMonth && year == selectedYear) {
        result.putIfAbsent(day, () => []).add(p);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final paymentsByDay = _getPaymentsByDay();
    final firstDay = DateTime(selectedYear, selectedMonth, 1);
    final lastDay = DateTime(selectedYear, selectedMonth + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWeekdayHeaders(context),
        const SizedBox(height: AppSizing.spaceBtwItems),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.2,
          ),
          itemCount: daysInMonth + startWeekday,
          itemBuilder: (context, index) {
            if (index < startWeekday) {
              return const SizedBox.shrink();
            }
            final day = index - startWeekday + 1;
            final dayPayments = paymentsByDay[day] ?? [];
            final hasPayments = dayPayments.isNotEmpty;
            final isToday = day == DateTime.now().day &&
                selectedMonth == DateTime.now().month &&
                selectedYear == DateTime.now().year;

            return Container(
              decoration: BoxDecoration(
                color: hasPayments
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : (isToday
                        ? colorScheme.primary.withValues(alpha: 0.08)
                        : colorScheme.secondary),
                borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: AppTextStyles.text14w400(context).copyWith(
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (hasPayments)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          dayPayments.length.clamp(0, 3),
                          (i) => Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: findShadeById(dayPayments[i].colorId)
                                      ?.color ??
                                  colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    return Row(
      children: Weekday.values
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d.localizedShortName(context),
                  style: AppTextStyles.text12w400(context),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
