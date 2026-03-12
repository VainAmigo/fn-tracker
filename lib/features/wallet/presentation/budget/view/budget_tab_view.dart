import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletBudgetTabWidget extends StatefulWidget {
  const WalletBudgetTabWidget({super.key});

  @override
  State<WalletBudgetTabWidget> createState() => _WalletBudgetTabWidgetState();
}

class _WalletBudgetTabWidgetState extends State<WalletBudgetTabWidget> {
  @override
  void initState() {
    super.initState();
    final (:start, :end) = MonthRangeUtils.currentMonth();
    context.read<BudgetCubit>().loadBudgetStats(
      startDayKey: start.dayKey,
      endDayKey: end.dayKey,
    );
  }

  void _onDateChange(Month month, int year) {
    final (:start, :end) = MonthRangeUtils.rangeFor(year, month);
    context.read<BudgetCubit>().loadBudgetStats(
      startDayKey: start.dayKey,
      endDayKey: end.dayKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;

    return SingleChildScrollView(
      child: MonthPickerScrollWidget(
        onDateChange: _onDateChange,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizing.spaceBtwSections),
            BlocBuilder<BudgetCubit, BudgetState>(
              builder: (context, state) {
                return switch (state) {
                  BudgetInitial() || BudgetLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  BudgetStatsLoaded(:final stats) =>
                    stats.budget == null
                        ? _NoBudgetPlaceholder(
                            onCreatePressed: () =>
                                _showBudgetSheet(currency: currency),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BudgetDonutStatWidget(
                                budget: stats.budget!,
                                totalForPeriod: stats.totalForPeriod,
                                currency: currency,
                                onEditBudgetPressed: () => _showBudgetSheet(
                                  currency: currency,
                                  existingBudget: stats.budget,
                                ),
                              ),
                              const SizedBox(
                                height: AppSizing.spaceBtwSections,
                              ),
                              BudgetsSpendingCategoriesListWidget(
                                categorySpending: stats.categorySpending,
                                currency: currency,
                              ),
                            ],
                          ),
                  BudgetError() => _BudgetErrorPlaceholder(
                    onRetry: () {
                      final (:start, :end) = MonthRangeUtils.currentMonth();
                      context.read<BudgetCubit>().loadBudgetStats(
                        startDayKey: start.dayKey,
                        endDayKey: end.dayKey,
                      );
                    },
                  ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmountForInput(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.truncate().toString();
    }
    return amount.toString();
  }

  void _showBudgetSheet({
    required Currency currency,
    BudgetModel? existingBudget,
  }) {
    String? newAmount = existingBudget != null
        ? _formatAmountForInput(existingBudget.amount)
        : null;

    AppBottomSheet.showFittedModalBottomSheet(
      context,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.defaultPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AmountInputWidget(
              initialAmount: existingBudget != null
                  ? _formatAmountForInput(existingBudget.amount)
                  : '',
              currency: currency,
              onAmountChanged: (amount) => newAmount = amount,
            ),

            if (existingBudget != null) ...[
              PrimaryButton(
                text: 'Delete Budget',
                onPressed: () {
                  context.read<BudgetCubit>().deleteBudget(existingBudget.id);
                  Navigator.of(context).pop();
                },
                size: PrimaryButtonSize.xSmall,
                rounded: true,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.3),
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
            ],

            PrimaryButton(
              text: 'Save',
              onPressed: () {
                final parsed = double.tryParse(newAmount ?? '');
                if (parsed == null || parsed <= 0) return;

                if (existingBudget != null) {
                  final updated = BudgetModel(
                    id: existingBudget.id,
                    amount: parsed,
                  );
                  context.read<BudgetCubit>().updateBudget(budget: updated);
                } else {
                  final created = BudgetModel(id: '', amount: parsed);
                  context.read<BudgetCubit>().createBudget(budget: created);
                }
                Navigator.of(context).pop();
              },
              size: PrimaryButtonSize.medium,
            ),
            const SizedBox(height: AppSizing.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}

class _NoBudgetPlaceholder extends StatelessWidget {
  const _NoBudgetPlaceholder({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No budget found. Please create one.',
          style: AppTextStyles.text16w400(context),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        PrimaryButton(
          text: 'Create budget',
          size: PrimaryButtonSize.xSmall,
          rounded: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
          onPressed: onCreatePressed,
        ),
      ],
    );
  }
}

class _BudgetErrorPlaceholder extends StatelessWidget {
  const _BudgetErrorPlaceholder({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Something went wrong. Please try again later.',
          style: AppTextStyles.text16w400(context),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        PrimaryButton(
          text: 'Retry',
          size: PrimaryButtonSize.xSmall,
          rounded: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
