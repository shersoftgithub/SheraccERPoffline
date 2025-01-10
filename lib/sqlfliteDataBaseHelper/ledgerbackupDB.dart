import 'dart:typed_data';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CompanyLEdgerDatabaseHelper {
  static Database? _database;
  static final CompanyLEdgerDatabaseHelper _instance = CompanyLEdgerDatabaseHelper._internal();

  CompanyLEdgerDatabaseHelper._internal();
  static CompanyLEdgerDatabaseHelper get instance => _instance;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'companyLedger.db');
    
    return openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade, 
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE LedgerNames (
        Ledcode TEXT PRIMARY KEY,
        LedName TEXT,
        lh_id TEXT,
        add1 TEXT,
        add2 TEXT,
        add3 TEXT,
        add4 TEXT,
        city TEXT,
        route TEXT,
        state TEXT,
        Mobile TEXT,
        pan TEXT,
        Email TEXT,
        gstno TEXT,
        CAmount REAL,
        Active INTEGER,
        SalesMan TEXT,
        Location TEXT,
        OrderDate TEXT,
        DeliveryDate TEXT,
        CPerson TEXT,
        CostCenter TEXT,
        Franchisee TEXT,
        SalesRate REAL,
        SubGroup TEXT,
        SecondName TEXT,
        UserName TEXT,
        Password TEXT,
        CustomerType TEXT,
        OTP TEXT,
        maxDiscount REAL
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      ''');
    }
  }

  Future<void> insertLedgerData(Map<String, dynamic> ledgerData) async {
    final db = await database;

    await db.insert(
      'LedgerNames',
      ledgerData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getLedgerData() async {
    final db = await database;
    final result = await db.query('LedgerNames');

    return result.map((row) {
      if (row['Photo'] != null) {
        row['Photo'] = row['Photo'] as Uint8List;
      }
      return row;
    }).toList();
  }
Future<List<String>> getAllNames() async {
    final db = await instance.database;
    final result = await db.query('LedgerNames', columns: ['LedName']);
    return result.map((item) => item['LedName'] as String).toList();
  }

  Future<Map<String, dynamic>?> getLedgerDetailsByName(String ledgerName) async {
  final db = await instance.database;

  // Fetch ledger details for the given name
  final result = await db.query(
    'LedgerNames',
    columns: ['Ledcode AS LedId', 'Mobile'],
    where: 'LedName = ?',
    whereArgs: [ledgerName],
  );

  // If data is found, return the first result as a map
  if (result.isNotEmpty) {
    return result.first;
  }

  return null; // Return null if no matching record is found
}

}
