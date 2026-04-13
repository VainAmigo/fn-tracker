import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/features.dart';

part 'ai_logic_state.dart';

class AiLogicCubit extends Cubit<AiLogicState> {
  AiLogicCubit({
    required AiLogicEntryMode entryMode,
    required CategoryRepository categoryRepo,
    required FinanceRepository financeRepo,
    required AiExpenseParseRepository parseRepo,
    required TransactionsRepository transactionsRepo,
  }) : _categoryRepo = categoryRepo,
       _financeRepo = financeRepo,
       _parseRepo = parseRepo,
       _transactionsRepo = transactionsRepo,
       super(AiLogicInitial(entryMode: entryMode));

  final CategoryRepository _categoryRepo;
  final FinanceRepository _financeRepo;
  final AiExpenseParseRepository _parseRepo;
  final TransactionsRepository _transactionsRepo;

  void setEditableText(String text) {
    final s = state;
    if (s is AiLogicDraftsReady) return;
    emit(s.toInput(editableText: text));
  }

  void setAttachment({
    required List<int> bytes,
    required String mimeType,
    String? name,
  }) {
    final s = state;
    if (s is AiLogicDraftsReady) return;
    emit(
      s.toInput(
        attachmentBytes: bytes,
        attachmentMime: mimeType,
        attachmentName: name,
      ),
    );
  }

  void clearAttachment() {
    final s = state;
    if (s is AiLogicDraftsReady) return;
    emit(s.toInput(clearAttachment: true));
  }

  void resetError() {
    final s = state;
    if (s.errorMessage == null) return;
    emit(s.toInput(errorMessage: null));
  }

  Future<void> runParse() async {
    final base = state;
    final text = base.editableText.trim();
    final bytes = base.attachmentBytes;
    final mime = base.attachmentMime;

    if (bytes == null || bytes.isEmpty) {
      if (text.isEmpty) {
        emit(
          base.toInput(
            errorMessage: 'Введите текст или выберите файл.',
          ),
        );
        return;
      }
    }

    emit(
      AiLogicParsing(
        entryMode: base.entryMode,
        editableText: base.editableText,
        attachmentBytes: base.attachmentBytes,
        attachmentMime: base.attachmentMime,
        attachmentName: base.attachmentName,
      ),
    );

    try {
      final categories = await _categoryRepo.getUserCategories();
      final wallets = await _financeRepo.getWallets();

      final drafts = bytes != null && bytes.isNotEmpty && mime != null
          ? await _parseRepo.parseTransactionFromBytes(
              bytes: bytes,
              mimeType: mime,
              categories: categories,
              wallets: wallets,
            )
          : await _parseRepo.parseTransactionFromText(
              userText: text,
              categories: categories,
              wallets: wallets,
            );

      emit(
        AiLogicDraftsReady(
          entryMode: base.entryMode,
          editableText: base.editableText,
          attachmentBytes: base.attachmentBytes,
          attachmentMime: base.attachmentMime,
          attachmentName: base.attachmentName,
          drafts: drafts,
        ),
      );
    } catch (e) {
      emit(
        AiLogicInputState(
          entryMode: base.entryMode,
          editableText: base.editableText,
          attachmentBytes: base.attachmentBytes,
          attachmentMime: base.attachmentMime,
          attachmentName: base.attachmentName,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void updateDraft(int index, AiTransactionDraft draft) {
    final s = state;
    if (s is! AiLogicDraftsReady) return;
    final list = List<AiTransactionDraft>.from(s.drafts);
    if (index < 0 || index >= list.length) return;
    list[index] = draft;
    emit(
      AiLogicDraftsReady(
        entryMode: s.entryMode,
        editableText: s.editableText,
        attachmentBytes: s.attachmentBytes,
        attachmentMime: s.attachmentMime,
        attachmentName: s.attachmentName,
        drafts: list,
      ),
    );
  }

  void backToInput() {
    final s = state;
    emit(
      AiLogicInputState(
        entryMode: s.entryMode,
        editableText: s.editableText,
        attachmentBytes: s.attachmentBytes,
        attachmentMime: s.attachmentMime,
        attachmentName: s.attachmentName,
        errorMessage: null,
      ),
    );
  }

  Future<List<TransactionModel>> saveAllDrafts({
    required String currencyCode,
  }) async {
    final s = state;
    if (s is! AiLogicDraftsReady) {
      throw StateError('Нет черновиков для сохранения.');
    }

    for (final d in s.drafts) {
      if (!d.isReadyToSave) {
        throw StateError(
          'Заполните сумму, кошелёк или цель; для расхода укажите категорию.',
        );
      }
    }

    final created = <TransactionModel>[];
    for (final draft in s.drafts) {
      final tx = draft.toTransactionModel(currencyCode: currencyCode);
      created.add(await _transactionsRepo.addTransaction(transaction: tx));
    }
    return created;
  }
}
