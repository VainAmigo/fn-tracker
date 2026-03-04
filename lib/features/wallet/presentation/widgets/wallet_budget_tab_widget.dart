import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletBudgetTabWidget extends StatelessWidget {
  const WalletBudgetTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthPickerScrollWidget(
            onDateChange: (Month month, int year) {
              // MonthRangeUtils.rangeFor(year, month) → (start, end) выбранного месяца
              print('month: $month, year: $year');
              print(MonthRangeUtils.rangeFor(year, month));
            },
          ),
          const SizedBox(height: AppSizing.spaceBtwSections),
        ],
      ),
    );
  }
}
