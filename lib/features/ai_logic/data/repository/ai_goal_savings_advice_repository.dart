abstract class AiGoalSavingsAdviceRepository {
  Future<String> generateAdvice({
    required String userQuestion,
    required String contextJsonPayload,
  });
}
