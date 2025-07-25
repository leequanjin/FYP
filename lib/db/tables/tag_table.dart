import 'package:moodly/db/database_service.dart';
import 'package:sqflite/sqflite.dart';

class TagTable {
  static const tableName = 'tags';
  static const columnId = 'id';
  static const columnName = 'name';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL UNIQUE
      )
    ''');
  }

  static Future<int> ensure(String name) async {
    final db = await DatabaseService.instance.database;
    final existing = await db.query(
      tableName,
      where: '$columnName = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first[columnId] as int;
    }

    return await db.insert(tableName, {columnName: name});
  }

  static Future<List<String>> getTagsForIds(List<int> tagIds) async {
    if (tagIds.isEmpty) return [];
    final db = await DatabaseService.instance.database;
    final res = await db.query(
      tableName,
      where: '$columnId IN (${List.filled(tagIds.length, '?').join(',')})',
      whereArgs: tagIds,
    );
    return res.map((e) => e[columnName] as String).toList();
  }

  static Future<void> seedDefaults(Database db, List<String> names) async {
    for (final n in names) {
      await db.insert(
        tableName,
        {columnName: n},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  static Future<List<String>> getAllNames() async {
    final db = await DatabaseService.instance.database;
    final res = await db.query(tableName, orderBy: columnName);
    return res.map((e) => e[columnName] as String).toList();
  }
}
