import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PV_DatabaseHelper {
  static const _databaseName = "pv_database.db";
  static const _databaseVersion = 1;

  

  // Singleton pattern
  PV_DatabaseHelper._privateConstructor();
  static final PV_DatabaseHelper instance = PV_DatabaseHelper._privateConstructor();

  // Database instance
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create tables
  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Create tables in the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS PV_Particulars (
        auto TEXT PRIMARY KEY,
        EntryNo TEXT,
        Name TEXT,
        Amount REAL,
        Discount REAL,
        Total REAL,
        Narration TEXT,
        ddate TEXT,
        CashAccount TEXT
      );
    ''');

  }

  // Insert data into PV_Particulars table
  Future<void> insertPVParticulars(List<Map<String, dynamic>> data) async {
    final db = await database;
    
    // Insert data into the table, or replace it if the primary key already exists
    Batch batch = db.batch();
    for (var row in data) {
      batch.insert(
        "PV_Particulars",
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  // Insert data into RV_Particulars table
  Future<void> insertRVParticulars(List<Map<String, dynamic>> data) async {
    final db = await database;

    // Insert data into the table, or replace it if the primary key already exists
    Batch batch = db.batch();
    for (var row in data) {
      batch.insert(
        "PV_Particulars",
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }
  
  // Fetch data from the PV_Particulars table
  Future<List<Map<String, dynamic>>> fetchPVParticulars() async {
    final db = await database;
    return await db.query("PV_Particulars");
  }

  // Fetch data from the RV_Particulars table
  Future<List<Map<String, dynamic>>> fetchRVParticulars() async {
    final db = await database;
    return await db.query("PV_Particulars");
  }
}
