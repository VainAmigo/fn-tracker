import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/core/core.dart';

class AppMainView extends StatefulWidget {
  const AppMainView({super.key});

  @override
  State<AppMainView> createState() => _AppMainViewState();
}

class _AppMainViewState extends State<AppMainView> {
  int _selectedIndex = 0;

  static const _tabs = [
    HomeView(),
    WalletView(),
    AnalyticsView(),
    SettingsView(),
  ];

  void _onDataUpdated(BuildContext context) {
    final (:start, :end) = MonthRangeUtils.currentMonth();
    context.read<HomeCubit>().getHomePageStats(
      startDayKey: start.dayKey,
      endDayKey: end.dayKey,
    );
    context.read<AnalyticsCubit>().loadAnalytics();
    context.read<WalletCubit>().loadWallets();
    context.read<GoalsCubit>().loadGoals();
    context.read<BudgetCubit>().loadBudgetStats(periodKey: start.periodKey);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddTransactionCubit, AddTransactionState>(
          listener: (context, state) {
            if (state is AddTransactionSuccess) {
              context.read<TransactionsCubit>().addTransactionLocally(
                state.createdTransaction,
              );
              _onDataUpdated(context);
            }
          },
        ),
        BlocListener<TransactionsCubit, TransactionsState>(
          listener: (context, state) {
            if (state is TransactionDeleted) {
              _onDataUpdated(context);
            }
          },
        ),
      ],
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _tabs),
        bottomNavigationBar: AppBottomNavWidget(
          destinations: mainBottomNavDestinations,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
