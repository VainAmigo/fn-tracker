import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Вариант напоминания о плановом платеже.
enum ScheduledReminderOption {
  onTheDay('On the day'),
  oneDayBefore('1 day before'),
  twoDaysBefore('2 days before'),
  threeDaysBefore('3 days before'),
  oneWeekBefore('1 week before');

  const ScheduledReminderOption(this.label);
  final String label;
}

class ScheduledReminderPickerWidget extends StatelessWidget {
  const ScheduledReminderPickerWidget({
    required this.initialOption,
    required this.onOptionSelected,
    super.key,
  });

  final ScheduledReminderOption initialOption;
  final ValueChanged<ScheduledReminderOption> onOptionSelected;

  static Future<void> show(
    BuildContext context, {
    required ScheduledReminderOption initialOption,
    required ValueChanged<ScheduledReminderOption> onOptionSelected,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ScheduledReminderPickerWidget(
        initialOption: initialOption,
        onOptionSelected: onOptionSelected,
      ),
    );
  }

  void _select(BuildContext context, ScheduledReminderOption value) {
    onOptionSelected(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
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
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    ColorScheme c,
    ScheduledReminderOption option,
  ) {
    final isSelected = initialOption == option;
    return InkWell(
      onTap: () => _select(context, option),
      borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      child: Container(
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
    );
  }
}
