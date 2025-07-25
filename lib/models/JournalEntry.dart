class JournalEntry {
  final int? id;
  final String? content;
  final String date;
  final String mood;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    required this.mood,
    required this.tags,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map, {List<String> tags = const []}) {
    return JournalEntry(
      id: map['id'] as int?,
      content: map['content'] as String?,
      date: map['date'] as String,
      mood: map['mood'] as String? ?? 'Okay',
      tags: tags,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'content': content,
    'date': date,
    'mood': mood,
  };
}
