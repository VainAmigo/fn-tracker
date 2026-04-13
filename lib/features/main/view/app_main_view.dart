import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/buttons/primary_button.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/features/main/services/android_analytics_widget_bridge.dart';
import 'package:fn_tracker/features/main/services/android_widget_bridge.dart';
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
  bool _fabMenuOpen = false;
  final quickActions = QuickActions();

  @override
  void initState() {
    super.initState();
    // Нельзя вызывать context.l10n / context.read в initState — только после кадра.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registerQuickActions();
      _runAutoCreate();
      AndroidWidgetBridge.init(onCategoryTap: _openAddExpenseFromWidget);
      _syncWidgetData(context);
    });
  }

  @override
  void dispose() {
    AndroidWidgetBridge.dispose();
    super.dispose();
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

  Future<void> _openAddExpenseFromWidget(String categoryId) async {
    if (!mounted) return;

    final categoriesCubit = context.read<CategoriesCubit>();
    CategoryModel? category = _findCategoryById(
      categoriesCubit.state,
      categoryId,
    );

    if (category == null) {
      await categoriesCubit.loadCategories();
      category = _findCategoryById(categoriesCubit.state, categoryId);
    }

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamed(AppRouter.addTransaction, arguments: category);
  }

  CategoryModel? _findCategoryById(CategoriesState state, String categoryId) {
    if (state is! CategoriesLoaded) return null;
    for (final item in state.categories) {
      if (item.categoryId == categoryId) return item;
    }
    return null;
  }

  Future<void> _syncWidgetData(BuildContext context) async {
    final categoriesState = context.read<CategoriesCubit>().state;
    if (categoriesState is! CategoriesLoaded) {
      await AndroidWidgetBridge.clear();
      return;
    }

    final allCategories = categoriesState.categories;
    final settings = context.read<QuickCategoriesSettingsCubit>().state;
    final transactionsState = context.read<TransactionsCubit>().state;
    final recentIds = <String>[];

    final txList = switch (transactionsState) {
      TransactionsLoaded() => transactionsState.transactions,
      TransactionDeleted() => transactionsState.transactions,
      _ => <TransactionModel>[],
    };

    for (final tx in txList) {
      final categoryId = tx.categoryId;
      if (categoryId == null ||
          categoryId.isEmpty ||
          recentIds.contains(categoryId)) {
        continue;
      }
      recentIds.add(categoryId);
      if (recentIds.length >= 12) break;
    }

    final defaultPinnedIds = _resolvePinnedIds(
      categories: allCategories,
      pinnedOrder: settings.pinnedOrder,
    );

    final (widgetPinnedIds, widgetRecentIds) = switch (settings.widgetSource) {
      WidgetCategoriesSource.system => switch (settings.displayMode) {
        QuickCategoriesDisplayMode.pinned => (defaultPinnedIds, <String>[]),
        QuickCategoriesDisplayMode.recent => (recentIds, <String>[]),
      },
      WidgetCategoriesSource.custom => (settings.customWidgetOrder, <String>[]),
    };

    await AndroidWidgetBridge.syncCategories(
      categories: allCategories,
      pinnedIds: widgetPinnedIds,
      recentIds: widgetRecentIds,
    );
  }

  Future<void> _syncAnalyticsWidgetData(BuildContext context) async {
    final state = context.read<AnalyticsCubit>().state;
    if (state is! AnalyticsLoaded) {
      await AndroidAnalyticsWidgetBridge.clear();
      return;
    }
    await AndroidAnalyticsWidgetBridge.syncAnalytics(
      data: state.data,
      periodLabel: _periodLabel(state.period),
    );
  }

  String _periodLabel(DatePickerPeriod period) {
    return switch (period) {
      MonthlyPeriod(:final year, :final month) => '${month.name} $year',
      YearlyPeriod(:final year) => '$year',
      WeeklyPeriod(:final start, :final end) =>
        '${start.day}.${start.month} - ${end.day}.${end.month}',
    };
  }

  List<String> _resolvePinnedIds({
    required List<CategoryModel> categories,
    required List<String> pinnedOrder,
  }) {
    final pinnedSet = <String>{
      for (final category in categories)
        if (category.isQuick == true) category.categoryId,
    };
    if (pinnedSet.isEmpty) return const [];

    final result = <String>[];
    for (final id in pinnedOrder) {
      if (pinnedSet.contains(id)) result.add(id);
    }
    for (final id in pinnedSet) {
      if (!result.contains(id)) result.add(id);
    }
    return result;
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
            _syncWidgetData(context);
          },
        ),
        BlocListener<CategoriesCubit, CategoriesState>(
          listener: (context, state) {
            _syncWidgetData(context);
          },
        ),
        BlocListener<
          QuickCategoriesSettingsCubit,
          QuickCategoriesSettingsState
        >(
          listener: (context, state) {
            _syncWidgetData(context);
          },
        ),
        BlocListener<AnalyticsCubit, AnalyticsState>(
          listener: (context, state) {
            _syncAnalyticsWidgetData(context);
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Scaffold(
            body: IndexedStack(index: _selectedIndex, children: _tabs),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Material(
              elevation: 0,
              color: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizing.borderRadius100),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (_fabMenuOpen) {
                    setState(() => _fabMenuOpen = false);
                  } else {
                    Navigator.of(context).pushNamed(AppRouter.addTransaction);
                  }
                },
                onLongPress: () => setState(() => _fabMenuOpen = true),
                child: SizedBox(
                  width: AppSizing.heightM,
                  height: AppSizing.heightM,
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: AppSizing.iconSizeM,
                  ),
                ),
              ),
            ),
            bottomNavigationBar: AppBottomNavWidget(
              destinations: mainBottomNavDestinations,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  _fabMenuOpen = false;
                });
              },
            ),
          ),
          if (_fabMenuOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _fabMenuOpen = false),
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 108,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryButton(
                    text: 'Add with voice',
                    onPressed: () {
                      setState(() => _fabMenuOpen = false);
                      Navigator.of(context).pushNamed(
                        AppRouter.aiLogic,
                        arguments: const AiLogicEntryArgs(
                          mode: AiLogicEntryMode.voice,
                        ),
                      );
                    },
                    icon: Icons.mic_rounded,
                    size: PrimaryButtonSize.small,
                    fullWidth: false,
                    rounded: true,
                  ),
                  PrimaryButton(
                    text: 'Add with file',
                    onPressed: () {
                      setState(() => _fabMenuOpen = false);
                      Navigator.of(context).pushNamed(
                        AppRouter.aiLogic,
                        arguments: const AiLogicEntryArgs(
                          mode: AiLogicEntryMode.attachment,
                        ),
                      );
                    },
                    icon: Icons.attach_file_rounded,
                    size: PrimaryButtonSize.small,
                    fullWidth: false,
                    rounded: true,
                  ),
                  PrimaryButton(
                    text: 'Add manually',
                    onPressed: () {
                      setState(() => _fabMenuOpen = false);
                      Navigator.of(context).pushNamed(AppRouter.addTransaction);
                    },
                    icon: Icons.edit_note_rounded,
                    size: PrimaryButtonSize.small,
                    fullWidth: false,
                    rounded: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
