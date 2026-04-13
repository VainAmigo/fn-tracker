import 'package:fn_tracker/features/features.dart';

abstract class AiExpenseParseRepository {
  /// Список черновиков: одна или несколько операций после распознавания.
  Future<List<AiTransactionDraft>> parseTransactionFromText({
    required String userText,
    required List<CategoryModel> categories,
    required List<WalletModel> wallets,
  });

  Future<List<AiTransactionDraft>> parseTransactionFromBytes({
    required List<int> bytes,
    required String mimeType,
    required List<CategoryModel> categories,
    required List<WalletModel> wallets,
    String? extraUserHint,
  });
}
