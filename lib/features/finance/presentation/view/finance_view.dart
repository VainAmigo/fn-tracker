import 'dart:async';

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
  List<int> _visualOrder = List<int>.from(FinanceTabOrderStorage.defaultOrder);

  static const _tabBodies = [
    WalletBudgetTabWidget(),
    AccountsTabWidget(),
    TransactionsListView(embedded: true),
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
      context.read<TransactionsCubit>().loadTransactionsByPeriod(
        TransactionPeriod.month,
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadTabOrder());
  }

  Future<void> _loadTabOrder() async {
    final loaded = await FinanceTabOrderStorage.load();
    if (!mounted) return;
    setState(() {
      _visualOrder = loaded;
      _selectedTab = FinanceTab.values[loaded.first];
    });
  }

  void _openTabOrderSettings() {
    FinanceTabOrderSettingsSheet.show(
      context,
      initialOrder: _visualOrder,
      onOrderChanged: (order) {
        setState(() => _visualOrder = order);
      },
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FinanceTabBarWidget(
                  title: context.l10n.yourFinancesAndSavings,
                  visualOrder: _visualOrder,
                  selectedTab: _selectedTab,
                  onChanged: (tab) =>
                      setState(() => _selectedTab = tab),
                  onTabOrderSettingsPressed: _openTabOrderSettings,
                ),
                const SizedBox(height: AppSizing.spaceBtwElements),
                Expanded(
                  child: _tabBodies[_selectedTab.index],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
