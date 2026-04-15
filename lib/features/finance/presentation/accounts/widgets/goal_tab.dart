import 'package:flutter/material.dart';
import 'package:fn_tracker/l10n/l10.dart';

/// Табы для фильтрации целей: в процессе / завершённые.
enum GoalTab { inProgress, completed }

extension GoalTabX on GoalTab {
  String label(BuildContext context) => switch (this) {
        GoalTab.inProgress => context.l10n.inProgress,
        GoalTab.completed => context.l10n.completed,
      };
}
