import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb('iron_progress.db');
    return _database!;
  }

  Future<Database> _initDb(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercise_catalog (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        exercise_id TEXT PRIMARY KEY,
        workout_id TEXT NOT NULL,
        name TEXT NOT NULL,
        sets_target INTEGER NOT NULL,
        reps_target INTEGER NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
  CREATE TABLE workout_history (
    history_id TEXT PRIMARY KEY,
    workout_id TEXT NOT NULL,
    workout_name TEXT NOT NULL,
    date_time TEXT NOT NULL
  )
''');

    await db.execute('''
  CREATE TABLE exercise_history_sets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    history_id TEXT NOT NULL,
    exercise_name TEXT NOT NULL,
    set_number INTEGER NOT NULL,
    weight_used TEXT NOT NULL,
    FOREIGN KEY (history_id) REFERENCES workout_history (history_id) ON DELETE CASCADE
  )
''');
  }
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
