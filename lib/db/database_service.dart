import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/db/tables/task_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), "master_db.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await TaskTable.createTable(db);
        await JournalTable.createTable(db);
      },
    );
  }
}
