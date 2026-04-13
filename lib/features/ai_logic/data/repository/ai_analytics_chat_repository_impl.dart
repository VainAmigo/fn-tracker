import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fn_tracker/features/features.dart';

class AiAnalyticsChatRepositoryImpl implements AiAnalyticsChatRepository {
  AiAnalyticsChatRepositoryImpl({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  GenerativeModel _model() {
    final firebaseAi = FirebaseAI.googleAI(auth: _auth);
    return firebaseAi.generativeModel(
      model: kAiGenerativeModelName,
      systemInstruction: Content.system(AiAnalyticsChatPrompts.systemInstruction),
      generationConfig: GenerationConfig(temperature: 0.35),
    );
  }

  @override
  Future<String> generateReply({
    required List<({String role, String text})> priorTurns,
    required String userMessage,
    String? analyticsJsonPayload,
    required String periodDescription,
  }) async {
    final contents = <Content>[];
    for (final t in priorTurns) {
      final role = t.role.toLowerCase();
      if (role == 'user') {
        contents.add(Content('user', [TextPart(t.text)]));
      } else if (role == 'model' || role == 'assistant') {
        contents.add(Content.model([TextPart(t.text)]));
      }
    }

    final composed = AiAnalyticsChatMessageComposer.userMessageForModel(
      userMessage: userMessage,
      analyticsJsonPayload: analyticsJsonPayload,
      periodDescription: periodDescription,
    );
    contents.add(Content.text(composed));

    final model = _model();
    final response = await model.generateContent(contents);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw StateError('Пустой ответ модели.');
    }
    return text;
  }
}
