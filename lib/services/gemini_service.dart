import 'package:google_generative_ai/google_generative_ai.dart';

enum BotPersonality { friendly, motivational, reflective }

class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;
  late ChatSession _chat;
  BotPersonality _currentPersonality;

  GeminiService(
    this.apiKey, {
    BotPersonality personality = BotPersonality.friendly,
  }) : _currentPersonality = personality {
    _model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);
    _initChat();
  }

  void _initChat() {
    final prompt = _getPromptForPersonality(_currentPersonality);
    _chat = _model.startChat(history: [Content.text(prompt)]);
  }

  void changePersonality(BotPersonality newPersonality) {
    _currentPersonality = newPersonality;
    _initChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }

  String _getPromptForPersonality(BotPersonality personality) {
    switch (personality) {
      case BotPersonality.motivational:
        return 'You are a motivating and encouraging journaling assistant. '
            'Help the user to identify and achieve their goals by providing support, guidance, and accountability. '
            'Keep your responses short, similar to an actual text message, and use minimal emojis. '
            'Never give medical advice.';
      case BotPersonality.reflective:
        return 'You are a deep and thoughtful journaling assistant. '
            'You encourage self-reflection and introspection. '
            'Ask meaningful follow-up questions and keep a calm tone. '
            'Keep your responses short, similar to an actual text message, and use minimal emojis. '
            'Never give medical advice.';
      case BotPersonality.friendly:
        return 'You are a friendly and supportive journaling assistant. '
            'Always respond with kindness and help users reflect on their thoughts. '
            'Try to keep the user engaged by sometimes subtly prompting them when its appropriate. '
            'Keep your responses short, similar to an actual text message, and use minimal emojis. '
            'Never give medical advice.';
    }
  }
}
