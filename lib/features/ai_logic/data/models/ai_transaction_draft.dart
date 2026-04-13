import 'package:flutter/material.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';

/// Один черновик транзакции после AI (поля могут быть пустыми — дозаполнение вручную).
class AiTransactionDraft {
  AiTransactionDraft({
    required this.transactionType,
    required this.date,
    String? categoryId,
    this.walletId,
    this.goalId,
    this.amount,
    this.note = '',
  }) : categoryId =
            (categoryId != null && categoryId.isNotEmpty) ? categoryId : null;

  TransactionType transactionType;
  DateTime date;
  String? categoryId;
  String? walletId;
  String? goalId;
  double? amount;
  String note;

  bool get hasValidAccount =>
      (walletId != null && goalId == null) ||
      (walletId == null && goalId != null);

  bool get hasValidAmount => amount != null && amount! > 0;

  /// Для расхода нужна категория или цель (как на экране добавления).
  bool get hasRequiredCategoryForExpense =>
      transactionType != TransactionType.expense ||
      goalId != null ||
      (categoryId != null && categoryId!.isNotEmpty);

  bool get isReadyToSave =>
      hasValidAmount &&
      hasValidAccount &&
      hasRequiredCategoryForExpense;

  AiTransactionDraft copyWith({
    TransactionType? transactionType,
    DateTime? date,
    String? categoryId,
    String? walletId,
    String? goalId,
    double? amount,
    String? note,
    bool clearCategory = false,
    bool clearWallet = false,
    bool clearGoal = false,
    bool clearAmount = false,
  }) {
    return AiTransactionDraft(
      transactionType: transactionType ?? this.transactionType,
      date: date ?? this.date,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      walletId: clearWallet ? null : (walletId ?? this.walletId),
      goalId: clearGoal ? null : (goalId ?? this.goalId),
      amount: clearAmount ? null : (amount ?? this.amount),
      note: note ?? this.note,
    );
  }

  TransactionModel toTransactionModel({String? currencyCode}) {
    final safeNote = note.isEmpty
        ? null
        : AiExpenseNoteUtils.clampToWordCount(note, 5);
    final amt = amount ?? 0;
    final d = DateUtils.dateOnly(date);
    return TransactionModel(
      id: '',
      categoryId: categoryId,
      walletId: walletId,
      goalId: goalId,
      amount: amt,
      note: safeNote,
      type: transactionType,
      createdAt: DateTime.now(),
      date: d,
      dayKey: d.dayKey,
      periodKey: d.periodKey,
      currency: currencyCode,
    );
  }
}
