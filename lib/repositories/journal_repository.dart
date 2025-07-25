import 'package:moodly/db/database_service.dart';
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
  }) async {
    if (id == null) {
      await JournalTable.add(content, date, mood);
      final inserted = await JournalTable.getByDate(date);
      if (inserted == null || inserted.id == null) return;

      final tagIds = <int>[];
      for (final t in tags) {
        tagIds.add(await TagTable.ensure(t));
      }
      await JournalTagTable.replaceTags(inserted.id!, tagIds);
    } else {
      await JournalTable.update(id, content, date, mood);
      final tagIds = <int>[];
      for (final t in tags) {
        tagIds.add(await TagTable.ensure(t));
      }
      await JournalTagTable.replaceTags(id, tagIds);
    }
  }

  static Future<List<JournalEntry>> getAll() async {
    final entries = await JournalTable.getAll();
    final result = <JournalEntry>[];

    for (final e in entries) {
      if (e.id == null) continue;
      final tagIds = await JournalTagTable.getTagIdsForJournal(e.id!);
      final tagNames = await TagTable.getTagsForIds(tagIds);
      result.add(
        JournalEntry.fromMap(
          e.toMap(),
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

    return JournalEntry.fromMap(entry.toMap(), tags: tagNames);
  }

  static Future<List<JournalEntry>> getByTag(String tagName) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT j.*
      FROM journals j
      JOIN journal_tags jt ON jt.journal_id = j.id
      JOIN tags t ON t.id = jt.tag_id
      WHERE t.name = ?
      ORDER BY j.date DESC
    ''', [tagName]);

    final result = <JournalEntry>[];
    for (final row in rows) {
      final id = row['id'] as int?;
      final tags = id == null
          ? <String>[]
          : await TagTable.getTagsForIds(
        await JournalTagTable.getTagIdsForJournal(id),
      );

      result.add(JournalEntry.fromMap(row, tags: tags));
    }
    return result;
  }
}
