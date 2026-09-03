import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/buttons/primary_button.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/features/main/services/android_analytics_widget_bridge.dart';
import 'package:fn_tracker/features/main/services/android_wallet_widget_bridge.dart';
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

class _AppMainViewState extends State<AppMainView> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _fabMenuOpen = false;
  final quickActions = QuickActions();
  CurrencyProvider? _currencyProvider;
  ThemeProvider? _themeProvider;
  LocaleProvider? _localeProvider;

  static const _fabAnimDuration = Duration(milliseconds: 280);
  static const _fabMenuAnimDuration = Duration(milliseconds: 260);
  static const _fabAnimCurve = Curves.easeOutCubic;
  static const _fabRotationCurve = Curves.easeOutBack;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Нельзя вызывать context.l10n / context.read в initState — только после кадра.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _registerQuickActions();
      _runAutoCreate();
      AndroidWidgetBridge.init(onCategoryTap: _openAddExpenseFromWidget);
      _syncWidgetData(context);
      _syncWalletWidgetData(context);
      _currencyProvider = context.read<CurrencyProvider>()
        ..addListener(_onThemeCurrencyOrLocaleChanged);
      _themeProvider = context.read<ThemeProvider>()
        ..addListener(_onThemeCurrencyOrLocaleChanged);
      _localeProvider = context.read<LocaleProvider>()
        ..addListener(_onThemeCurrencyOrLocaleChanged);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _currencyProvider?.removeListener(_onThemeCurrencyOrLocaleChanged);
    _themeProvider?.removeListener(_onThemeCurrencyOrLocaleChanged);
    _localeProvider?.removeListener(_onThemeCurrencyOrLocaleChanged);
    AndroidWidgetBridge.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _scheduleHomeWidgetsSync();
  }

  void _onThemeCurrencyOrLocaleChanged() {
    _scheduleHomeWidgetsSync();
  }

  void _scheduleHomeWidgetsSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncWidgetData(context);
      _syncWalletWidgetData(context);
    });
  }

  void _registerQuickActions() {
    if (!mounted) return;
    quickActions.setShortcutItems([
      ShortcutItem(
        type: 'expense',
        localizedTitle: context.l10n.expense,
        icon: 'expense_icon',
      ),
      ShortcutItem(
        type: 'income',
        localizedTitle: context.l10n.income,
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

  Future<void> _runAutoCreate() async {
    if (!mounted) return;
    final financeRepo = context.read<WalletCubit>().financeRepo;
    final transactionsRepo = context.read<TransactionsCubit>().transactionsRepo;
    final service = ScheduledPaymentAutoCreateService(
      financeRepo: financeRepo,
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
    FinanceView(),
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
    final colorScheme = Theme.of(context).colorScheme;
    final emptyLabel = context.l10n.noCategories;
    final categoriesState = context.read<CategoriesCubit>().state;
    if (categoriesState is! CategoriesLoaded) {
      await AndroidWidgetBridge.clear(
        colorScheme: colorScheme,
        emptyLabel: emptyLabel,
      );
      return;
    }

    final displayCategories = _categoriesForHomeWidget(
      categories: categoriesState.categories,
      settings: context.read<QuickCategoriesSettingsCubit>().state,
      transactionsState: context.read<TransactionsCubit>().state,
    );

    await AndroidWidgetBridge.syncCategories(
      categories: displayCategories,
      colorScheme: colorScheme,
      emptyLabel: emptyLabel,
    );
  }

  List<CategoryModel> _categoriesForHomeWidget({
    required List<CategoryModel> categories,
    required QuickCategoriesSettingsState settings,
    required TransactionsState transactionsState,
  }) {
    return switch (settings.widgetSource) {
      WidgetCategoriesSource.custom => _categoriesByOrder(
        categories,
        settings.customWidgetOrder,
      ),
      WidgetCategoriesSource.system => switch (settings.displayMode) {
        QuickCategoriesDisplayMode.pinned => _resolvePinnedCategories(
          categories: categories,
          pinnedOrder: settings.pinnedOrder,
        ),
        QuickCategoriesDisplayMode.recent => _recentCategories(
          categories: categories,
          transactionsState: transactionsState,
        ),
      },
    };
  }

  List<CategoryModel> _categoriesByOrder(
    List<CategoryModel> categories,
    List<String> order,
  ) {
    if (order.isEmpty) return const [];
    final byId = {
      for (final category in categories) category.categoryId: category,
    };
    return [
      for (final id in order)
        if (byId[id] != null) byId[id]!,
    ];
  }

  List<CategoryModel> _resolvePinnedCategories({
    required List<CategoryModel> categories,
    required List<String> pinnedOrder,
  }) {
    return _categoriesByOrder(
      categories,
      _resolvePinnedIds(categories: categories, pinnedOrder: pinnedOrder),
    );
  }

  List<CategoryModel> _recentCategories({
    required List<CategoryModel> categories,
    required TransactionsState transactionsState,
  }) {
    final txList = switch (transactionsState) {
      TransactionsLoaded() => transactionsState.transactions,
      TransactionDeleted() => transactionsState.transactions,
      _ => <TransactionModel>[],
    };
    final byId = {
      for (final category in categories) category.categoryId: category,
    };
    final result = <CategoryModel>[];
    for (final tx in txList) {
      final categoryId = tx.categoryId;
      if (categoryId == null || categoryId.isEmpty) continue;
      final category = byId[categoryId];
      if (category == null) continue;
      if (result.any((item) => item.categoryId == categoryId)) continue;
      result.add(category);
      if (result.length >= 12) break;
    }
    return result;
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

  Future<void> _syncWalletWidgetData(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final title = context.l10n.wallet;
    final emptyLabel = context.l10n.noWallets;
    final currency = context.read<CurrencyProvider>().currency;
    final walletsState = context.read<WalletCubit>().state;

    if (walletsState is! WalletsLoaded) {
      await AndroidWalletWidgetBridge.clear(
        colorScheme: colorScheme,
        title: title,
        emptyLabel: emptyLabel,
      );
      return;
    }

    WalletModel? defaultWallet;
    for (final wallet in walletsState.wallets) {
      if (wallet.isDefault && !wallet.isHidden) {
        defaultWallet = wallet;
        break;
      }
    }
    defaultWallet ??= walletsState.wallets
        .where((wallet) => !wallet.isHidden)
        .firstOrNull;

    await AndroidWalletWidgetBridge.syncWallet(
      wallet: defaultWallet,
      currency: currency,
      colorScheme: colorScheme,
      title: title,
      emptyLabel: emptyLabel,
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
        BlocListener<WalletCubit, WalletsState>(
          listener: (context, state) {
            if (state is WalletsLoaded ||
                state is WalletsEmpty ||
                state is WalletsInitial) {
              _syncWalletWidgetData(context);
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Scaffold(
            body: IndexedStack(index: _selectedIndex, children: _tabs),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: AnimatedScale(
              scale: _fabMenuOpen ? 1.06 : 1.0,
              duration: _fabAnimDuration,
              curve: _fabAnimCurve,
              child: Material(
                elevation: 0,
                color: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizing.borderRadius100,
                  ),
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
                    child: Center(
                      child: AnimatedRotation(
                        turns: _fabMenuOpen ? 0.125 : 0,
                        duration: _fabAnimDuration,
                        curve: _fabRotationCurve,
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: AppSizing.iconSizeM,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: AppBottomNavWidget(
              destinations: mainBottomNavDestinations(context),
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  _fabMenuOpen = false;
                });
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_fabMenuOpen,
              child: AnimatedOpacity(
                opacity: _fabMenuOpen ? 1 : 0,
                duration: _fabMenuAnimDuration,
                curve: _fabAnimCurve,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _fabMenuOpen = false),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 120,
            child: IgnorePointer(
              ignoring: !_fabMenuOpen,
              child: AnimatedSlide(
                offset: _fabMenuOpen ? Offset.zero : const Offset(0, 0.12),
                duration: _fabMenuAnimDuration,
                curve: _fabAnimCurve,
                child: AnimatedOpacity(
                  opacity: _fabMenuOpen ? 1 : 0,
                  duration: _fabMenuAnimDuration,
                  curve: _fabAnimCurve,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PrimaryButton(
                        text: context.l10n.addWithVoice,
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
                        text: context.l10n.addWithFile,
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
                        text: context.l10n.addManually,
                        onPressed: () {
                          setState(() => _fabMenuOpen = false);
                          Navigator.of(
                            context,
                          ).pushNamed(AppRouter.addTransaction);
                        },
                        icon: Icons.edit_note_rounded,
                        size: PrimaryButtonSize.small,
                        fullWidth: false,
                        rounded: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
