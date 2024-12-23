import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SaleDatabaseHelper {
  static const _databaseName = "salescredit.db";
  static const _databaseVersion = 2;

  static const table = 'salescredit_table';

  // Column names
  static const columnId = 'invoice_id';
  static const columnDate = 'date';
  static const columnSaleRate = 'sales_rate';
  static const columnCustomer = 'customer';
  static const columnPhoneNo = 'phoneNo';
  static const columnItemName = 'item_name';
  static const columnQTY = 'qty';
  static const columnUnit = 'unit';
  static const columnRate = 'rate';
  static const columnTax = 'tax';
  static const columnTotalAmt = 'total_amt';

  // Singleton instance
  static final SaleDatabaseHelper instance = SaleDatabaseHelper._privateConstructor();
  static Database? _database;

  SaleDatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDate TEXT NOT NULL,
        $columnSaleRate REAL NOT NULL,
        $columnCustomer TEXT NOT NULL,
        $columnPhoneNo TEXT NOT NULL,
        $columnItemName TEXT NOT NULL,
        $columnQTY INTEGER NOT NULL,
        $columnUnit TEXT NOT NULL,
        $columnRate REAL NOT NULL,
        $columnTax REAL NOT NULL,
        $columnTotalAmt REAL NOT NULL
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
  Future<List<String>> getAllUniqueItemname() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT DISTINCT $columnItemName FROM $table');
    List<String> uniqueUnder = result.map((row) => row[columnItemName] as String).toList();

    return uniqueUnder;
  }
}
