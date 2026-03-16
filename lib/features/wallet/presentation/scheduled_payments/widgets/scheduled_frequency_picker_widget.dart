import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/features/wallet/data/models/scheduled_payment_model.dart';
import 'package:fn_tracker/theme/themes.dart';

class ScheduledFrequencyPickerWidget extends StatelessWidget {
  const ScheduledFrequencyPickerWidget({
    required this.initialFrequency,
    required this.onFrequencySelected,
    super.key,
  });

  final ScheduledPaymentFrequency initialFrequency;
  final ValueChanged<ScheduledPaymentFrequency> onFrequencySelected;

  static Future<void> show(
    BuildContext context, {
    required ScheduledPaymentFrequency initialFrequency,
    required ValueChanged<ScheduledPaymentFrequency> onFrequencySelected,
  }) {
    return AppBottomSheet.showFittedModalBottomSheet(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ScheduledFrequencyPickerWidget(
        initialFrequency: initialFrequency,
        onFrequencySelected: onFrequencySelected,
      ),
    );
  }

  void _select(BuildContext context, ScheduledPaymentFrequency value) {
    onFrequencySelected(value);
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
          const ModalSheetTitleWidget(title: 'Payment frequency'),
          const SizedBox(height: AppSizing.spaceBtwSections),
          _card(
            context,
            c,
            ScheduledPaymentFrequency.yearly,
            'Ежегодно',
            height: AppSizing.heightL,
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          _card(context, c, ScheduledPaymentFrequency.monthly, 'Ежемесячно'),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          _card(context, c, ScheduledPaymentFrequency.oneTime, 'Единожды'),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    ColorScheme c,
    ScheduledPaymentFrequency frequency,
    String title, {
    double? height,
  }) {
    final isSelected = initialFrequency == frequency;
    return InkWell(
      onTap: () => _select(context, frequency),
      borderRadius: BorderRadius.circular(AppSizing.borderRadius16),
      child: Container(
        height: height ?? AppSizing.heightM,
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
            title,
            style: AppTextStyles.text16w400(
              context,
            ).copyWith(color: isSelected ? c.onPrimary : c.onSecondary),
          ),
        ),
      ),
    );
  }
}
