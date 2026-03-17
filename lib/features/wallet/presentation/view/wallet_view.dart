import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  WalletTab _selectedTab = WalletTab.budget;

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
                  WalletTabBarWidget(
                    title: 'Your ballance and saves',
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
