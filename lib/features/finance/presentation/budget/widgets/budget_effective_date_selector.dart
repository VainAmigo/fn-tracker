import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Режим применения бюджета: заменить всё или с определённой даты.
enum BudgetEffectiveDateMode { replaceAll, fromDate }

/// Виджет выбора режима и даты применения бюджета (для режима редактирования).
class BudgetEffectiveDateSelector extends StatelessWidget {
  const BudgetEffectiveDateSelector({
    super.key,
    required this.mode,
    required this.effectiveDate,
    required this.onModeChanged,
    required this.onDateChanged,
  });

  final BudgetEffectiveDateMode mode;
  final DateTime effectiveDate;
  final ValueChanged<BudgetEffectiveDateMode> onModeChanged;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedControl<BudgetEffectiveDateMode>(
          segments: const [
            SegmentItem(
              value: BudgetEffectiveDateMode.replaceAll,
              label: 'Replace all',
            ),
            SegmentItem(
              value: BudgetEffectiveDateMode.fromDate,
              label: 'From date',
            ),
          ],
          selectedValue: mode,
          onChanged: onModeChanged,
        ),
        if (mode == BudgetEffectiveDateMode.fromDate) ...[
          const SizedBox(height: AppSizing.spaceBtwElements),
          FormCardWidget(
            title: effectiveDate.dayKey,
            subtitle: 'Effective from',
            trailing: Icon(
              Icons.calendar_today,
              size: AppSizing.iconSizeS,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onTap: () => _pickDate(context),
          ),
        ],
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: effectiveDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }
}
