/// Табы для фильтрации целей: в процессе / завершённые.
enum GoalTab { inProgress, completed }

extension GoalTabX on GoalTab {
  String get label => switch (this) {
        GoalTab.inProgress => 'В процессе',
        GoalTab.completed => 'Завершённые',
      };
}
