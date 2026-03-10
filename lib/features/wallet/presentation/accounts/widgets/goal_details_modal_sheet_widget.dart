import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalDetailsModalSheetWidget extends StatelessWidget {
  const GoalDetailsModalSheetWidget({
    super.key,
    required this.goal,
    required this.onEdit,
  });

  final GoalModel goal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(
            title: 'Goal details',
            action: PrimaryButton(
              text: 'Edit',
              onPressed: onEdit,
              size: PrimaryButtonSize.xSmall,
              rounded: true,
              fullWidth: false,
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          GoalCardWidget(goal: goal),
          const SizedBox(height: AppSizing.spaceBtwElements),
          PrimaryButton(
            text: 'History',
            icon: Icons.history,
            size: PrimaryButtonSize.xSmall,
            rounded: true,
            backgroundColor: colorScheme.tertiary.withValues(alpha: 0.3),
            foregroundColor: colorScheme.tertiary,
            onPressed: () => Navigator.of(context).pushNamed(
              AppRouter.transactionsById,
              arguments: {'idType': TransactionIdType.goal, 'id': goal.id},
            ),
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: AppSizing.iconSizeXS,
                color: colorScheme.onSecondary,
              ),
              const SizedBox(width: AppSizing.spaceBtwItems),
              Text(
                'Created ${goal.createdAt.formatMonthDay}',
                style: AppTextStyles.text14w400(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.spaceBtwElements),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: AppSizing.spaceBtwItemsExtra,
            children: [
              BlocListener<GoalsCubit, GoalsState>(
                listener: (context, state) {
                  if (state is GoalsLoaded) {
                    Navigator.of(context).pop();
                  }
                },
                child: PrimaryButton(
                  text: 'Delete',
                  icon: Icons.delete,
                  iconOnly: true,
                  fullWidth: false,
                  size: PrimaryButtonSize.large,
                  paddingStyle: PrimaryButtonPaddingStyle.slim,
                  rounded: true,
                  onPressed: () {
                    context.read<GoalsCubit>().deleteGoal(goalId: goal.id);
                  },
                ),
              ),
              Flexible(
                child: PrimaryButton(
                  text: 'Deposit',
                  icon: Icons.add,
                  size: PrimaryButtonSize.large,
                  rounded: true,
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRouter.addTransaction, arguments: goal),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }
}
