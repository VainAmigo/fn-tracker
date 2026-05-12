import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

class FinanceTabBarWidget extends StatelessWidget {
  const FinanceTabBarWidget({
    super.key,
    required this.title,
    required this.visualOrder,
    required this.selectedTab,
    required this.onChanged,
    required this.onTabOrderSettingsPressed,
  });

  final String title;

  /// Индексы [FinanceTab.values] в порядке отображения.
  final List<int> visualOrder;
  final FinanceTab selectedTab;
  final ValueChanged<FinanceTab> onChanged;

  /// Кнопка «Настройки» в конце полосы — порядок вкладок в модалке.
  final VoidCallback onTabOrderSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TabTitleWidget(title: title),
        SizedBox(
          height: AppSizing.heightM,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final entry in visualOrder.asMap().entries) ...[
                  if (entry.key > 0)
                    SizedBox(width: AppSizing.spaceBtwElements),
                  _FinanceTabLabel(
                    tab: FinanceTab.values[entry.value],
                    selectedTab: selectedTab,
                    onTap: onChanged,
                    colorScheme: colorScheme,
                  ),
                ],
                SizedBox(width: AppSizing.spaceBtwElements),
                GestureDetector(
                  onTap: onTabOrderSettingsPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      context.l10n.settings,
                      style: AppTextStyles.text16w400(context).copyWith(
                        color: colorScheme.onSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FinanceTabLabel extends StatelessWidget {
  const _FinanceTabLabel({
    required this.tab,
    required this.selectedTab,
    required this.onTap,
    required this.colorScheme,
  });

  final FinanceTab tab;
  final FinanceTab selectedTab;
  final ValueChanged<FinanceTab> onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isSelected = tab == selectedTab;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(tab),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          tab.label(context),
          style: AppTextStyles.text16w400(context).copyWith(
            color: isSelected ? colorScheme.onSurface : colorScheme.onSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
