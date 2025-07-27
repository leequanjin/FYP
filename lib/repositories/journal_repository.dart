import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/db/tables/journal_tag_table.dart';
import 'package:moodly/db/tables/tag_table.dart';
import 'package:moodly/models/JournalEntry.dart';

class JournalRepository {
  static Future<void> upsert({
    required int? id,
    required String? content,
    required DateTime date,
    required String mood,
    required List<String> tags,
    List<String> imagePaths = const [],
    List<String> thumbPaths = const [],
  }) async {
    if (id == null) {
      await JournalTable.add(content, date, mood, imagePaths, thumbPaths);
      final inserted = await JournalTable.getByDate(date);
      if (inserted?.id == null) return;

      // tags
      final tagIds = <int>[];
      for (final t in tags) {
        tagIds.add(await TagTable.ensure(t));
      }
      await JournalTagTable.replaceTags(inserted!.id!, tagIds);
    } else {
      await JournalTable.update(id, content, date, mood, imagePaths, thumbPaths);

      // tags
      final tagIds = <int>[];
      for (final t in tags) {
        tagIds.add(await TagTable.ensure(t));
      }
      await JournalTagTable.replaceTags(id, tagIds);
    }
  }

  static Future<List<JournalEntry>> getAll() async {
    final rows = await JournalTable.getAll();
    final result = <JournalEntry>[];

    for (final e in rows) {
      if (e.id == null) continue;
      final tagIds = await JournalTagTable.getTagIdsForJournal(e.id!);
      final tagNames = await TagTable.getTagsForIds(tagIds);
      result.add(
        JournalEntry.fromMap(
          {
            'id': e.id,
            'content': e.content,
            'date': e.date,
            'mood': e.mood,
            'images': e.imagePaths.join(','),
            'thumbs': e.thumbPaths.join(','),
          },
          tags: tagNames,
        ),
      );
    }

    return result;
  }

  static Future<JournalEntry?> getByDate(DateTime date) async {
    final entry = await JournalTable.getByDate(date);
    if (entry == null || entry.id == null) return null;

    final tagIds = await JournalTagTable.getTagIdsForJournal(entry.id!);
    final tagNames = await TagTable.getTagsForIds(tagIds);

    return JournalEntry.fromMap(
      {
        'id': entry.id,
        'content': entry.content,
        'date': entry.date,
        'mood': entry.mood,
        'images': entry.imagePaths.join(','),
        'thumbs': entry.thumbPaths.join(','),
      },
      tags: tagNames,
    );
  }
}
