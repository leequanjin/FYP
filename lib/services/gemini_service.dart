import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel _model;
  final ChatSession _chat;

  GeminiService(String apiKey)
      : _model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: apiKey,
  ),
        _chat = GenerativeModel(
          model: 'gemini-2.5-flash-lite',
          apiKey: apiKey,
        ).startChat(history: [
          Content.text(
            'You are a friendly and supportive journaling assistant. '
                'Always respond with kindness, help users reflect on their thoughts, '
                'and never provide medical advice.',
          )
        ]);

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
