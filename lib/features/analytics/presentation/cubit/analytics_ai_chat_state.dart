import 'package:fn_tracker/features/features.dart';

/// История для API: чередование user / model с полным текстом (включая JSON в первом user).
typedef AnalyticsAiApiTurn = ({String role, String text});

class AnalyticsAiChatState {
  const AnalyticsAiChatState({
    this.messages = const [],
    this.apiTurns = const [],
    this.isSending = false,
    this.boundPeriodKey,
    this.contextJson,
    this.periodLabel,
    this.lastAttachedPeriodKey,
    this.errorMessage,
  });

  final List<AnalyticsAiChatMessage> messages;
  final List<AnalyticsAiApiTurn> apiTurns;
  final bool isSending;

  /// Текущий период на экране аналитики.
  final String? boundPeriodKey;
  final String? contextJson;
  final String? periodLabel;

  /// Последний период, для которого JSON уже был добавлен к запросу.
  final String? lastAttachedPeriodKey;
  final String? errorMessage;

  AnalyticsAiChatState copyWith({
    List<AnalyticsAiChatMessage>? messages,
    List<AnalyticsAiApiTurn>? apiTurns,
    bool? isSending,
    String? boundPeriodKey,
    String? contextJson,
    String? periodLabel,
    String? lastAttachedPeriodKey,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnalyticsAiChatState(
      messages: messages ?? this.messages,
      apiTurns: apiTurns ?? this.apiTurns,
      isSending: isSending ?? this.isSending,
      boundPeriodKey: boundPeriodKey ?? this.boundPeriodKey,
      contextJson: contextJson ?? this.contextJson,
      periodLabel: periodLabel ?? this.periodLabel,
      lastAttachedPeriodKey:
          lastAttachedPeriodKey ?? this.lastAttachedPeriodKey,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
