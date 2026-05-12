import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Карточка бюджета за текущий месяц (как на вкладке «Бюджет»).
class HomeBudgetSummaryWidget extends StatelessWidget {
  const HomeBudgetSummaryWidget({super.key});

  static DatePickerPeriod _monthPeriod() {
    final range = MonthRangeUtils.currentMonth();
    final start = range.start;
    return MonthlyPeriod(year: start.year, month: Month.fromDateTime(start));
  }

  void _showCreateBudget(BuildContext context) {
    BudgetFormModalSheet.show(
      context,
      saveLabel: context.l10n.save,
      title: context.l10n.createBudget,
      onSave: (amount, {String? effectiveDayKey, bool replaceAll = false}) {
        context.read<BudgetCubit>().createBudget(
          budget: BudgetModel(id: '', amount: amount),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        return switch (state) {
          BudgetInitial() || BudgetLoading() => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizing.spaceBtwSections),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          BudgetError() => const SizedBox.shrink(),
          BudgetStatsLoaded(:final stats, :final history) =>
            stats.budget == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EmptyCardWidget(
                        title: context.l10n.noBudgetFound,
                      ),
                      const SizedBox(height: AppSizing.spaceBtwItems),
                      PrimaryButton(
                        text: context.l10n.createBudget,
                        size: PrimaryButtonSize.xSmall,
                        rounded: true,
                        fullWidth: false,
                        backgroundColor: Colors.transparent,
                        foregroundColor:
                            Theme.of(context).colorScheme.primary,
                        onPressed: () => _showCreateBudget(context),
                      ),
                    ],
                  )
                : BudgetSummaryCard(
                    budget: stats.budget!,
                    period: _monthPeriod(),
                    totalForPeriod: stats.totalForPeriod,
                    history: history,
                    transactions: stats.transactions,
                  ),
        };
      },
    );
  }
}
