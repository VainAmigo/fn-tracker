/// Текст пользовательского сообщения для API и для сохранения в истории диалога.
abstract final class AiAnalyticsChatMessageComposer {
  static String userMessageForModel({
    required String userMessage,
    String? analyticsJsonPayload,
    required String periodDescription,
  }) {
    if (analyticsJsonPayload == null || analyticsJsonPayload.isEmpty) {
      return userMessage;
    }
    return '''
Период (для справки): $periodDescription

Ниже JSON с агрегированной аналитикой за этот период. Используй эти цифры для ответов в этом диалоге.

$analyticsJsonPayload

Вопрос пользователя:
$userMessage
'''.trim();
  }
}
