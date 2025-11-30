import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('services.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgrade);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const realTypeNullable = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE services (
        id $idType,
        date $textType,
        clientName $textType,
        deviceName $textType,
        serialNumber $textType,
        reason $textType,
        servicePerformed $textType,
        value $realType,
        status $textType
      )
    ''');
  }

  Future _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // adiciona coluna status e migra valores a partir de 'finalized' (0/1)
      try {
        await db.execute("ALTER TABLE services ADD COLUMN status TEXT");
      } catch (_) {
        // se já existir, ignore
      }
      // popula status com base na coluna antiga 'finalized' quando disponível
      try {
        await db.execute("UPDATE services SET status = CASE WHEN finalized = 1 THEN 'finalized' ELSE 'pending' END WHERE status IS NULL");
      } catch (_) {
        // se a coluna 'finalized' não existir, nada a fazer
      }
    }
  }

  Future<int> insertService(Service service) async {
    final db = await instance.database;
    await _ensureStatusColumn(db);
    final map = await _prepareMapForDb(service, db);
    return await db.insert('services', map);
  }

  Future<List<Service>> getAllServices() async {
    final db = await instance.database;
    final result = await db.query('services', orderBy: 'id DESC');
    return result.map((map) => Service.fromMap(map)).toList();
  }

  Future<int> updateService(Service service) async {
    final db = await instance.database;
    await _ensureStatusColumn(db);
    final map = await _prepareMapForDb(service, db);
    return await db.update('services', map, where: 'id = ?', whereArgs: [service.id]);
  }

  Future<void> _ensureStatusColumn(Database db) async {
    try {
      final info = await db.rawQuery("PRAGMA table_info(services)");
      final hasStatus = info.any((row) => row['name'] == 'status');
      if (!hasStatus) {
        await db.execute("ALTER TABLE services ADD COLUMN status TEXT");
        // try to populate from legacy 'finalized' column when present
        try {
          await db.execute("UPDATE services SET status = CASE WHEN finalized = 1 THEN 'finalized' ELSE 'pending' END WHERE status IS NULL");
        } catch (_) {}
      }
    } catch (e) {
      // se algo falhar aqui, não interrompe a operação principal; deixamos que o insert lance a exceção
    }
  }

  Future<Map<String, Object?>> _prepareMapForDb(Service service, Database db) async {
    final map = service.toMap();
    try {
      final info = await db.rawQuery("PRAGMA table_info(services)");
      final hasFinalized = info.any((row) => row['name'] == 'finalized');
      if (hasFinalized) {
        map['finalized'] = service.finalized ? 1 : 0;
      }
      // ensure status column exists in map for new tables
      if (!map.containsKey('status')) map['status'] = service.status;
    } catch (_) {}
    return map;
  }

  Future<int> deleteService(int id) async {
    final db = await instance.database;
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
