import 'package:flutter/material.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Модалка с информацией о бюджете и вариантах добавления.
class BudgetInfoModalSheet extends StatelessWidget {
  const BudgetInfoModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.showFittedModalBottomSheet<void>(
      context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      child: const BudgetInfoModalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizing.defaultPadding,
        AppSizing.defaultPadding,
        AppSizing.defaultPadding,
        AppSizing.bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModalSheetTitleWidget(title: 'About budget'),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Text(
            'Budget is a monthly spending limit. You can track how much you spend '
            'against it and add new amounts when your budget changes.',
            style: AppTextStyles.text14w400(context).copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Text(
            'Add options',
            style: AppTextStyles.text14w400(context).copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          BudgetInfoTile(
            title: 'Replace all',
            description:
                'Replaces all budget history with the new amount. Use when you '
                'want to reset your budget completely.',
            icon: Icons.refresh,
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          BudgetInfoTile(
            title: 'From date',
            description:
                'Adds a new budget amount effective from a specific date. '
                'Previous entries remain in history.',
            icon: Icons.calendar_today,
          ),
        ],
      ),
    );
  }
}

class BudgetInfoTile extends StatelessWidget {
  const BudgetInfoTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppSizing.iconSizeS,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSizing.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.text14w400(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSizing.spaceBtwItemsExtra),
                Text(
                  description,
                  style: AppTextStyles.text14w400(context).copyWith(
                    color: colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
