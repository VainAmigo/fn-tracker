import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fn_tracker/features/ai_logic/data/ai_constants.dart';
import 'package:fn_tracker/features/ai_logic/data/ai_expense_note_utils.dart';
import 'package:fn_tracker/features/ai_logic/data/ai_expense_parse_repository.dart';
import 'package:fn_tracker/features/ai_logic/data/ai_prompts.dart';
import 'package:fn_tracker/features/ai_logic/data/models/ai_transaction_draft.dart';
import 'package:fn_tracker/features/transactions/data/models/category_model.dart';
import 'package:fn_tracker/features/transactions/data/models/transaction_model.dart';
import 'package:fn_tracker/features/wallet/data/models/wallet_model.dart';

class AiExpenseParseRepositoryImpl implements AiExpenseParseRepository {
  AiExpenseParseRepositoryImpl({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  GenerativeModel _model() {
    final firebaseAi = FirebaseAI.googleAI(auth: _auth);
    return firebaseAi.generativeModel(
      model: kAiGenerativeModelName,
      systemInstruction: Content.system(AiPrompts.systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseJsonSchema: AiPrompts.responseJsonSchema,
        temperature: 0.2,
      ),
    );
  }

  List<Map<String, String>> _categoryMaps(List<CategoryModel> categories) {
    return categories
        .map((c) => {'categoryId': c.categoryId, 'name': c.name})
        .toList();
  }

  List<Map<String, String>> _walletMaps(List<WalletModel> wallets) {
    return wallets
        .where((w) => w.id != null && w.id!.isNotEmpty && !w.isHidden)
        .map((w) => {'id': w.id!, 'name': w.name})
        .toList();
  }

  Set<String> _categoryIds(List<CategoryModel> c) =>
      c.map((e) => e.categoryId).toSet();

  Set<String> _walletIds(List<WalletModel> w) =>
      w.map((e) => e.id).whereType<String>().toSet();

  TransactionType _parseType(Map<String, dynamic> item) {
    final t = item['type']?.toString().toUpperCase() ?? 'EXPENSE';
    if (t == 'INCOME') return TransactionType.income;
    return TransactionType.expense;
  }

  /// Дата из ответа модели (YYYY-MM-DD или ISO). Иначе null — использовать сегодня.
  DateTime? _parseModelDateString(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(t);
    if (m != null) {
      final y = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      final d = int.tryParse(m.group(3)!);
      if (y != null && mo != null && d != null) {
        try {
          return DateTime(y, mo, d);
        } catch (_) {
          return null;
        }
      }
    }
    final parsed = DateTime.tryParse(t);
    if (parsed != null) {
      return DateUtils.dateOnly(parsed);
    }
    return null;
  }

  AiTransactionDraft _mapToDraft(
    Map<String, dynamic> item,
    Set<String> allowedCat,
    Set<String> allowedWal,
    DateTime defaultDate,
  ) {
    final type = _parseType(item);
    final rawCat = item['categoryId']?.toString() ?? '';
    final rawWal = item['walletId']?.toString() ?? '';
    final amountRaw = item['amount'];
    final note = item['note']?.toString() ?? '';

    final categoryId =
        rawCat.isNotEmpty && allowedCat.contains(rawCat) ? rawCat : null;
    final walletId =
        rawWal.isNotEmpty && allowedWal.contains(rawWal) ? rawWal : null;

    double? amount;
    final parsed = switch (amountRaw) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s.replaceAll(',', '.')),
      _ => null,
    };
    if (parsed != null && parsed > 0) {
      amount = parsed;
    }

    final fromModel = _parseModelDateString(item['date']?.toString() ?? '');
    final date =
        fromModel != null ? DateUtils.dateOnly(fromModel) : defaultDate;

    return AiTransactionDraft(
      transactionType: type,
      date: date,
      categoryId: categoryId,
      walletId: walletId,
      goalId: null,
      amount: amount,
      note: AiExpenseNoteUtils.clampToWordCount(note, 5),
    );
  }

  Future<List<AiTransactionDraft>> _runParse(
    List<Content> contents,
    List<CategoryModel> categories,
    List<WalletModel> wallets,
    DateTime defaultDateIfNoModelDate,
  ) async {
    final allowedCat = _categoryIds(categories);
    final allowedWal = _walletIds(wallets);
    if (allowedCat.isEmpty) {
      throw StateError('Нет категорий для сопоставления.');
    }
    if (allowedWal.isEmpty) {
      throw StateError('Нет кошельков для сопоставления.');
    }

    final model = _model();
    final response = await model.generateContent(contents);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw StateError('Пустой ответ модели.');
    }

    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Ожидался JSON-объект: $text');
    }

    final items = <Map<String, dynamic>>[];
    final txs = decoded['transactions'];
    if (txs is List) {
      for (final e in txs) {
        if (e is Map<String, dynamic>) {
          items.add(e);
        }
      }
    }
    if (items.isEmpty) {
      final legacy = decoded['transaction'];
      if (legacy is Map<String, dynamic>) {
        items.add(legacy);
      }
    }
    if (items.isEmpty) {
      throw FormatException(
        'Ожидался непустой массив transactions (или объект transaction): $text',
      );
    }

    return items
        .map(
          (raw) => _mapToDraft(
            raw,
            allowedCat,
            allowedWal,
            defaultDateIfNoModelDate,
          ),
        )
        .toList();
  }

  @override
  Future<List<AiTransactionDraft>> parseTransactionFromText({
    required String userText,
    required List<CategoryModel> categories,
    required List<WalletModel> wallets,
  }) async {
    final visibleWallets = wallets.where((w) => !w.isHidden).toList();
    final userSection = AiPrompts.userContextSection(
      categories: _categoryMaps(categories),
      wallets: _walletMaps(visibleWallets),
      userContentDescription: 'Текст пользователя:\n${userText.trim()}',
    );
    return _runParse(
      [Content.text(userSection)],
      categories,
      visibleWallets,
      DateUtils.dateOnly(DateTime.now()),
    );
  }

  @override
  Future<List<AiTransactionDraft>> parseTransactionFromBytes({
    required List<int> bytes,
    required String mimeType,
    required List<CategoryModel> categories,
    required List<WalletModel> wallets,
    String? extraUserHint,
  }) async {
    final visibleWallets = wallets.where((w) => !w.isHidden).toList();
    final hint = extraUserHint == null || extraUserHint.isEmpty
        ? 'Распознай все операции по вложенному файлу (массив transactions).'
        : extraUserHint;
    final userSection = AiPrompts.userContextSection(
      categories: _categoryMaps(categories),
      wallets: _walletMaps(visibleWallets),
      userContentDescription: hint,
    );

    final uint8 = Uint8List.fromList(bytes);
    final content = Content.multi([
      TextPart(userSection),
      InlineDataPart(mimeType, uint8),
    ]);

    return _runParse(
      [content],
      categories,
      visibleWallets,
      DateUtils.dateOnly(DateTime.now()),
    );
  }
}
