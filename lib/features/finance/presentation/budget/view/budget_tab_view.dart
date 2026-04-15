import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
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
    return MonthlyPeriod(year: start.year, month: Month.fromDateTime(start));
  }

  @override
  Widget build(BuildContext context) {
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
                  BudgetStatsLoaded(:final stats, :final history) =>
                    stats.budget == null
                        ? _NoBudgetPlaceholder(
                            onCreatePressed: () => _showBudgetSheet(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BudgetSummaryCard(
                                budget: stats.budget!,
                                period: _periodOrDefault(),
                                totalForPeriod: stats.totalForPeriod,
                                history: history,
                                transactions: stats.transactions,
                              ),
                              const SizedBox(
                                height: AppSizing.spaceBtwElements,
                              ),
                              BudgetDonutStatWidget(
                                budget: stats.budget!,
                                period: _periodOrDefault(),
                                totalForPeriod: stats.totalForPeriod,
                                history: history,
                                onBudgetTap: () => _showBudgetDetailsSheet(
                                  budget: stats.budget!,
                                  totalForPeriod: stats.totalForPeriod,
                                  history: history,
                                ),
                              ),
                              const SizedBox(
                                height: AppSizing.spaceBtwSections,
                              ),
                              BudgetsSpendingCategoriesListWidget(
                                categorySpending: stats.categorySpending,
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
    required List<BudgetHistoryEntry> history,
  }) {
    final period = _periodOrDefault();
    BudgetDetailsSheet.show(
      context,
      budget: budget,
      totalForPeriod: totalForPeriod,
      period: period,
      history: history,
      onEdit: () => _showBudgetSheet(existingBudget: budget),
    );
  }

  void _showBudgetSheet({BudgetModel? existingBudget}) {
    BudgetFormModalSheet.show(
      context,
      initialAmount: existingBudget?.amount,
      isEdit: existingBudget != null,
      saveLabel: context.l10n.save,
      title: existingBudget != null ? context.l10n.editBudget : context.l10n.createBudget,
      onSave: (amount, {String? effectiveDayKey, bool replaceAll = false}) {
        if (existingBudget != null) {
          context.read<BudgetCubit>().updateBudget(
            budget: BudgetModel(id: existingBudget.id, amount: amount),
            effectiveDayKey: effectiveDayKey,
            replaceAll: replaceAll,
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
          context.l10n.noBudgetFound,
          style: AppTextStyles.text16w400(context),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        PrimaryButton(
          text: context.l10n.createBudget,
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          context.l10n.somethingWentWrong,
          style: AppTextStyles.text16w400(context),
        ),
        const SizedBox(height: AppSizing.spaceBtwItems),
        PrimaryButton(
          text: context.l10n.retry,
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
