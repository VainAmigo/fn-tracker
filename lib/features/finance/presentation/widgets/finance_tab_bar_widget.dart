import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';

class FinanceTabBarWidget extends StatelessWidget {
  const FinanceTabBarWidget({
    super.key,
    required this.title,
    required this.selectedTab,
    required this.onChanged,
  });

  final String title;
  final FinanceTab selectedTab;
  final ValueChanged<FinanceTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TabTitleWidget(title: title),
        CustomTabWidget<FinanceTab>(
          items: FinanceTab.values,
          selectedValue: selectedTab,
          onChanged: onChanged,
          labelBuilder: (tab) => tab.label,
          leftPadding: 0,
        ),
      ],
    );
  }
}
