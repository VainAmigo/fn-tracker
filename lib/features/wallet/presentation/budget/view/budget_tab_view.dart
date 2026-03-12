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

  void _showBudgetSheet({
    required Currency currency,
    BudgetModel? existingBudget,
  }) {
    AmountFormModalSheet.show(
      context,
      initialAmount: existingBudget?.amount,
      saveLabel: 'Save',
      onSave: (amount) {
        if (existingBudget != null) {
          context.read<BudgetCubit>().updateBudget(
                budget: BudgetModel(id: existingBudget.id, amount: amount),
              );
        } else {
          context.read<BudgetCubit>().createBudget(
                budget: BudgetModel(id: '', amount: amount),
              );
        }
      },
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
