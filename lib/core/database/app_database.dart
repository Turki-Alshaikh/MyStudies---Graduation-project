import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('my1studies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(dbPath, filePath);

    return await openDatabase(
      dbFilePath,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add notifications table in version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          color INTEGER NOT NULL,
          read INTEGER NOT NULL DEFAULT 0,
          reminderId TEXT,
          eventId TEXT,
          courseId TEXT
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Courses table
    await db.execute('''
      CREATE TABLE courses(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        creditHours INTEGER NOT NULL,
        grade TEXT,
        room TEXT,
        building TEXT
      )
    ''');

    // Course meetings table
    await db.execute('''
      CREATE TABLE course_meetings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseId TEXT NOT NULL,
        weekday INTEGER NOT NULL,
        startMinutes INTEGER NOT NULL,
        endMinutes INTEGER NOT NULL,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE events(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        course TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        type TEXT NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE reminders(
        id TEXT PRIMARY KEY,
        eventId TEXT NOT NULL,
        courseId TEXT,
        leadTimeMinutes INTEGER NOT NULL,
        triggerTime TEXT NOT NULL,
        notificationId INTEGER NOT NULL,
        FOREIGN KEY (eventId) REFERENCES events (id) ON DELETE CASCADE
      )
    ''');

    // Resources table
    await db.execute('''
      CREATE TABLE resources(
        id TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        url TEXT NOT NULL,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // GPA expected grades table
    await db.execute('''
      CREATE TABLE expected_grades(
        courseId TEXT PRIMARY KEY,
        grade TEXT NOT NULL,
        FOREIGN KEY (courseId) REFERENCES courses (id) ON DELETE CASCADE
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        color INTEGER NOT NULL,
        read INTEGER NOT NULL DEFAULT 0,
        reminderId TEXT,
        eventId TEXT,
        courseId TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> deleteAllData() async {
    final db = await instance.database;

    // Delete all data from all tables
    await db.delete('course_meetings');
    await db.delete('reminders');
    await db.delete('events');
    await db.delete('resources');
    await db.delete('expected_grades');
    await db.delete('courses');
    await db.delete('settings');
    await db.delete('notifications');
  }
}
