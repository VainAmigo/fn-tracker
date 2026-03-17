import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/wallet/data/models/scheduled_payment_model.dart';
import 'package:fn_tracker/theme/themes.dart';

class ScheduledPaymentTypePickerWidget extends StatelessWidget {
  const ScheduledPaymentTypePickerWidget({
    required this.initialType,
    required this.onTypeSelected,
    super.key,
  });

  final ScheduledPaymentType initialType;
  final ValueChanged<ScheduledPaymentType> onTypeSelected;

  static Future<void> show(
    BuildContext context, {
    required ScheduledPaymentType initialType,
    required ValueChanged<ScheduledPaymentType> onTypeSelected,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ScheduledPaymentTypePickerWidget(
        initialType: initialType,
        onTypeSelected: onTypeSelected,
      ),
    );
  }

  void _select(BuildContext context, ScheduledPaymentType value) {
    onTypeSelected(value);
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
          const ModalSheetTitleWidget(title: 'Type of scheduled payment'),
          const SizedBox(height: AppSizing.spaceBtwSections),
          _card(context, c, ScheduledPaymentType.subscription),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          _card(context, c, ScheduledPaymentType.regular),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          _card(context, c, ScheduledPaymentType.regularIncome),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    ColorScheme c,
    ScheduledPaymentType type,
  ) {
    final isSelected = initialType == type;
    return InkWell(
      onTap: () => _select(context, type),
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
            type.label,
            style: AppTextStyles.text16w400(context).copyWith(
              color: isSelected ? c.onPrimary : c.onSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
