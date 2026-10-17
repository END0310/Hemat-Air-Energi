import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/device_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hemat_energi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        power_watt REAL NOT NULL,
        quantity INTEGER NOT NULL,
        daily_hours REAL NOT NULL
      )
    ''');
  }

  Future<int> insertDevice(Device device) async {
    final db = await database;
    final map = device.toMap();
    map.remove('id'); 
    return await db.insert(
      'devices',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Device>> getDevices() async {
    final db = await database;
    final result = await db.query(
      'devices',
      orderBy: 'id DESC',
    );

    return result.map((json) => Device.fromMap(json)).toList();
  }

  Future<int> deleteDevice(int id) async {
    final db = await database;
    return await db.delete(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
