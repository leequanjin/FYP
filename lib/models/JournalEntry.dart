class JournalEntry {
  final int? id;
  final String? content;
  final String date;
  final String mood;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    required this.mood,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as int?,
      content: map['content'] as String?,
      date: map['date'] as String,
      mood: map['mood'] as String? ?? 'Okay',
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'content': content,
    'date': date,
    'mood': mood,
  };
}
