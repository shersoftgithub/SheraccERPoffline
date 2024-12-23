import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PaymentDatabaseHelper {
  static const _databaseName = "payment.db";
  static const _databaseVersion = 1;

  static const table = 'payment_table';

  // Column names
  static const columnId = 'id';
  static const columnDate = 'date';
  static const columnCashAccount = 'cashAccount';
  static const columnLedgerName = 'ledgerName';
  static const columnBalance = 'balance';
  static const columnAmount = 'amount';
  static const columnDiscount = 'discount';
  static const columnTotal = 'total';
  static const columnNarration = 'narration';

  // Singleton instance
  static final PaymentDatabaseHelper instance =
      PaymentDatabaseHelper._privateConstructor();
  static Database? _database;

  PaymentDatabaseHelper._privateConstructor();

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
        $columnCashAccount TEXT NOT NULL,
        $columnLedgerName TEXT NOT NULL,
        $columnBalance REAL NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnDiscount REAL NOT NULL,
        $columnTotal REAL NOT NULL,
        $columnNarration TEXT NOT NULL
      )
    ''');
  }

  // Insert a new row
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Query all rows
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Update a row
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete a row
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // Retrieve distinct cash accounts
  Future<List<String>> getAllUniqueCashAccounts() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db
        .rawQuery('SELECT DISTINCT $columnCashAccount FROM $table');
    return result.map((row) => row[columnCashAccount] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getTotalBalancesByLedger() async {
  Database db = await instance.database;
  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT $columnLedgerName, SUM($columnBalance) AS total_balance
    FROM $table
    GROUP BY $columnLedgerName
  ''');
  return result;
}

Future<List<Map<String, dynamic>>> queryFilteredRows(DateTime? fromDate, DateTime? toDate, String ledgerName) async {
  Database db = await instance.database;

  String whereClause = '';
  List<dynamic> whereArgs = [];

  if (ledgerName.isNotEmpty) {
    whereClause = '$columnLedgerName LIKE ?';
    whereArgs.add('%$ledgerName%');
  }

  if (fromDate != null && toDate != null) {
    if (whereClause.isNotEmpty) whereClause += ' AND ';
     whereClause += '$columnDate BETWEEN ? AND ?';
    whereArgs.add(fromDate.toIso8601String());
    whereArgs.add(toDate.toIso8601String());
  }

  return await db.query(
    table,
    where: whereClause.isNotEmpty ? whereClause : null,
    whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
  );
}

}
