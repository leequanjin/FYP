import 'package:intl/intl.dart';
import 'package:moodly/db/database_service.dart';
import 'package:moodly/models/JournalEntry.dart';
import 'package:sqflite/sqflite.dart';

class JournalTable {
  static const tableName = "journals";
  static const columnId = "id";
  static const columnContent = "content";
  static const columnDate = "date";
  static const columnMood = "mood";
  static const columnImages = "images";
  static const columnThumbs = "thumbs";

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnContent TEXT,
        $columnDate TEXT NOT NULL,
        $columnMood TEXT NOT NULL DEFAULT 'Neutral',
        $columnImages TEXT NOT NULL DEFAULT '',
        $columnThumbs TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  static Future<void> add(
      String? content,
      DateTime date,
      String? selectedMood,
      List<String> imagePaths,
      List<String> thumbPaths,
      ) async {
    final db = await DatabaseService.instance.database;
    await db.insert(tableName, {
      columnContent: content,
      columnDate: DateFormat('dd-MM-yyyy').format(date),
      columnMood: selectedMood ?? 'Neutral',
      columnImages: imagePaths.join(','),
      columnThumbs: thumbPaths.join(','),
    });
  }

  static Future<void> addISO(
      String? content,
      String dateStr,
      String? selectedMood,
      List<String> imagePaths,
      List<String> thumbPaths,
      ) async {
    final db = await DatabaseService.instance.database;
    await db.insert(tableName, {
      columnContent: content,
      columnDate: dateStr,
      columnMood: selectedMood ?? 'Neutral',
      columnImages: imagePaths.join(','),
      columnThumbs: thumbPaths.join(','),
    });
  }


  static Future<List<JournalEntry>> getAll() async {
    final db = await DatabaseService.instance.database;
    final data = await db.query(tableName);
    return data.map((e) => JournalEntry.fromMap(e)).toList();
  }

  static Future<void> update(
      int id,
      String? content,
      DateTime date,
      String? selectedMood,
      List<String> imagePaths,
      List<String> thumbPaths,
      ) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      tableName,
      {
        columnContent: content,
        columnDate: DateFormat('dd-MM-yyyy').format(date),
        columnMood: selectedMood ?? 'Neutral',
        columnImages: imagePaths.join(','),
        columnThumbs: thumbPaths.join(','),
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> delete(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  static Future<JournalEntry?> getByDate(DateTime date) async {
    final db = await DatabaseService.instance.database;
    final formatted = DateFormat('dd-MM-yyyy').format(date);
    final data = await db.query(
      tableName,
      where: '$columnDate = ?',
      whereArgs: [formatted],
    );

    if (data.isNotEmpty) {
      return JournalEntry.fromMap(data.first);
    } else {
      return null;
    }
  }

  static Future<void> clearAll() async {
    final db = await DatabaseService.instance.database;
    await db.delete('journals');
  }

  static Future<JournalEntry?> getLastInserted() async {
    final db = await DatabaseService.instance.database;
    final result = await db.query(
      'journals',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return JournalEntry.fromMap(result.first);
    }
    return null;
  }
}