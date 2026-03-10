import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalsListWidget extends StatefulWidget {
  const GoalsListWidget({
    super.key,
    this.autoLoad = false,
    this.shrinkWrap = false,
    this.onGoalSelected,
  });

  final bool autoLoad;
  final bool shrinkWrap;
  final ValueChanged<GoalModel>? onGoalSelected;

  @override
  State<GoalsListWidget> createState() => _GoalsListWidgetState();
}

class _GoalsListWidgetState extends State<GoalsListWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      context.read<GoalsCubit>().loadGoals();
    }
  }

  CategoryCardRadius _radiusForIndex(int index, int total) {
    if (total == 1) return CategoryCardRadius.single;
    if (index == 0) return CategoryCardRadius.first;
    if (index == total - 1) return CategoryCardRadius.last;
    return CategoryCardRadius.middle;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, state) {
        return switch (state) {
          GoalsInitial() => const SizedBox.shrink(),
          GoalsLoading() => const Center(child: CircularProgressIndicator()),
          GoalsEmpty() => const SizedBox.shrink(),
          GoalsLoaded() => _buildList(context, state.goalsModel.goals),
          GoalsError() => Center(child: Text(state.message)),
        };
      },
    );
  }

  Widget _buildList(BuildContext context, List<GoalModel> goals) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = goals.length + 1;

    return ListView.separated(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: total,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSizing.spaceBtwItemsExtra),
      itemBuilder: (context, index) {
        if (index == goals.length) {
          return CategoryCard(
            title: 'New goal',
            leading: Container(
              height: AppSizing.heightS,
              decoration: BoxDecoration(
                color: colorScheme.onSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Icon(
                  Icons.add_rounded,
                  size: AppSizing.iconSizeM,
                  color: colorScheme.onSecondary,
                ),
              ),
            ),
            radius: _radiusForIndex(index, total),
            onTap: () => Navigator.of(context).pushNamed(AppRouter.createGoal),
          );
        }

        final goal = goals[index];
        final shade = findShadeById(goal.colorId);
        final icon = findIconById(goal.iconId);
        final color = shade?.color ?? colorScheme.primary;

        return CategoryCard(
          title: goal.name,
          subtitle:
              '\$${goal.progress.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
          leading: Container(
            height: AppSizing.heightS,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Icon(
                icon?.icon ?? Icons.flag_rounded,
                size: AppSizing.iconSizeM,
                color: color,
              ),
            ),
          ),
          radius: _radiusForIndex(index, total),
          onTap: widget.onGoalSelected != null
              ? () => widget.onGoalSelected!(goal)
              : () => Navigator.of(context).pushNamed(
                    AppRouter.updateGoal,
                    arguments: goal,
                  ),
        );
      },
    );
  }
}
