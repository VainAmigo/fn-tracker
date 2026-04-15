import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/features/features.dart';

class AiGoalSavingsAdviceRepositoryImpl
    implements AiGoalSavingsAdviceRepository {
  AiGoalSavingsAdviceRepositoryImpl({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  GenerativeModel _model() {
    final firebaseAi = FirebaseAI.googleAI(auth: _auth);
    return firebaseAi.generativeModel(
      model: kAiGenerativeModelName,
      systemInstruction: Content.system(
        AiGoalSavingsAdvicePrompts.systemInstruction,
      ),
      generationConfig: GenerationConfig(temperature: 0.35),
    );
  }

  @override
  Future<String> generateAdvice({
    required String userQuestion,
    required String contextJsonPayload,
  }) async {
    final prompt =
        '''
Контекст пользователя (JSON):
$contextJsonPayload

Вопрос пользователя:
$userQuestion
''';

    final response = await _model().generateContent([Content.text(prompt)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw StateError('Пустой ответ модели.');
    }
    return text;
  }
}
