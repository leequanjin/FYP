import 'package:intl/intl.dart';
import 'package:moodly/db/database_service.dart';
import 'package:moodly/models/Task.dart';
import 'package:sqflite/sqflite.dart';

class TaskTable {
  static const tableName = "tasks";
  static const columnId = "id";
  static const columnTitle = "title";
  static const columnDate = "date";
  static const columnStatus = "status";

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnDate TEXT,
        $columnStatus INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> add(String title, DateTime date) async {
    final db = await DatabaseService.instance.database;
    final task = Task(
      title: title,
      date: DateFormat('dd-MM-yyyy').format(date),
      status: 0,
    );
    await db.insert(tableName, task.toMap());
  }

  static Future<void> addISO(String title, String dateStr, int status) async {
    final db = await DatabaseService.instance.database;
    final task = Task(
      title: title,
      date: dateStr,
      status: status,
    );
    await db.insert(tableName, task.toMap());
  }

  static Future<List<Task>> getAll() async {
    final db = await DatabaseService.instance.database;
    final data = await db.query(tableName);
    return data.map((e) => Task.fromMap(e)).toList();
  }

  static Future<void> updateStatus(int id, int status) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      tableName,
      {columnStatus: status},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  static Future<void> update(int id, String title, DateTime date) async {
    final db = await DatabaseService.instance.database;

    final existing = await db.query(
      tableName,
      columns: [columnStatus],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    final currentStatus =
    existing.isNotEmpty ? existing.first[columnStatus] as int : 0;

    final updatedTask = Task(
      id: id,
      title: title,
      date: DateFormat('dd-MM-yyyy').format(date),
      status: currentStatus,
    );

    await db.update(
      tableName,
      updatedTask.toMap(),
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

  static Future<void> clearAll() async {
    final db = await DatabaseService.instance.database;
    await db.delete(tableName);
  }

  static Future<Task?> getLastInserted() async {
    final db = await DatabaseService.instance.database;
    final result = await db.query(
      tableName,
      orderBy: '$columnId DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Task.fromMap(result.first);
    }
    return null;
  }
}
