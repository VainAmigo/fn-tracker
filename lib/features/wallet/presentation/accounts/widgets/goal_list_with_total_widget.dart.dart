import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/components/components.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalListWithTotalWidget extends StatefulWidget {
  const GoalListWithTotalWidget({
    super.key,
    this.onGoalSelected,
    this.shrinkWrap = false,
    this.autoLoad = false,
    this.onHiddenCardsSelected,
  });

  final ValueChanged<GoalModel>? onGoalSelected;
  final bool shrinkWrap;
  final bool autoLoad;
  final VoidCallback? onHiddenCardsSelected;

  @override
  State<GoalListWithTotalWidget> createState() =>
      _GoalListWithTotalWidgetState();
}

class _GoalListWithTotalWidgetState extends State<GoalListWithTotalWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      context.read<GoalsCubit>().loadGoals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, state) {
        if (state is GoalsLoading || state is GoalsInitial) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is GoalsError) {
          return Center(
            child: Text(state.message, textAlign: TextAlign.center),
          );
        }

        final goalsModel = switch (state) {
          GoalsLoaded s => s.goalsModel,
          _ => null,
        };

        if (goalsModel == null || goalsModel.goals.isEmpty) {
          return const Center(child: Text('Целей пока нет'));
        }

        final visibleGoals =
            goalsModel.goals.where((g) => !g.isHidden).toList();
        final hiddenGoals = goalsModel.goals.where((g) => g.isHidden).toList();
        final hasHidden = hiddenGoals.isNotEmpty;

        return ListView.separated(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : null,
          itemCount: visibleGoals.length + (hasHidden ? 2 : 1),
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          itemBuilder: (context, index) {
            if (index == 0) {
              return GoalTotalCardWidget(total: goalsModel.totalGoal);
            }
            if (hasHidden && index == visibleGoals.length + 1) {
              return _HiddenGoalsPlaceholder(
                count: hiddenGoals.length,
                onTap: widget.onHiddenCardsSelected,
              );
            }

            final goal = visibleGoals[index - 1];
            return GoalCardWidget(
              goal: goal,
              onTap: widget.onGoalSelected != null
                  ? () => widget.onGoalSelected!(goal)
                  : null,
            );
          },
        );
      },
    );
  }
}

class _HiddenGoalsPlaceholder extends StatelessWidget {
  const _HiddenGoalsPlaceholder({
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CategoryCard(
      title: 'Скрытые карточки',
      subtitle: '$count ${_pluralize(count)}',
      leading: Container(
        height: AppSizing.heightS,
        decoration: BoxDecoration(
          color: colorScheme.onSecondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizing.borderRadius8),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Icon(
            Icons.visibility_off,
            size: AppSizing.iconSizeM,
            color: colorScheme.onSecondary,
          ),
        ),
      ),
      radius: CardRadius.single,
      onTap: onTap,
    );
  }

  String _pluralize(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'карточка';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) {
      return 'карточки';
    }
    return 'карточек';
  }
}
