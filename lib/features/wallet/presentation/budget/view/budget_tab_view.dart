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
  DatePickerPeriod? _currentPeriod;

  void _onPeriodChange(DatePickerPeriod period) {
    context.read<BudgetCubit>().loadBudgetStats(
      startDayKey: period.startDayKey,
      endDayKey: period.endDayKey,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _currentPeriod = period);
    });
  }

  DatePickerPeriod _periodOrDefault() {
    if (_currentPeriod != null) return _currentPeriod!;
    final (:start, :end) = MonthRangeUtils.currentMonth();
    return MonthlyPeriod(
      year: start.year,
      month: Month.fromDateTime(start),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>().currency;

    return SingleChildScrollView(
      child: MonthPickerScrollWidget(
        onPeriodChange: _onPeriodChange,
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
                                period: _periodOrDefault(),
                                totalForPeriod: stats.totalForPeriod,
                                currency: currency,
                                onBudgetTap: () => _showBudgetDetailsSheet(
                                  budget: stats.budget!,
                                  totalForPeriod: stats.totalForPeriod,
                                  currency: currency,
                                ),
                              ),
                              const SizedBox(
                                height: AppSizing.spaceBtwItems,
                              ),
                              BudgetTipsWidget(
                                budget: stats.budget!,
                                period: _periodOrDefault(),
                                totalForPeriod: stats.totalForPeriod,
                                currency: currency,
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
            const SizedBox(height: AppSizing.bottomPadding),
          ],
        ),
      ),
    );
  }

  void _showBudgetDetailsSheet({
    required BudgetModel budget,
    required double totalForPeriod,
    required Currency currency,
  }) {
    final period = _periodOrDefault();
    BudgetDetailsSheet.show(
      context,
      budget: budget,
      totalForPeriod: totalForPeriod,
      currency: currency,
      period: period,
      onEdit: () => _showBudgetSheet(
        currency: currency,
        existingBudget: budget,
      ),
    );
  }

  void _showBudgetSheet({
    required Currency currency,
    BudgetModel? existingBudget,
  }) {
    BudgetFormModalSheet.show(
      context,
      initialAmount: existingBudget?.amount,
      initialType: existingBudget?.type ?? BudgetType.monthly,
      saveLabel: 'Save',
      title: existingBudget != null ? 'Edit budget' : 'Create budget',
      onSave: (amount, type) {
        if (existingBudget != null) {
          context.read<BudgetCubit>().updateBudget(
            budget: BudgetModel(
              id: existingBudget.id,
              amount: amount,
              type: type,
            ),
          );
        } else {
          context.read<BudgetCubit>().createBudget(
            budget: BudgetModel(
              id: '',
              amount: amount,
              type: type,
            ),
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
