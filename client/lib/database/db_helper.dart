import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// db ad
class DbHelper {
  static Database? _database;

  static Future<Database> getDb() async {
    // if database is already created, return it
    if (_database != null) {
      return _database!;
    }
    // else, we create the db and return it
    _database = await _createDB();
    return _database!;
  }

  static Future<Database> _createDB() async {
    final dbPath = await getDatabasesPath();
    const dbName = 'deafconnect.db';

    var database = await openDatabase(
      join(dbPath, dbName),
      version: 5,
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
      },
      onCreate: (Database database, int version) async {
        await _createTables(database);
      },
    );
    return database;
  }

  static Future _createTables(Database database) async {
    // CREATING TRANSCRIPTS TABLE
    await database.execute("""
      CREATE TABLE IF NOT EXISTS transcripts (
        transcript_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        transcript_name VARCHAR(255) NOT NULL,
        date_created STRING
      );
    """);

    // CREATING MESSAGES TABLE
    await database.execute("""
      CREATE TABLE IF NOT EXISTS messages (
        message_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        transcript_id INT,
        message_content TEXT,
        is_received BOOLEAN,
        message_date STRING,
        ms_since_epoch INTEGER,
        FOREIGN KEY (transcript_id) REFERENCES transcripts(transcript_id)
      );
    """);

    // CREATING SHORTCUTS TABLE
    await database.execute("""
    CREATE TABLE IF NOT EXISTS shortcuts (
      shortcut_order INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      shortcut_name VARCHAR(255)
    );  
    """);

    // CREATING AVATAR MESSAGES TABLE
    await database.execute("""
    CREATE TABLE IF NOT EXISTS avatar_messages (
      avatar_message_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      avatar_message VARCHAR(255)
    );  
    """);
  }
}
