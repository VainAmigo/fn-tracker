/// Запрос к модели для чата аналитики (мультитёрн, опционально один блок JSON).
abstract class AiAnalyticsChatRepository {
  /// [priorTurns]: пары user/model по порядку (уже без «ожидания»).
  /// Если [analyticsJsonPayload] не null — он добавляется к тексту **текущего** запроса пользователя один раз за сессию периода (решает клиент).
  Future<String> generateReply({
    required List<({String role, String text})> priorTurns,
    required String userMessage,
    String? analyticsJsonPayload,
    required String periodDescription,
  });
}
