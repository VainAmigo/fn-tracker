class GoalsModel {
  final List<GoalModel> goals;
  final TotalGoalModel totalGoal;

  GoalsModel({required this.goals, required this.totalGoal});

  Map<String, dynamic> toJson() {
    return {
      'goals': goals.map((goal) => goal.toJson()).toList(),
      'totalGoal': totalGoal.toJson(),
    };
  }

  GoalsModel copyWith({List<GoalModel>? goals, TotalGoalModel? totalGoal}) {
    return GoalsModel(
      goals: goals ?? this.goals,
      totalGoal: totalGoal ?? this.totalGoal,
    );
  }

  factory GoalsModel.fromJson(Map<String, dynamic> json) {
    return GoalsModel(
      goals: (json['goals'] as List<dynamic>)
          .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalGoal: TotalGoalModel.fromJson(json['totalGoal']),
    );
  }
}

class GoalModel {
  final String id;
  final String name;
  final String colorId;
  final String iconId;
  final double progress;
  final double targetAmount;
  final DateTime createdAt;
  final bool hideAmount;
  final bool isHidden;
  /// Цель завершена: пользователь нажал Complete и создана expense-транзакция.
  final bool isCompleted;
  /// Дата завершения цели.
  final DateTime? completedAt;
  /// Сумма на момент завершения (до expense-транзакции).
  final double? completedAmount;

  GoalModel({
    required this.id,
    required this.name,
    required this.colorId,
    required this.iconId,
    required this.progress,
    required this.targetAmount,
    required this.createdAt,
    this.hideAmount = false,
    this.isHidden = false,
    this.isCompleted = false,
    this.completedAt,
    this.completedAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorId': colorId,
      'iconId': iconId,
      'progress': progress,
      'targetAmount': targetAmount,
      'createdAt': createdAt.toIso8601String(),
      'hideAmount': hideAmount,
      'isHidden': isHidden,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'completedAmount': completedAmount,
    };
  }

  GoalModel copyWith({
    String? id,
    String? name,
    String? colorId,
    String? iconId,
    double? progress,
    double? targetAmount,
    DateTime? createdAt,
    bool? hideAmount,
    bool? isHidden,
    bool? isCompleted,
    DateTime? completedAt,
    double? completedAmount,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorId: colorId ?? this.colorId,
      iconId: iconId ?? this.iconId,
      progress: progress ?? this.progress,
      targetAmount: targetAmount ?? this.targetAmount,
      createdAt: createdAt ?? this.createdAt,
      hideAmount: hideAmount ?? this.hideAmount,
      isHidden: isHidden ?? this.isHidden,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completedAmount: completedAmount ?? this.completedAmount,
    );
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final raw = json['createdAt'];
    final DateTime createdAt = raw is DateTime
        ? raw
        : raw is String
        ? DateTime.parse(raw)
        : DateTime.fromMillisecondsSinceEpoch(0);

    return GoalModel(
      id: json['id'],
      name: json['name'],
      colorId: json['colorId'],
      iconId: json['iconId'],
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      createdAt: createdAt,
      hideAmount: json['hideAmount'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      completedAmount: (json['completedAmount'] as num?)?.toDouble(),
    );
  }
}

class TotalGoalModel {
  final double totalProgress;
  final double totalTargetAmount;
  final int goalsCount;
  final int completedCount;

  TotalGoalModel({
    required this.totalProgress,
    required this.totalTargetAmount,
    required this.goalsCount,
    required this.completedCount,
  });

  double get percent =>
      totalTargetAmount > 0 ? (totalProgress / totalTargetAmount * 100).clamp(0, 100) : 0;

  double get remaining =>
      (totalTargetAmount - totalProgress).clamp(0, double.infinity);

  int get activeCount => goalsCount - completedCount;

  Map<String, dynamic> toJson() {
    return {
      'totalProgress': totalProgress,
      'totalTargetAmount': totalTargetAmount,
      'goalsCount': goalsCount,
      'completedCount': completedCount,
    };
  }

  TotalGoalModel copyWith({
    double? totalProgress,
    double? totalTargetAmount,
    int? goalsCount,
    int? completedCount,
  }) {
    return TotalGoalModel(
      totalProgress: totalProgress ?? this.totalProgress,
      totalTargetAmount: totalTargetAmount ?? this.totalTargetAmount,
      goalsCount: goalsCount ?? this.goalsCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }

  factory TotalGoalModel.fromJson(Map<String, dynamic> json) {
    return TotalGoalModel(
      totalProgress: json['totalProgress'],
      totalTargetAmount: json['totalTargetAmount'],
      goalsCount: json['goalsCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
    );
  }
}
