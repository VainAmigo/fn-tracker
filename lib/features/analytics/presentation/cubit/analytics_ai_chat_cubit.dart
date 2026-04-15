import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/l10.dart';

class AnalyticsAiChatCubit extends Cubit<AnalyticsAiChatState> {
  AnalyticsAiChatCubit({required AiAnalyticsChatRepository repository})
    : _repository = repository,
      super(const AnalyticsAiChatState());

  final AiAnalyticsChatRepository _repository;

  /// Вызывать с экрана аналитики при загрузке данных или смене периода.
  void bindAnalyticsContext(AnalyticsModel data, DatePickerPeriod period) {
    final key = AnalyticsAiContextBuilder.periodContextKey(period);
    final json = AnalyticsAiContextBuilder.buildJsonString(data, period);
    final label = AnalyticsAiContextBuilder.periodDescription(period);

    if (state.boundPeriodKey == key && state.contextJson == json) {
      return;
    }

    final periodChanged =
        state.boundPeriodKey != null && state.boundPeriodKey != key;

    if (periodChanged) {
      emit(
        AnalyticsAiChatState(
          messages: state.messages,
          apiTurns: const [],
          boundPeriodKey: key,
          contextJson: json,
          periodLabel: label,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        boundPeriodKey: key,
        contextJson: json,
        periodLabel: label,
        clearError: true,
      ),
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    emit(state.copyWith(clearError: true));
  }

  void clearChat() {
    if (state.messages.isEmpty && state.apiTurns.isEmpty) return;
    emit(
      AnalyticsAiChatState(
        boundPeriodKey: state.boundPeriodKey,
        contextJson: state.contextJson,
        periodLabel: state.periodLabel,
      ),
    );
  }

  void resetForLogout() {
    emit(const AnalyticsAiChatState());
  }

  Future<void> sendUserMessage(String rawText, BuildContext context) async {
    final text = rawText.trim();
    if (text.isEmpty || state.isSending) return;

    final boundKey = state.boundPeriodKey;
    final contextJson = state.contextJson;
    final periodLabel = state.periodLabel ?? '';

    if (boundKey == null || contextJson == null || contextJson.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: context.l10n.noDataForSelectedPeriod,
        ),
      );
      return;
    }

    final attachPayload = state.lastAttachedPeriodKey != boundKey
        ? contextJson
        : null;

    final userMessage = AnalyticsAiChatMessage(
      role: AnalyticsAiMessageRole.user,
      text: text,
      sentAt: DateTime.now(),
    );
    final pending = const AnalyticsAiChatMessage(
      role: AnalyticsAiMessageRole.assistant,
      text: '',
      isPending: true,
    );

    emit(
      state.copyWith(
        messages: [...state.messages, userMessage, pending],
        isSending: true,
        clearError: true,
      ),
    );

    try {
      final reply = await _repository.generateReply(
        priorTurns: state.apiTurns,
        userMessage: text,
        analyticsJsonPayload: attachPayload,
        periodDescription: periodLabel,
      );

      final userLineForApi = AiAnalyticsChatMessageComposer.userMessageForModel(
        userMessage: text,
        analyticsJsonPayload: attachPayload,
        periodDescription: periodLabel,
      );

      final withoutPending = state.messages.where((m) => !m.isPending).toList();
      final assistant = AnalyticsAiChatMessage(
        role: AnalyticsAiMessageRole.assistant,
        text: reply,
        sentAt: DateTime.now(),
      );

      emit(
        state.copyWith(
          messages: [...withoutPending, assistant],
          apiTurns: [
            ...state.apiTurns,
            (role: 'user', text: userLineForApi),
            (role: 'model', text: reply),
          ],
          isSending: false,
          lastAttachedPeriodKey: attachPayload != null
              ? boundKey
              : state.lastAttachedPeriodKey,
        ),
      );
    } catch (e) {
      final withoutPending = state.messages.where((m) => !m.isPending).toList();
      emit(
        state.copyWith(
          messages: withoutPending,
          isSending: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
