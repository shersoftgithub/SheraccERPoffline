import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static const _databaseName = "ledger.db";
  static const _databaseVersion = 2; 

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
  static const columnOpeningBalance = 'opening_balance';
  static const columnReceivedBalance = 'received_balance';
  static const columnPayAmount = 'pay_amount';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

 
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, 
    );
  }

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
        $columnBalance REAL,
        $columnOpeningBalance REAL DEFAULT 0.0,
        $columnReceivedBalance REAL DEFAULT 0.0,
        $columnPayAmount REAL DEFAULT 0.0
      )
    ''');
  }

 Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    final existingColumns = await _getTableColumns(db, table);

    if (!existingColumns.contains(columnOpeningBalance)) {
      await db.execute('''
        ALTER TABLE $table
        ADD COLUMN $columnOpeningBalance REAL DEFAULT 0.0
      ''');
    }

    if (!existingColumns.contains(columnReceivedBalance)) {
      await db.execute('''
        ALTER TABLE $table
        ADD COLUMN $columnReceivedBalance REAL DEFAULT 0.0
      ''');
    }

    if (!existingColumns.contains(columnPayAmount)) {
      await db.execute('''
        ALTER TABLE $table
        ADD COLUMN $columnPayAmount REAL DEFAULT 0.0
      ''');
    }
  }
}

Future<void> clearTable() async {
    Database db = await instance.database;
    await db.delete(table);
  }
  
Future<List<String>> _getTableColumns(Database db, String tableName) async {
  final result = await db.rawQuery('PRAGMA table_info($tableName)');
  return result.map((row) => row['name'] as String).toList();
}


  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<int>> getAllLedgerIds() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      table,
      columns: [columnId], 
    );

    List<int> ledgerIds = result.map((row) => row[columnId] as int).toList();

    return ledgerIds;
  }

  Future<List<String>> getAllLedgerNames() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      table,
      columns: [columnLedgerName],
    );
    List<String> ledgerNames = result.map((row) => row[columnLedgerName] as String).toList();

    return ledgerNames;
  }

  Future<List<String>> getAllUniqueUnder() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT DISTINCT $columnUnder FROM $table');
    List<String> uniqueUnder = result.map((row) => row[columnUnder] as String).toList();

    return uniqueUnder;
  }

  Future<List<Map<String, dynamic>>> getAllLedgersWithBalances() async {
  Database db = await instance.database;
  final List<Map<String, dynamic>> result = await db.query(
    table,
    columns: [
      columnId,
      columnLedgerName,
      columnOpeningBalance,
      columnReceivedBalance,
      columnPayAmount
    ],
  );

  return result;
}


Future<void> updateOpeningBalancesFromPayments(
    List<Map<String, dynamic>> paymentBalances) async {
  Database db = await instance.database;
  Batch batch = db.batch();

  for (var payment in paymentBalances) {
    String ledgerName = payment[PaymentDatabaseHelper.columnLedgerName];
    double totalBalance = payment['total_balance'];

    batch.update(
      table,
      {columnOpeningBalance: totalBalance},
      where: '$columnLedgerName = ?',
      whereArgs: [ledgerName],
    );
  }

  await batch.commit(noResult: true);
}

Future<void> updateLedgerBalance(String ledgerName, double newBalance) async {
  final db = await database;
  await db.update(
    'ledger_table', // Your ledger table name
    {'opening_balance': newBalance}, // Use the correct column name for opening balance
    where: 'ledger_name = ?', // Use the correct column name for ledger name
    whereArgs: [ledgerName],
  );
}

Future<Map<String, dynamic>?> getLedgerByName(String ledgerName) async {
  final db = await instance.database;
  final result = await db.query(
    'ledger_table', // Your ledger table name
    where: 'ledger_name = ?', // Use the correct column name for ledger name
    whereArgs: [ledgerName],
  );
  return result.isNotEmpty ? result.first : null;
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
    // whereClause += '$columnDate BETWEEN ? AND ?';
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
