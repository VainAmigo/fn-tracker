import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class BudgetStatWidget extends StatefulWidget {
  const BudgetStatWidget({super.key});

  @override
  State<BudgetStatWidget> createState() => _BudgetStatWidgetState();
}

class _BudgetStatWidgetState extends State<BudgetStatWidget> {
  late Future<double> _totalFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final (:start, :end) = MonthRangeUtils.currentMonth();
    _totalFuture = context
        .read<TransactionsPeriodTotalCubit>()
        .transactionsRepo
        .getTotalForPeriod(start, end);

    final budgetState = context.read<BudgetCubit>().state;
    if (budgetState is BudgetInitial) {
      context.read<BudgetCubit>().getBudget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyProvider>().currency;
    final formatter = CurrencyFormatter(currency);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<BudgetCubit, BudgetState>(
      buildWhen: (prev, curr) => curr is BudgetLoaded || curr is BudgetNotFound,
      builder: (context, budgetState) {
        if (budgetState is! BudgetLoaded) return const SizedBox.shrink();

        final budget = budgetState.budget;

        return FutureBuilder<double>(
          future: _totalFuture,
          builder: (context, snapshot) {
            final spent = snapshot.data ?? 0.0;
            final exceeded = spent > budget.amount;

            final remainingPercent =
                ((budget.amount - spent) / budget.amount * 100)
                    .clamp(0, 100)
                    .toStringAsFixed(0);

            final barSegments = exceeded
                ? [
                    BarChartSegment(
                      value: budget.amount,
                      color: colorScheme.onSecondary,
                    ),
                    BarChartSegment(
                      value: spent - budget.amount,
                      color: colorScheme.error,
                    ),
                  ]
                : [
                    BarChartSegment(value: spent, color: colorScheme.primary),
                    BarChartSegment(
                      value: budget.amount - spent,
                      color: colorScheme.onSecondary,
                    ),
                  ];

            final accentColor = exceeded
                ? colorScheme.error
                : colorScheme.primary;

            return Container(
              padding: const EdgeInsets.all(AppSizing.defaultPadding),
              margin: const EdgeInsets.only(bottom: AppSizing.spaceBtwSections),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Monthly Budget',
                    style: AppTextStyles.text20w600(context),
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                  Text(
                    formatter.format(spent),
                    style: AppTextStyles.text20w600(
                      context,
                    ).copyWith(color: accentColor),
                  ),
                  const SizedBox(height: AppSizing.spaceBtwItems),
                  SegmentedBar(
                    height: 8,
                    gap: 3,
                    segments: barSegments,
                    trackColor: colorScheme.secondary,
                  ),
                  const SizedBox(height: AppSizing.spaceBtwElements),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${formatter.format(budget.amount)} / ${formatter.format(spent)}',
                        style: AppTextStyles.listTileSubtitle(context).copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        exceeded
                            ? 'Budget exceeded'
                            : '$remainingPercent% remaining',
                        style: AppTextStyles.listTileSubtitle(
                          context,
                        ).copyWith(color: accentColor),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
