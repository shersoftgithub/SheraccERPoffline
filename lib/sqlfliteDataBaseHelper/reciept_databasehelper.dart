import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ReceiptDatabaseHelper {
  static const _databaseName = "receipt.db";
  static const _databaseVersion = 1;
  static const table = 'receipt_table';

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

  static final ReceiptDatabaseHelper instance =
      ReceiptDatabaseHelper._privateConstructor();
  static Database? _database;

  ReceiptDatabaseHelper._privateConstructor();

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

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<Map<String, dynamic>?> queryRowById(int id) async {
    Database db = await instance.database;
    final result = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> update(int id, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearTable() async {
    Database db = await instance.database;
    await db.delete(table);
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), _databaseName);
    await deleteDatabase(path);
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
