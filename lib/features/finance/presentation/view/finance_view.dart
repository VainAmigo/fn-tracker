import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class FinanceView extends StatefulWidget {
  const FinanceView({super.key});

  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView> {
  FinanceTab _selectedTab = FinanceTab.budget;

  static const _tabBodies = [
    WalletBudgetTabWidget(),
    AccountsTabWidget(),
    CategoriesTabView(),
    ScheduledPaymentsTabView(),
  ];

  Future<void> _onRefresh() async {
    final (:start, :end) = MonthRangeUtils.currentMonth();
    await Future.wait([
      context.read<BudgetCubit>().loadBudgetStats(
        startDayKey: start.dayKey,
        endDayKey: end.dayKey,
      ),
      context.read<WalletCubit>().loadWallets(),
      context.read<GoalsCubit>().loadGoals(),
      context.read<CategoriesCubit>().loadCategories(),
      context.read<ScheduledPaymentsCubit>().loadPayments(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FinanceTabBarWidget(
                    title: context.l10n.yourFinancesAndSavings,
                    selectedTab: _selectedTab,
                    onChanged: (tab) =>
                        setState(() => _selectedTab = tab),
                  ),
                  const SizedBox(height: AppSizing.spaceBtwElements),
                  // Показываем только активный таб — высота экрана = высота его контента
                  _tabBodies[_selectedTab.index],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
