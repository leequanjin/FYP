import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moodly/services/gemini_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  late GeminiService _gemini;
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  String _selectedCompanion = 'Chill Chat Companion';

  final List<String> _companions = [
    'Chill Chat Companion',
    'Motivational Coach',
    'Deep Thinker',
  ];

  BotPersonality _getPersonalityFromLabel(String label) {
    switch (label) {
      case 'Motivational Coach':
        return BotPersonality.motivational;
      case 'Deep Thinker':
        return BotPersonality.reflective;
      case 'Chill Chat Companion':
        return BotPersonality.friendly;
      default:
        return BotPersonality.friendly;
    }
  }

  @override
  void initState() {
    super.initState();
    _gemini = GeminiService(_apiKey);

    _messages.add({
      'sender': 'gemini',
      'text': "Hey there! I'm your journal companion.",
    });

    _messages.add({'sender': 'gemini', 'text': "How was your day?"});
  }

  void _sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': userInput});
      _controller.clear();
    });

    final aiResponse = await _gemini.sendMessage(userInput);

    setState(() {
      _messages.add({'sender': 'gemini', 'text': aiResponse});
    });
  }

  void _summarizeAndExport() async {
    final chatHistory = _messages
        .map(
          (msg) =>
              "${msg['sender'] == 'user' ? 'User' : 'Gemini'}: ${msg['text']}",
        )
        .join('\n');

    final prompt =
        '''
    Based on the following journaling-style chat between a user and their companion:
    
    $chatHistory
    
    1. Write a short journal-style summary of the user's day from the perspective of the user.
    2. Suggest a single mood that best represents how the user felt overall from the following :
      'Awesome!', 
      'Great', 
      'Neutral', 
      'Bad',
      'Terrible...'.
    3. Suggest 1–5 tags that describe what the user talked about from the following :
      'Work',
      'Family',
      'Health',
      'Study',
      'Gratitude',
      'Reflection',
      'Travel',
      'Exercise',
      'Productivity',
      'Mood',
      'Relationships',
      'Finance',
      'Idea',
      'Goal',
      'Food'
      'Friends'
    
    Respond using this exact format (do not include extra explanation):
    
    Summary: <summary text>
    Mood: <single mood word>
    Tags: <comma-separated tags>
    ''';

    final response = await _gemini.sendMessage(prompt);

    if (!mounted) return;

    final lines = response.split('\n');
    String summary = '';
    String mood = '';
    List<String> tags = [];

    for (var line in lines) {
      if (line.startsWith('Summary:')) {
        summary = line.replaceFirst('Summary:', '').trim();
      } else if (line.startsWith('Mood:')) {
        mood = line.replaceFirst('Mood:', '').trim();
      } else if (line.startsWith('Tags:')) {
        tags = line
            .replaceFirst('Tags:', '')
            .split(',')
            .map((tag) => tag.trim())
            .toList();
      }
    }

    Navigator.pop(context, {'summary': summary, 'mood': mood, 'tags': tags});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCompanion,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCompanion = value;
                      });
                      final newPersonality = _getPersonalityFromLabel(value);
                      _gemini.changePersonality(newPersonality);
                    }
                  },
                  items: _companions.map((companion) {
                    return DropdownMenuItem<String>(
                      value: companion,
                      child: Text(
                        companion,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize),
            tooltip: "Summarize & Export",
            onPressed: _summarizeAndExport,
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['sender'] == 'user';

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      isUser ? 60 : 8,
                      4,
                      isUser ? 8 : 60,
                      4,
                    ),
                    child: Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg['text']!,
                          style: TextStyle(
                            color: isUser
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
