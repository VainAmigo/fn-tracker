import 'dart:convert';

import 'package:fn_tracker/features/features.dart';

abstract final class GoalSavingsAiContextBuilder {
  static String buildJsonString({
    required List<GoalModel> goals,
    required List<WalletModel> wallets,
    required List<CategoryModel> categories,
    required List<TransactionModel> transactions,
    String? focusGoalId,
  }) {
    final payload = <String, Object?>{
      'focusGoalId': focusGoalId,
      'goals': goals
          .map(
            (g) => <String, Object?>{
              'id': g.id,
              'name': g.name,
              'progress': g.progress,
              'targetAmount': g.targetAmount,
              'isCompleted': g.isCompleted,
              'isHidden': g.isHidden,
              'createdAt': g.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'wallets': wallets
          .map(
            (w) => <String, Object?>{
              'id': w.id,
              'name': w.name,
              'balance': w.balance,
              'isHidden': w.isHidden,
              'isDefault': w.isDefault,
            },
          )
          .toList(),
      'categories': categories
          .map((c) => <String, Object?>{'id': c.categoryId, 'name': c.name})
          .toList(),
      'transactions': transactions
          .where((t) => t.transferId == null)
          .map(
            (t) => <String, Object?>{
              'id': t.id,
              'type': t.type.toJson(),
              'amount': t.amount,
              'categoryId': t.categoryId,
              'walletId': t.walletId,
              'goalId': t.goalId,
              'date': t.date.toIso8601String(),
              'dayKey': t.dayKey,
              'note': t.note,
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
