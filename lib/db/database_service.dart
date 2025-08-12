import 'package:moodly/constants/default_tags.dart';
import 'package:moodly/db/tables/journal_table.dart';
import 'package:moodly/db/tables/journal_tag_table.dart';
import 'package:moodly/db/tables/tag_table.dart';
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
      version: 3,
      onCreate: (db, version) async {
        await TaskTable.createTable(db);
        await JournalTable.createTable(db);
        await TagTable.createTable(db);
        await TagTable.seedDefaults(db, kDefaultTags);
        await JournalTagTable.createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE ${JournalTable.tableName} ADD COLUMN ${JournalTable.columnImages} TEXT NOT NULL DEFAULT ''",
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE ${JournalTable.tableName} ADD COLUMN ${JournalTable.columnThumbs} TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
  }
}
