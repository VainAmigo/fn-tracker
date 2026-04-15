import 'package:flutter/material.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';

class GoalHiddenListSheet extends StatelessWidget {
  const GoalHiddenListSheet({
    super.key,
    required this.goals,
    required this.onGoalSelected,
    this.onChangePin,
  });

  final List<GoalModel> goals;
  final void Function(GoalModel goal) onGoalSelected;
  final VoidCallback? onChangePin;

  @override
  Widget build(BuildContext context) {
    return HiddenCardsSheet<GoalModel>(
      title: context.l10n.hiddenCards,
      items: goals,
      itemBuilder: (goal) => GoalCardWidget(goal: goal),
      onItemTap: onGoalSelected,
      onChangePin: onChangePin,
    );
  }
}
