class JournalEntry {
  final int? id;
  final String? content;
  final String date;
  final String mood;
  final List<String> tags;
  final List<String> imagePaths;
  final List<String> thumbPaths;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    required this.mood,
    required this.tags,
    required this.imagePaths,
    required this.thumbPaths,
  });

  factory JournalEntry.fromMap(
      Map<String, dynamic> map, {
        List<String> tags = const [],
      }) {
    final images = (map['images'] as String?)
        ?.split(',')
        .where((e) => e.isNotEmpty)
        .toList() ??
        const [];
    final thumbs = (map['thumbs'] as String?)
        ?.split(',')
        .where((e) => e.isNotEmpty)
        .toList() ??
        const [];

    return JournalEntry(
      id: map['id'] as int?,
      content: map['content'] as String?,
      date: map['date'] as String,
      mood: map['mood'] as String? ?? 'Neutral',
      tags: tags,
      imagePaths: images,
      thumbPaths: thumbs,
    );
  }

  factory JournalEntry.fromBackupMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as int?,
      content: map['content'] as String?,
      date: map['date'] as String,
      mood: map['mood'] as String? ?? 'Neutral',
      tags: (map['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],
      imagePaths: (map['imagePaths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],
      thumbPaths: (map['thumbPaths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'content': content,
    'date': date,
    'mood': mood,
    'images': imagePaths.join(','),
    'thumbs': thumbPaths.join(','),
  };

  Map<String, dynamic> toBackupMap() => {
    'id': id,
    'content': content,
    'date': date,
    'mood': mood,
    'tags': tags,
    'imagePaths': imagePaths,
    'thumbPaths': thumbPaths,
  };
}
