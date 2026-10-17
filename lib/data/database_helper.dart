import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/device_models.dart';
import '../models/electricity_profile_model.dart';
import '../models/meter_reading_model.dart';
import '../models/notification_model.dart';
import '../models/token_purchase_model.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabel devices (FR-05)
    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        power_watt REAL NOT NULL,
        quantity INTEGER NOT NULL,
        daily_hours REAL NOT NULL
      )
    ''');

    // 2. Tabel konfigurasi tarif PLN resmi (PRD Section 11 & 19)
    await db.execute('''
      CREATE TABLE tariff_configurations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        power_va INTEGER NOT NULL,
        tariff_per_kwh REAL NOT NULL
      )
    ''');

    // 3. Tabel profil listrik pengguna (PRD Section 11 & 19)
    await db.execute('''
      CREATE TABLE electricity_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        power_va INTEGER NOT NULL,
        connection_type TEXT NOT NULL,
        tariff_per_kwh REAL NOT NULL
      )
    ''');

    // 4. Tabel catatan meter listrik (FR-03 & FR-07)
    await db.execute('''
      CREATE TABLE meter_readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reading_date TEXT NOT NULL,
        kwh_meter REAL NOT NULL,
        photo_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 5. Tabel transaksi pembelian token (FR-02 & FR-07)
    await db.execute('''
      CREATE TABLE token_purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_date TEXT NOT NULL,
        amount_rp REAL NOT NULL,
        kwh_token REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 6. Tabel notifikasi lokal (Modul 2 & Log)
    await db.execute('''
      CREATE TABLE app_notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        date_time TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        payload TEXT
      )
    ''');

    // Seed konfigurasi tarif dan default profil
    await _seedTariffs(db);
    await _seedDefaultProfile(db);
    await _seedInitialDemoData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tariff_configurations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          power_va INTEGER NOT NULL,
          tariff_per_kwh REAL NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS electricity_profile (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          power_va INTEGER NOT NULL,
          connection_type TEXT NOT NULL,
          tariff_per_kwh REAL NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS meter_readings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reading_date TEXT NOT NULL,
          kwh_meter REAL NOT NULL,
          photo_path TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS token_purchases (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          purchase_date TEXT NOT NULL,
          amount_rp REAL NOT NULL,
          kwh_token REAL NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          type TEXT NOT NULL,
          date_time TEXT NOT NULL,
          is_read INTEGER NOT NULL DEFAULT 0,
          payload TEXT
        )
      ''');

      await _seedTariffs(db);
      await _seedDefaultProfile(db);
      await _seedInitialDemoData(db);
    }
  }

  Future<void> _seedTariffs(Database db) async {
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM tariff_configurations');
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    if (count > 0) return;

    // Data Tarif Resmi PLN untuk Pelanggan Prabayar (PRD Section 19)
    final tariffs = [
      {'category': 'Rumah Tangga R-1/TR', 'power_va': 900, 'tariff_per_kwh': 1352.00},
      {'category': 'Rumah Tangga R-1/TR', 'power_va': 1300, 'tariff_per_kwh': 1444.70},
      {'category': 'Rumah Tangga R-1/TR', 'power_va': 2200, 'tariff_per_kwh': 1444.70},
      {'category': 'Rumah Tangga R-2/TR', 'power_va': 3500, 'tariff_per_kwh': 1699.53},
      {'category': 'Rumah Tangga R-2/TR', 'power_va': 5500, 'tariff_per_kwh': 1699.53},
      {'category': 'Rumah Tangga R-3/TR', 'power_va': 6600, 'tariff_per_kwh': 1699.53},
      {'category': 'Bisnis Kecil B-1/TR', 'power_va': 1300, 'tariff_per_kwh': 1444.70},
    ];

    for (final tariff in tariffs) {
      await db.insert('tariff_configurations', tariff);
    }
  }

  Future<void> _seedDefaultProfile(Database db) async {
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM electricity_profile');
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    if (count > 0) return;

    await db.insert('electricity_profile', {
      'category': 'Rumah Tangga R-1/TR',
      'power_va': 1300,
      'connection_type': 'Prabayar / Token',
      'tariff_per_kwh': 1444.70,
    });
  }

  Future<void> _seedInitialDemoData(Database db) async {
    // Cek apakah data meter kosong; jika iya masukkan data awal sesuai UI & UX Frame 08 & 06
    final meterCountRes = await db.rawQuery('SELECT COUNT(*) as count FROM meter_readings');
    final meterCount = Sqflite.firstIntValue(meterCountRes) ?? 0;

    if (meterCount == 0) {
      final now = DateTime.now();

      // Transaksi token sebelumnya
      await db.insert('token_purchases', {
        'purchase_date': now.subtract(const Duration(days: 4, hours: 2)).toIso8601String(),
        'amount_rp': 50000.0,
        'kwh_token': 33.7,
        'created_at': now.subtract(const Duration(days: 4, hours: 2)).toIso8601String(),
      });

      // Catatan meter 3 hari lalu
      await db.insert('meter_readings', {
        'reading_date': now.subtract(const Duration(days: 2, hours: 14)).toIso8601String(),
        'kwh_meter': 21.4,
        'photo_path': null,
        'created_at': now.subtract(const Duration(days: 2, hours: 14)).toIso8601String(),
      });

      // Catatan meter 2 hari lalu
      await db.insert('meter_readings', {
        'reading_date': now.subtract(const Duration(days: 1, hours: 14)).toIso8601String(),
        'kwh_meter': 16.8,
        'photo_path': null,
        'created_at': now.subtract(const Duration(days: 1, hours: 14)).toIso8601String(),
      });

      // Catatan meter hari ini
      await db.insert('meter_readings', {
        'reading_date': now.toIso8601String(),
        'kwh_meter': 12.7,
        'photo_path': null,
        'created_at': now.toIso8601String(),
      });
    }

    // Seed perangkat contoh jika tabel devices masih kosong (sesuai UI & UX Frame 10)
    final deviceCountRes = await db.rawQuery('SELECT COUNT(*) as count FROM devices');
    final deviceCount = Sqflite.firstIntValue(deviceCountRes) ?? 0;
    if (deviceCount == 0) {
      final initialDevices = [
        {'name': 'AC Kamar', 'power_watt': 500.0, 'quantity': 1, 'daily_hours': 6.0},
        {'name': 'Kulkas 1 Pintu', 'power_watt': 100.0, 'quantity': 1, 'daily_hours': 15.0},
        {'name': 'TV LED Kos', 'power_watt': 100.0, 'quantity': 1, 'daily_hours': 4.0},
        {'name': 'Lampu Belajar', 'power_watt': 12.0, 'quantity': 2, 'daily_hours': 8.0},
      ];
      for (final dev in initialDevices) {
        await db.insert('devices', dev);
      }
    }
  }

  Future<void> resetDummyModule1Data() async {
    final db = await database;
    await db.delete('meter_readings');
    await db.delete('token_purchases');

    final now = DateTime.now();

    await db.insert('token_purchases', {
      'purchase_date': now.subtract(const Duration(days: 4, hours: 2)).toIso8601String(),
      'amount_rp': 50000.0,
      'kwh_token': 33.7,
      'created_at': now.subtract(const Duration(days: 4, hours: 2)).toIso8601String(),
    });

    await db.insert('meter_readings', {
      'reading_date': now.subtract(const Duration(days: 2, hours: 14)).toIso8601String(),
      'kwh_meter': 21.4,
      'photo_path': null,
      'created_at': now.subtract(const Duration(days: 2, hours: 14)).toIso8601String(),
    });

    await db.insert('meter_readings', {
      'reading_date': now.subtract(const Duration(days: 1, hours: 14)).toIso8601String(),
      'kwh_meter': 16.8,
      'photo_path': null,
      'created_at': now.subtract(const Duration(days: 1, hours: 14)).toIso8601String(),
    });

    await db.insert('meter_readings', {
      'reading_date': now.toIso8601String(),
      'kwh_meter': 12.7,
      'photo_path': null,
      'created_at': now.toIso8601String(),
    });
  }

  // ===================== CRUD DEVICES (FR-05) =====================
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

  Future<int> updateDevice(Device device) async {
    final db = await database;
    return await db.update(
      'devices',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  // ===================== TARIFF CONFIG & PROFILE (FR-01 & FR-06) =====================
  Future<List<TariffConfig>> getTariffConfigs() async {
    final db = await database;
    final result = await db.query('tariff_configurations', orderBy: 'power_va ASC');
    return result.map((json) => TariffConfig.fromMap(json)).toList();
  }

  Future<ElectricityProfile> getElectricityProfile() async {
    final db = await database;
    final result = await db.query('electricity_profile', limit: 1);
    if (result.isNotEmpty) {
      return ElectricityProfile.fromMap(result.first);
    }
    // Fallback default profile jika belum ada
    return const ElectricityProfile(
      category: 'Rumah Tangga R-1/TR',
      powerVa: 1300,
      connectionType: 'Prabayar / Token',
      tariffPerKwh: 1444.70,
    );
  }

  Future<void> saveElectricityProfile(ElectricityProfile profile) async {
    final db = await database;
    final map = profile.toMap();
    map.remove('id');

    final existing = await db.query('electricity_profile', limit: 1);
    if (existing.isEmpty) {
      await db.insert('electricity_profile', map);
    } else {
      final id = existing.first['id'] as int;
      await db.update(
        'electricity_profile',
        map,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // ===================== METER READINGS (FR-03 & FR-07) =====================
  Future<int> insertMeterReading(MeterReading reading) async {
    final db = await database;
    final map = reading.toMap();
    map.remove('id');
    return await db.insert('meter_readings', map);
  }

  Future<List<MeterReading>> getMeterReadings({bool ascending = false}) async {
    final db = await database;
    final result = await db.query(
      'meter_readings',
      orderBy: ascending ? 'reading_date ASC' : 'reading_date DESC',
    );
    return result.map((json) => MeterReading.fromMap(json)).toList();
  }

  Future<int> deleteMeterReading(int id) async {
    final db = await database;
    return await db.delete(
      'meter_readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===================== TOKEN PURCHASES (FR-02 & FR-07) =====================
  Future<int> insertTokenPurchase(TokenPurchase purchase) async {
    final db = await database;
    final map = purchase.toMap();
    map.remove('id');
    return await db.insert('token_purchases', map);
  }

  Future<List<TokenPurchase>> getTokenPurchases({bool ascending = false}) async {
    final db = await database;
    final result = await db.query(
      'token_purchases',
      orderBy: ascending ? 'purchase_date ASC' : 'purchase_date DESC',
    );
    return result.map((json) => TokenPurchase.fromMap(json)).toList();
  }

  Future<int> deleteTokenPurchase(int id) async {
    final db = await database;
    return await db.delete(
      'token_purchases',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===================== NOTIFICATIONS (Modul 2) =====================
  Future<int> insertNotification(AppNotificationItem notification) async {
    final db = await database;
    final map = notification.toMap();
    map.remove('id');
    return await db.insert('app_notifications', map);
  }

  Future<List<AppNotificationItem>> getNotifications() async {
    final db = await database;
    final result = await db.query(
      'app_notifications',
      orderBy: 'date_time DESC',
    );
    return result.map((json) => AppNotificationItem.fromMap(json)).toList();
  }

  Future<int> markNotificationAsRead(int id) async {
    final db = await database;
    return await db.update(
      'app_notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> hasNotificationForDateAndType({
    required String datePrefix,
    required String type,
  }) async {
    final db = await database;
    final result = await db.query(
      'app_notifications',
      where: 'date_time LIKE ? AND type = ?',
      whereArgs: ['$datePrefix%', type],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
