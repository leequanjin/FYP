import 'package:path/path.dart' as path;

class JournalEntry {
  final int? id;
  final String? content;
  final String date;
  final String mood;
  final List<String> tags;
  final List<String> imagePaths; // Local paths in SQLite / URLs in backup
  final List<String> thumbPaths; // Local paths in SQLite / URLs in backup

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    required this.mood,
    required this.tags,
    required this.imagePaths,
    required this.thumbPaths,
  });

  // ---------- For Local SQLite ----------
  factory JournalEntry.fromMap(
    Map<String, dynamic> map, {
    List<String> tags = const [],
  }) {
    final images =
        (map['images'] as String?)
            ?.split(',')
            .where((e) => e.isNotEmpty)
            .toList() ??
        const [];
    final thumbs =
        (map['thumbs'] as String?)
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

  // ---------- For Firestore Backup ----------
  factory JournalEntry.fromBackupMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['entryId'] != null ? int.tryParse(map['entryId']) : null,
      content: map['content'] as String?,
      date: map['date'] as String,
      mood: map['mood'] as String? ?? 'Neutral',
      tags:
          (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      imagePaths:
          (map['imagePaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      thumbPaths:
          (map['thumbPaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  // ---------- Save for Local SQLite ----------
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'content': content,
    'date': date,
    'mood': mood,
    'images': imagePaths.join(','), // Local file paths
    'thumbs': thumbPaths.join(','), // Local file paths
  };

  // ---------- Save for Firestore Backup ----------
  Map<String, dynamic> toBackupMap() => {
    'entryId':
        id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
    'content': content,
    'date': date,
    'mood': mood,
    'tags': tags,
    'imagePaths': imagePaths.map((p) => path.basename(p)).toList(),
    'thumbPaths': thumbPaths.map((p) => path.basename(p)).toList(),
  };

  // ---------- Copy Method for Easy Path Replacement ----------
  JournalEntry copyWith({
    int? id,
    String? content,
    String? date,
    String? mood,
    List<String>? tags,
    List<String>? imagePaths,
    List<String>? thumbPaths,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      imagePaths: imagePaths ?? this.imagePaths,
      thumbPaths: thumbPaths ?? this.thumbPaths,
    );
  }
}
