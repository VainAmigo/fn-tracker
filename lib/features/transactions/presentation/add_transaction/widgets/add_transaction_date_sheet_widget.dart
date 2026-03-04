import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

class AddTransactionDateSheetWidget extends StatelessWidget {
  const AddTransactionDateSheetWidget({
    required this.initialDate,
    required this.onDateSelected,
    super.key,
  });

  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSizing.bottomPadding,
        left: AppSizing.defaultPadding,
        right: AppSizing.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(title: 'Select date'),
          const SizedBox(height: AppSizing.spaceBtwSections),
          PrimaryButton(
            text: 'Choose date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (!context.mounted) return;
              if (picked != null) {
                onDateSelected(picked);
                Navigator.of(context).pop();
              }
            },
            size: PrimaryButtonSize.large,
            icon: Icons.calendar_month,
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSurface,
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          _buildDateRowWidget(context),
        ],
      ),
    );
  }

  Widget _buildDateRowWidget(BuildContext context) {
    final now = DateUtils.dateOnly(DateTime.now());
    final selected = DateUtils.dateOnly(initialDate);
    final yesterday = now.subtract(const Duration(days: 1));

    return Row(
      spacing: AppSizing.spaceBtwItemsExtra,
      children: [
        Expanded(
          child: _buildDateRowElement(
            context,
            selected == yesterday,
            'Yesterday',
            () {
              onDateSelected(yesterday);
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(
          child: _buildDateRowElement(
            context,
            selected == now,
            'Today',
            () {
              onDateSelected(now);
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateRowElement(
    BuildContext context,
    bool isSelected,
    String title,
    Function()? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizing.spaceBtwElements,
          vertical: AppSizing.spaceBtwItemsExtra,
        ),
        height: AppSizing.heightM,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          borderRadius: isSelected
              ? BorderRadius.circular(AppSizing.borderRadius100)
              : BorderRadius.circular(AppSizing.borderRadius16),
        ),
        child: Center(
          child: Text(title, style: AppTextStyles.text16w400(context)),
        ),
      ),
    );
  }
}
