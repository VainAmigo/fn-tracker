import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';

class AppMainView extends StatefulWidget {
  const AppMainView({super.key});

  @override
  State<AppMainView> createState() => _AppMainViewState();
}

class _AppMainViewState extends State<AppMainView> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAutoCreate());
  }

  Future<void> _runAutoCreate() async {
    final walletRepo = context.read<WalletCubit>().walletRepo;
    final transactionsRepo = context.read<TransactionsCubit>().transactionsRepo;
    final service = ScheduledPaymentAutoCreateService(
      walletRepo: walletRepo,
      transactionsRepo: transactionsRepo,
    );
    await service.checkAndCreateForToday();
    if (mounted) {
      context.read<TransactionsCubit>().loadTransactionsByPeriod(
        TransactionPeriod.month,
      );
      _onDataUpdated(context);
    }
  }

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
    context.read<BudgetCubit>().loadBudgetStats(
      startDayKey: start.dayKey,
      endDayKey: end.dayKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddTransactionCubit, AddTransactionState>(
          listener: (context, state) {
            if (state is AddTransactionSuccess) {
              context.read<TransactionsCubit>().addTransactionsLocally(
                state.createdTransactions,
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
        BlocListener<GoalsCubit, GoalsState>(
          listener: (context, state) {
            if (state is GoalsCompleteGoalSuccess) {
              context.read<TransactionsCubit>().addTransactionsLocally(
                [state.transaction],
              );
              _onDataUpdated(context);
            }
          },
        ),
      ],
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _tabs),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.borderRadius100),
          ),
          elevation: 0,
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRouter.addTransaction),
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
            size: AppSizing.iconSizeM,
          ),
        ),
        bottomNavigationBar: AppBottomNavWidget(
          destinations: mainBottomNavDestinations,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}
