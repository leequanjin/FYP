import 'package:moodly/db/database_service.dart';
import 'package:sqflite/sqflite.dart';

class JournalTagTable {
  static const tableName = 'journal_tags';
  static const columnJournalId = 'journal_id';
  static const columnTagId = 'tag_id';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnJournalId INTEGER NOT NULL,
        $columnTagId INTEGER NOT NULL,
        PRIMARY KEY ($columnJournalId, $columnTagId),
        FOREIGN KEY ($columnJournalId) REFERENCES journals(id) ON DELETE CASCADE,
        FOREIGN KEY ($columnTagId) REFERENCES tags(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> replaceTags(int journalId, List<int> tagIds) async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        tableName,
        where: '$columnJournalId = ?',
        whereArgs: [journalId],
      );

      for (final tagId in tagIds) {
        await txn.insert(tableName, {
          columnJournalId: journalId,
          columnTagId: tagId,
        });
      }
    });
  }

  static Future<List<int>> getTagIdsForJournal(int journalId) async {
    final db = await DatabaseService.instance.database;
    final res = await db.query(
      tableName,
      columns: [columnTagId],
      where: '$columnJournalId = ?',
      whereArgs: [journalId],
    );
    return res.map((e) => e[columnTagId] as int).toList();
  }

  static Future<void> clearAll() async {
    final db = await DatabaseService.instance.database;
    await db.delete('journal_tags');
  }
}
