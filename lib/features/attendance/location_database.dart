import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationDatabase {
  static final LocationDatabase instance = LocationDatabase._init();
  static Database? _database;

  LocationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('location_cache.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE locations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  attendance_id TEXT NOT NULL,
  latitude TEXT NOT NULL,
  longitude TEXT NOT NULL,
  battery_percent TEXT NOT NULL,
  is_charging TEXT NOT NULL,
  timestamp TEXT NOT NULL
)
''');
  }

  Future<int> cacheLocation(Map<String, dynamic> locationData) async {
    final db = await instance.database;
    return await db.insert('locations', {
      ...locationData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getCachedLocations() async {
    final db = await instance.database;
    return await db.query('locations', orderBy: 'timestamp ASC');
  }

  Future<int> deleteLocation(int id) async {
    final db = await instance.database;
    return await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('locations');
  }
}
