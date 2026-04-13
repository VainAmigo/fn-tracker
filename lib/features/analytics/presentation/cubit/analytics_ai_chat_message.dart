enum AnalyticsAiMessageRole { user, assistant }

class AnalyticsAiChatMessage {
  const AnalyticsAiChatMessage({
    required this.role,
    required this.text,
    this.sentAt,
    this.isPending = false,
  });

  final AnalyticsAiMessageRole role;
  final String text;
  final DateTime? sentAt;
  final bool isPending;
}
