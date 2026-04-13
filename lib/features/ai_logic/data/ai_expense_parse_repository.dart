import 'package:fn_tracker/features/ai_logic/data/models/ai_transaction_draft.dart';
import 'package:fn_tracker/features/transactions/data/models/category_model.dart';
import 'package:fn_tracker/features/wallet/data/models/wallet_model.dart';

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
