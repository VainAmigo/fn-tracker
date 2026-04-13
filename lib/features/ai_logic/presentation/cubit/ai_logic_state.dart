part of 'ai_logic_cubit.dart';

sealed class AiLogicState {
  const AiLogicState({
    required this.entryMode,
    this.editableText = '',
    this.attachmentBytes,
    this.attachmentMime,
    this.attachmentName,
    this.drafts = const [],
    this.errorMessage,
  });

  final AiLogicEntryMode entryMode;
  final String editableText;
  final List<int>? attachmentBytes;
  final String? attachmentMime;
  final String? attachmentName;
  final List<AiTransactionDraft> drafts;
  final String? errorMessage;

  AiLogicInputState toInput({
    String? editableText,
    List<int>? attachmentBytes,
    String? attachmentMime,
    String? attachmentName,
    bool clearAttachment = false,
    String? errorMessage,
  }) {
    return AiLogicInputState(
      entryMode: entryMode,
      editableText: editableText ?? this.editableText,
      attachmentBytes: clearAttachment ? null : (attachmentBytes ?? this.attachmentBytes),
      attachmentMime: clearAttachment ? null : (attachmentMime ?? this.attachmentMime),
      attachmentName: clearAttachment ? null : (attachmentName ?? this.attachmentName),
      drafts: drafts,
      errorMessage: errorMessage,
    );
  }
}

final class AiLogicInitial extends AiLogicState {
  const AiLogicInitial({
    required super.entryMode,
    super.editableText,
    super.attachmentBytes,
    super.attachmentMime,
    super.attachmentName,
    super.errorMessage,
  }) : super(drafts: const []);
}

final class AiLogicInputState extends AiLogicState {
  const AiLogicInputState({
    required super.entryMode,
    super.editableText,
    super.attachmentBytes,
    super.attachmentMime,
    super.attachmentName,
    super.drafts,
    super.errorMessage,
  });
}

final class AiLogicParsing extends AiLogicState {
  const AiLogicParsing({
    required super.entryMode,
    required super.editableText,
    super.attachmentBytes,
    super.attachmentMime,
    super.attachmentName,
  }) : super(drafts: const []);
}

final class AiLogicDraftsReady extends AiLogicState {
  const AiLogicDraftsReady({
    required super.entryMode,
    required super.editableText,
    super.attachmentBytes,
    super.attachmentMime,
    super.attachmentName,
    required super.drafts,
  });
}
