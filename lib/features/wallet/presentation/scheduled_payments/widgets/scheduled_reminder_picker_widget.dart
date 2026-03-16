import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/wallet/data/models/scheduled_payment_model.dart';
import 'package:fn_tracker/theme/themes.dart';

class ScheduledReminderPickerWidget extends StatefulWidget {
  const ScheduledReminderPickerWidget({
    this.initialOption,
    required this.onOptionSelected,
    this.initialHour = 9,
    this.initialMinute = 0,
    this.onTimeSelected,
    super.key,
  });

  final ScheduledReminderOption? initialOption;
  final ValueChanged<ScheduledReminderOption> onOptionSelected;
  final int initialHour;
  final int initialMinute;
  final void Function(int hour, int minute)? onTimeSelected;

  static Future<void> show(
    BuildContext context, {
    ScheduledReminderOption? initialOption,
    required ValueChanged<ScheduledReminderOption> onOptionSelected,
    int initialHour = 9,
    int initialMinute = 0,
    void Function(int hour, int minute)? onTimeSelected,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ScheduledReminderPickerWidget(
        initialOption: initialOption,
        onOptionSelected: onOptionSelected,
        initialHour: initialHour,
        initialMinute: initialMinute,
        onTimeSelected: onTimeSelected,
      ),
    );
  }

  @override
  State<ScheduledReminderPickerWidget> createState() =>
      _ScheduledReminderPickerWidgetState();
}

class _ScheduledReminderPickerWidgetState
    extends State<ScheduledReminderPickerWidget> {
  late ScheduledReminderOption? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialOption;
  }

  void _select(BuildContext context, ScheduledReminderOption value) {
    setState(() => _selectedOption = value);
    widget.onOptionSelected(value);
  }

  Future<void> _openTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: widget.initialHour, minute: widget.initialMinute),
    );
    if (picked != null && context.mounted) {
      widget.onTimeSelected?.call(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final timeStr =
        '${widget.initialHour.toString().padLeft(2, '0')}:${widget.initialMinute.toString().padLeft(2, '0')}';
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSizing.bottomPadding,
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const ModalSheetTitleWidget(title: 'When to remind'),
          const SizedBox(height: AppSizing.spaceBtwSections),
          ...ScheduledReminderOption.values.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizing.spaceBtwItemsExtra),
              child: _card(context, c, option),
            ),
          ),
          if (widget.onTimeSelected != null) ...[
            const SizedBox(height: AppSizing.spaceBtwSections),
            Text('Время уведомления', style: AppTextStyles.listTileTitle(context)),
            const SizedBox(height: AppSizing.spaceBtwItemsExtra),
            InkWell(
              onTap: () => _openTimePicker(context),
              borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
              child: Container(
                height: AppSizing.heightM,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizing.spaceBtwElements,
                  vertical: AppSizing.spaceBtwItemsExtra,
                ),
                decoration: BoxDecoration(
                  color: c.secondary,
                  borderRadius: BorderRadius.circular(AppSizing.borderRadius4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: AppSizing.iconSizeM, color: c.onSecondary),
                    const SizedBox(width: AppSizing.spaceBtwItems),
                    Text(
                      timeStr,
                      style: AppTextStyles.text16w400(context).copyWith(
                        color: c.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    ColorScheme c,
    ScheduledReminderOption option,
  ) {
    final isSelected = _selectedOption != null && _selectedOption == option;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _select(context, option),
        borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: AppSizing.heightM,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizing.spaceBtwElements,
            vertical: AppSizing.spaceBtwItemsExtra,
          ),
          decoration: BoxDecoration(
            color: isSelected ? c.primary : c.secondary,
            borderRadius: BorderRadius.circular(
              isSelected ? AppSizing.borderRadius100 : AppSizing.borderRadius4,
            ),
          ),
          child: Center(
            child: Text(
              option.label,
              style: AppTextStyles.text16w400(context).copyWith(
                color: isSelected ? c.onPrimary : c.onSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
