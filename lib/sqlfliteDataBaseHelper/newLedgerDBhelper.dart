import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static const _databaseName = "ledger.db";
  static const _databaseVersion = 1;

  static const table = 'ledger_table';
  static const columnId = 'id';
  static const columnLedgerName = 'ledger_name';
  static const columnUnder = 'under';
  static const columnAddress = 'address';
  static const columnContact = 'contact';
  static const columnMail = 'mail';
  static const columnTaxNo = 'tax_no';
  static const columnPriceLevel = 'price_level';
  static const columnBalance = 'balance';

  // Singleton pattern: only one instance of the database helper
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database reference
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create table if it doesn't exist
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Create table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnLedgerName TEXT NOT NULL,
        $columnUnder TEXT NOT NULL,
        $columnAddress TEXT,
        $columnContact TEXT,
        $columnMail TEXT,
        $columnTaxNo TEXT,
        $columnPriceLevel TEXT,
        $columnBalance REAL
      )
    ''');
  }

  // Insert data into the database
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Get all data from the database
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Delete data by id
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

 Future<List<int>> getAllLedgerIds() async {
  Database db = await instance.database;

  // Query the database for only the 'id' column
  final List<Map<String, dynamic>> result = await db.query(
    table,
    columns: [columnId], // Only select the 'id' column
  );

  // Convert the result to a list of 'id' values (which are int)
  List<int> ledgerIds = result.map((row) => row[columnId] as int).toList();

  return ledgerIds;
}

Future<List<String>> getAllLedgerNames() async {
  Database db = await instance.database;

  // Query the database for all ledger names
  final List<Map<String, dynamic>> result = await db.query(
    table,
    columns: [columnLedgerName], // Only get the ledger name
  );

  // Convert the result to a list of ledger names
  List<String> ledgerNames = result.map((row) => row[columnLedgerName] as String).toList();
  
  return ledgerNames;
}

}
