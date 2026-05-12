import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Модалка: изменить порядок вкладок экрана «Финансы».
/// Оформление как [QuickCategoriesSettingsSheet] / [QuickCategoriesPinSheet].
class FinanceTabOrderSettingsSheet extends StatefulWidget {
  const FinanceTabOrderSettingsSheet({
    super.key,
    required this.initialOrder,
    required this.onOrderChanged,
  });

  final List<int> initialOrder;
  final ValueChanged<List<int>> onOrderChanged;

  static Future<void> show(
    BuildContext context, {
    required List<int> initialOrder,
    required ValueChanged<List<int>> onOrderChanged,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: false,
      child: FinanceTabOrderSettingsSheet(
        initialOrder: List<int>.from(initialOrder),
        onOrderChanged: onOrderChanged,
      ),
    );
  }

  @override
  State<FinanceTabOrderSettingsSheet> createState() =>
      _FinanceTabOrderSettingsSheetState();
}

class _FinanceTabOrderSettingsSheetState
    extends State<FinanceTabOrderSettingsSheet> {
  late List<int> _order;

  @override
  void initState() {
    super.initState();
    _order = List<int>.from(widget.initialOrder);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
    unawaited(FinanceTabOrderStorage.save(List<int>.from(_order)));
    widget.onOrderChanged(List<int>.from(_order));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizing.defaultPadding,
        bottom: AppSizing.bottomPadding,
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          ModalSheetTitleWidget(
            title: context.l10n.financeTabOrderTitle,
            subtitle: context.l10n.financeTabOrderSubtitle,
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          TitledSection(
            title: context.l10n.financeTabOrderSectionTitle,
            children: [
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _order.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final tabIndex = _order[index];
                  final tab = FinanceTab.values[tabIndex];
                  final radius = radiusForIndex(index, _order.length);

                  return Padding(
                    key: ValueKey<int>(tabIndex),
                    padding: const EdgeInsets.only(
                      bottom: AppSizing.spaceBtwItemsExtra,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSizing.borderRadius12),
                      ),
                      child: CategoryCard(
                        title: tab.label(context),
                        leading: Icon(
                          _leadingIcon(tab),
                          size: AppSizing.iconSizeM,
                          color: colorScheme.primary,
                        ),
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.drag_handle,
                            color: colorScheme.onSurfaceVariant,
                            size: AppSizing.iconSizeL,
                          ),
                        ),
                        radius: radius,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _leadingIcon(FinanceTab tab) {
  return switch (tab) {
    FinanceTab.budget => Icons.pie_chart_outline_rounded,
    FinanceTab.accounts => Icons.account_balance_wallet_outlined,
    FinanceTab.transactions => Icons.receipt_long_rounded,
    FinanceTab.categories => Icons.category_rounded,
    FinanceTab.scheduledPayments => Icons.event_repeat_rounded,
  };
}
