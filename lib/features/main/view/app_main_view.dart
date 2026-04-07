import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';
import 'package:quick_actions/quick_actions.dart';

class AppMainView extends StatefulWidget {
  const AppMainView({super.key});

  @override
  State<AppMainView> createState() => _AppMainViewState();
}

class _AppMainViewState extends State<AppMainView> {
  int _selectedIndex = 0;
  final quickActions = QuickActions();

  @override
  void initState() {
    super.initState();
    // Нельзя вызывать context.l10n / context.read в initState — только после кадра.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registerQuickActions();
      _runAutoCreate();
    });
  }

  void _registerQuickActions() {
    if (!mounted) return;
    quickActions.setShortcutItems([
      ShortcutItem(
        type: 'expense',
        localizedTitle: _getShortcutTitle('expense', context),
        icon: 'expense_icon',
      ),
      ShortcutItem(
        type: 'income',
        localizedTitle: _getShortcutTitle('income', context),
        icon: 'income_icon',
      ),
    ]);

    quickActions.initialize((String shortcutType) {
      if (!context.mounted) return;
      switch (shortcutType) {
        case 'expense':
          Navigator.of(context).pushNamed(
            AppRouter.addTransaction,
            arguments: TransactionType.expense,
          );
          return;
        case 'income':
          Navigator.of(context).pushNamed(
            AppRouter.addTransaction,
            arguments: TransactionType.income,
          );
          return;
        default:
          return;
      }
    });
  }

  String _getShortcutTitle(String shortcutType, BuildContext context) {
    return switch (shortcutType) {
      'expense' => context.l10n.expense,
      'income' => context.l10n.income,
      _ => '',
    };
  }

  Future<void> _runAutoCreate() async {
    if (!mounted) return;
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
              context.read<TransactionsCubit>().addTransactionsLocally([
                state.transaction,
              ]);
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
