import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: AppSizing.defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WalletTabBarWidget(
                title: 'Your ballance and saves',
                selectedTab: _selectedTab,
                onChanged: (tab) => setState(() => _selectedTab = tab),
              ),
              const SizedBox(height: AppSizing.spaceBtwElements),
              Expanded(
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
  }
}
