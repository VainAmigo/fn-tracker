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
  ];

  Future<void> _onRefresh() async {
    final (:start, :end) = MonthRangeUtils.currentMonth();
    await Future.wait([
      context.read<BudgetCubit>().loadBudgetStats(periodKey: start.periodKey),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              const tabBarHeight = 100.0;
              final contentHeight = constraints.maxHeight -
                  tabBarHeight -
                  AppSizing.spaceBtwElements;

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
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
                        SizedBox(
                          height: contentHeight,
                          child: IndexedStack(
                            index: _selectedTab.index,
                            children: _tabBodies,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
