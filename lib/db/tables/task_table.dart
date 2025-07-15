import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/Task.dart';
import '../database_service.dart';

class TaskTable {
  static const tableName = "tasks";

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT,
        status INTEGER NOT NULL
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

  static Future<List<Task>> getAll() async {
    final db = await DatabaseService.instance.database;
    final data = await db.query(tableName);

    return data.map((e) => Task.fromMap(e)).toList();
  }

  static Future<void> updateStatus(int id, int status) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      tableName,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> update(int id, String title, DateTime date) async {
    final db = await DatabaseService.instance.database;

    final updatedTask = Task(
      id: id,
      title: title,
      date: DateFormat('dd-MM-yyyy').format(date),
      status: 0, // Optional: retain current status or retrieve first
    );

    await db.update(
      tableName,
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> delete(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
