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
    required this.onHideAmountChanged,
    required this.onHideGoalChanged,
  });

  final GoalModel goal;
  final VoidCallback onEdit;
  final void Function(bool hideAmount) onHideAmountChanged;
  final Future<void> Function(bool isHidden) onHideGoalChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final targetReached = goal.progress >= goal.targetAmount;

    if (goal.isCompleted) {
      return _buildCompletedModal(context, colorScheme);
    }
    return _buildInProgressModal(context, colorScheme, targetReached);
  }

  Widget _buildCompletedModal(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizing.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalSheetTitleWidget(title: 'Goal details'),
          const SizedBox(height: AppSizing.spaceBtwElements),
          GoalCardWidget(goal: goal),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          _InfoRow(
            label: 'Сумма цели',
            value: AmountFormatter.format(goal.targetAmount),
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          _InfoRow(
            label: 'Сумма завершения',
            value: goal.completedAmount != null
                ? AmountFormatter.format(goal.completedAmount!)
                : '—',
          ),
          const SizedBox(height: AppSizing.spaceBtwItems),
          _InfoRow(
            label: 'Создано',
            value: goal.createdAt.formatMonthDay,
          ),
          if (goal.completedAt != null) ...[
            const SizedBox(height: AppSizing.spaceBtwItems),
            _InfoRow(
              label: 'Завершено',
              value: goal.completedAt!.formatMonthDay,
            ),
          ],
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
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
          BlocListener<GoalsCubit, GoalsState>(
            listenWhen: (prev, curr) =>
                curr is GoalsLoaded || curr is GoalsError,
            listener: (context, state) {
              if (state is GoalsLoaded) {
                Navigator.of(context).pop();
              }
              if (state is GoalsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: PrimaryButton(
              text: 'Delete',
              icon: Icons.delete,
              size: PrimaryButtonSize.medium,
              rounded: false,
              onPressed: () async {
                final result = await showDeleteEntityDialog(
                  context,
                  title: 'Удалить цель?',
                  message:
                      'Удалить цель «${goal.name}»? Выберите способ удаления.',
                );
                if (!context.mounted || result == null || result == DeleteEntityResult.cancel) return;
                context.read<GoalsCubit>().deleteGoal(
                      goalId: goal.id,
                      deleteTransactions: result == DeleteEntityResult.deleteFull,
                    );
              },
            ),
          ),
          const SizedBox(height: AppSizing.bottomPadding),
        ],
      ),
    );
  }

  Widget _buildInProgressModal(
    BuildContext context,
    ColorScheme colorScheme,
    bool targetReached,
  ) {
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
          const SizedBox(height: AppSizing.spaceBtwItems),
          SwitchListTile(
            title: Text(
              'Скрыть сумму',
              style: AppTextStyles.text16w400(context),
            ),
            value: goal.hideAmount,
            onChanged: (_) => onHideAmountChanged(!goal.hideAmount),
          ),
          SwitchListTile(
            title: Text(
              'Скрыть цель',
              style: AppTextStyles.text16w400(context),
            ),
            subtitle: Text(
              'Будет видна только в блоке «Скрытые карточки»',
              style: AppTextStyles.text14w400(context),
            ),
            value: goal.isHidden,
            onChanged: (_) => onHideGoalChanged(!goal.isHidden),
          ),
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
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
                listenWhen: (prev, curr) =>
                    curr is GoalsLoaded || curr is GoalsError,
                listener: (context, state) {
                  if (state is GoalsLoaded) {
                    Navigator.of(context).pop();
                  }
                  if (state is GoalsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
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
                  onPressed: () async {
                    final result = await showDeleteEntityDialog(
                      context,
                      title: 'Удалить цель?',
                      message:
                          'Удалить цель «${goal.name}»? Выберите способ удаления.',
                    );
                    if (!context.mounted || result == null || result == DeleteEntityResult.cancel) return;
                    context.read<GoalsCubit>().deleteGoal(
                          goalId: goal.id,
                          deleteTransactions:
                              result == DeleteEntityResult.deleteFull,
                        );
                  },
                ),
              ),
              BlocListener<GoalsCubit, GoalsState>(
                listenWhen: (prev, curr) =>
                    curr is GoalsError || curr is GoalsCompleteGoalSuccess,
                listener: (context, state) {
                  if (state is GoalsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                  if (state is GoalsCompleteGoalSuccess) {
                    Navigator.of(context).pop();
                  }
                },
                child: Flexible(
                  child: PrimaryButton(
                    text: targetReached ? 'Complete' : 'Deposit',
                    icon: Icons.add,
                    size: PrimaryButtonSize.large,
                    rounded: true,
                    onPressed: () {
                      if (targetReached) {
                        context.read<GoalsCubit>().completeGoal(goal: goal);
                      } else {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          AppRouter.addTransaction,
                          arguments: goal,
                        );
                      }
                    },
                  ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.text14w400(context)),
        Text(
          value,
          style: AppTextStyles.text14w400(context)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
