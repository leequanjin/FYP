import 'package:intl/intl.dart';
import 'package:moodly/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksTitleColumnName = "title";
  final String _tasksDateColumnName = "date";
  final String _tasksStatusColumnName = "status";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_tasksTableName (
          $_tasksIdColumnName INTEGER PRIMARY KEY,
          $_tasksTitleColumnName TEXT NOT NULL,
          $_tasksDateColumnName TEXT,
          $_tasksStatusColumnName INTEGER NOT NULL
        )
        ''');
      },
    );
    return database;
  }

  Future<void> addTask(String title, DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('dd-MM-yyyy').format(date);
    await db.insert(_tasksTableName, {
      _tasksTitleColumnName: title,
      _tasksDateColumnName: formattedDate,
      _tasksStatusColumnName: 0,
    });
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);
    return data.map((e) => Task(
      id: e["id"] as int,
      status: e["status"] as int,
      title: e["title"] as String,
      date: e["date"] as String,
    )).toList();
  }

  Future<void> updateTaskStatus(int taskId, int newStatus) async {
    final db = await database;
    await db.update(
      _tasksTableName,
      {_tasksStatusColumnName: newStatus},
      where: '$_tasksIdColumnName = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> deleteTask(int taskId) async {
    final db = await database;
    await db.delete(
      _tasksTableName,
      where: '$_tasksIdColumnName = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> updateTask(int id, String title, DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('dd-MM-yyyy').format(date);
    await db.update(
      _tasksTableName,
      {
        _tasksTitleColumnName: title,
        _tasksDateColumnName: formattedDate,
      },
      where: '$_tasksIdColumnName = ?',
      whereArgs: [id],
    );
  }
}
