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
  MonthlyPeriod? _currentPeriod;

  void _onPeriodChange(DatePickerPeriod period) {
    context.read<BudgetCubit>().loadBudgetStats(
      startDayKey: period.startDayKey,
      endDayKey: period.endDayKey,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (period is MonthlyPeriod) {
        setState(() => _currentPeriod = period);
      }
    });
  }

  MonthlyPeriod _periodOrDefault() {
    if (_currentPeriod != null) return _currentPeriod!;
    final (:start, :end) = MonthRangeUtils.currentMonth();
    return MonthlyPeriod(year: start.year, month: Month.fromDateTime(start));
  }

  List<CategoryModel> _categoriesFrom(BudgetStatModel stats) =>
      stats.categorySpending.map((e) => e.category).toList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: MonthPickerScrollWidget(
        showModeTabs: false,
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
                            onCreatePressed: () => _showBudgetSheet(
                              categories: _categoriesFrom(stats),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BudgetSummaryCard(
                                stats: stats,
                                year: _periodOrDefault().year,
                                month: _periodOrDefault().month.value,
                                onTap: () => _showBudgetDetailsSheet(stats),
                              ),
                              const SizedBox(
                                height: AppSizing.spaceBtwElements,
                              ),
                              BudgetDonutStatWidget(
                                budgetAmount: stats.budgetAmount,
                                totalForPeriod: stats.totalForPeriod,
                                onBudgetTap: () =>
                                    _showBudgetDetailsSheet(stats),
                              ),
                              const SizedBox(
                                height: AppSizing.spaceBtwSections,
                              ),
                              BudgetsSpendingCategoriesListWidget(
                                categorySpending: stats.categorySpending,
                                onCategoryTap: (spending) =>
                                    _showCategoryActions(stats, spending),
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

  void _showBudgetDetailsSheet(BudgetStatModel stats) {
    final budget = stats.budget;
    if (budget == null) return;
    BudgetDetailsSheet.show(
      context,
      budget: budget,
      budgetAmount: stats.budgetAmount,
      onEdit: () => _showBudgetSheet(
        existingBudget: budget,
        initialAmount: stats.budgetAmount,
        categories: _categoriesFrom(stats),
      ),
    );
  }

  void _showBudgetSheet({
    BudgetModel? existingBudget,
    double? initialAmount,
    List<CategoryModel> categories = const [],
  }) {
    BudgetFormModalSheet.show(
      context,
      initialAmount: initialAmount ?? existingBudget?.amount,
      isEdit: existingBudget != null,
      saveLabel: context.l10n.save,
      title: existingBudget != null
          ? context.l10n.editBudget
          : context.l10n.createBudget,
      categories: categories,
      onSave: (amount, {required String startMonthKey}) {
        if (existingBudget != null) {
          context.read<BudgetCubit>().updateBudget(
            budget: BudgetModel(id: existingBudget.id, amount: amount),
            startMonthKey: startMonthKey,
          );
        } else {
          context.read<BudgetCubit>().createBudget(
            budget: BudgetModel(id: '', amount: amount),
            startMonthKey: startMonthKey,
          );
        }
      },
    );
  }

  void _showCategoryActions(
    BudgetStatModel stats,
    CategorySpending spending,
  ) {
    final categories = _categoriesFrom(stats);
    BudgetCategoryActionsSheet.show(
      context,
      spending: spending,
      budgetAmount: stats.budgetAmount,
      allCategories: categories,
      onSetLimit: () {
        BudgetCategoryLimitSheet.show(
          context,
          category: spending.category,
          budgetAmount: stats.budgetAmount,
          allCategories: categories,
          onSave: ({
            required CategoryLimitType limitType,
            required double? limitValue,
          }) async {
            final updated = spending.category.copyWith(
              limitType: limitType,
              limitValue: limitValue,
              clearLimitValue: limitType == CategoryLimitType.none,
            );
            await context.read<CategoriesCubit>().updateCategory(
              categoryModel: updated,
            );
            if (!mounted) return;
            final period = _periodOrDefault();
            await context.read<BudgetCubit>().loadBudgetStats(
              startDayKey: period.startDayKey,
              endDayKey: period.endDayKey,
            );
          },
        );
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
