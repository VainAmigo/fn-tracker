import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/theme/themes.dart';

class GoalListWithTotalWidget extends StatefulWidget {
  const GoalListWithTotalWidget({
    super.key,
    this.onGoalSelected,
    this.shrinkWrap = false,
    this.autoLoad = false,
  });

  final ValueChanged<GoalModel>? onGoalSelected;
  final bool shrinkWrap;
  final bool autoLoad;

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

        final goals = goalsModel.goals;

        return ListView.separated(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : null,
          itemCount: goals.length + 1,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizing.spaceBtwItemsExtra),
          itemBuilder: (context, index) {
            if (index == 0) {
              return GoalTotalCardWidget(total: goalsModel.totalGoal);
            }

            final goal = goals[index - 1];
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
