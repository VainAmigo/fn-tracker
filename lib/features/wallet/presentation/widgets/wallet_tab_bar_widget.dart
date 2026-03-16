import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';

class WalletTabBarWidget extends StatelessWidget {
  const WalletTabBarWidget({
    super.key,
    required this.title,
    required this.selectedTab,
    required this.onChanged,
  });

  final String title;
  final WalletTab selectedTab;
  final ValueChanged<WalletTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TabTitleWidget(title: title),
        CustomTabWidget<WalletTab>(
          items: WalletTab.values,
          selectedValue: selectedTab,
          onChanged: onChanged,
          labelBuilder: (tab) => tab.label,
          leftPadding: 0,
        ),
      ],
    );
  }
}
