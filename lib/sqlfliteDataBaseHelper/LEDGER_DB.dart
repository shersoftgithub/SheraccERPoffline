import 'dart:typed_data';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LedgerDatabaseHelper {
  static Database? _database;
  static Database? _backupDatabase;
  static final LedgerDatabaseHelper _instance = LedgerDatabaseHelper._internal();

  LedgerDatabaseHelper._internal();
  static LedgerDatabaseHelper get instance => _instance;

  // Database for the main ledger
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('ledgerDB.db');
    return _database!;
  }

  Future<Database> get backupDatabase async {
    if (_backupDatabase != null) return _backupDatabase!;
    _backupDatabase = await _initDatabase('ledgerDBBackup.db');
    return _backupDatabase!;
  }

  // Initialize both databases
  Future<Database> _initDatabase(String dbName) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);
    
    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createDatabase(db);
        // You can create views here as well
        await _createViews(db);
      },
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDatabase(Database db) async {
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
        maxDiscount REAL,
        OpeningBalance REAL
      );
    ''');

    await db.execute(''' 
      CREATE TABLE Account_Transactions (
        atLedCode TEXT PRIMARY KEY,
        atEntryno TEXT,
        atDebitAmount REAL,
        atCreditAmount REAL,
        atOpposite TEXT,
        atSalesType TEXT,
        atDate REAL DEFAULT 0,
        atType TEXT,
        Caccount TEXT,
        atDiscount REAL,
        atNaration TEXT
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 4) {
      await db.execute("ALTER TABLE Account_Transactions ADD COLUMN Caccount TEXT;");
      await db.execute("ALTER TABLE Account_Transactions ADD COLUMN atDiscount REAL;");
      await db.execute("ALTER TABLE Account_Transactions ADD COLUMN atNaration TEXT;");
    }
  }

  // Create Views to simplify queries
  Future<void> _createViews(Database db) async {
    await db.execute('''
      CREATE VIEW IF NOT EXISTS LedgerWithTransactions AS
      SELECT 
        l.Ledcode,
        l.LedName,
        a.atEntryno,
        a.atDebitAmount,
        a.atCreditAmount,
        a.atOpposite,
        a.atSalesType,
        a.atDate,
        a.Caccount,
        a.atDiscount,
        a.atNaration
      FROM LedgerNames l
      LEFT JOIN Account_Transactions a ON l.Ledcode = a.atLedCode;
    ''');
    print('Created view: LedgerWithTransactions');
  }
  Future<List<Map<String, dynamic>>> getLedgersWithTransactions() async {
    final db = await database;  // Use the primary database or backup as needed
    final result = await db.rawQuery('SELECT * FROM LedgerWithTransactions');
    return result;
  }

  // Insert data into LedgerNames table
  Future<void> insertLedgerData(Map<String, dynamic> ledgerData) async {
    final db = await database;
    await db.insert('LedgerNames', ledgerData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Insert data into Account_Transactions table
  Future<void> insertAccTrans(Map<String, dynamic> newTableData) async {
    final db = await database;
    await db.insert('Account_Transactions', newTableData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query('Account_Transactions');
  }
  // Fetch all Ledger Names
  Future<List<String>> getAllNames() async {
    final db = await instance.database;
    final result = await db.query('LedgerNames', columns: ['LedName']);
    return result.map((item) => item['LedName'] as String).toList();
  }

  // Fetch ledger details by name
  Future<Map<String, dynamic>?> getLedgerDetailsByName(String ledgerName) async {
    final db = await instance.database;
    final result = await db.query(
      'LedgerNames',
      columns: ['Ledcode AS LedId', 'Mobile','OpeningBalance'],
      where: 'LedName = ?',
      whereArgs: [ledgerName],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  Future<List<Map<String, dynamic>>> getAccTrans() async {
    final db = await database;
    final result = await db.query('account_Transactions');

    return result;
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

  // Helper function to check if a column exists in a table
  Future<bool> _doesColumnExist(Database db, String tableName, String columnName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }

  // Example of how to fetch data from the backup database
  Future<List<Map<String, dynamic>>> getBackupLedgersWithTransactions() async {
    final db = await backupDatabase;
    final result = await db.rawQuery('SELECT * FROM LedgerWithTransactions');
    return result;
  }

Future<Map<String, dynamic>?> getLedgerByName(String ledgerName) async {
  final db = await instance.database;
  final result = await db.query(
    'LedgerNames', 
    where: 'LedName = ?', 
    whereArgs: [ledgerName],
  );
  return result.isNotEmpty ? result.first : null;
}
Future<void> updateLedgerBalance(String ledgerName, double newBalance) async {
  final db = await database;
  await db.update(
    'LedgerNames', // Your ledger table name
    {'OpeningBalance': newBalance}, // Use the correct column name for opening balance
    where: 'Ledcode = ?', 
    whereArgs: [ledgerName],
  );
}
Future<bool> doesLedgerExist(String ledgerName) async {
  Database db = await instance.database;
  var result = await db.query(
    'LedgerNames',
    where: 'LedName = ?',
    whereArgs: [ledgerName],
  );
  return result.isNotEmpty;
}
Future<void> updatePaymentBalance(String ledgerName,String total,String amt, double newBalance) async {
  final db = await database;
  await db.update(
    'Account_Transactions', 
    {'atDebitAmount': newBalance,
    'atCreditAmount':total,
    'atDebitAmount':amt,
    }, 
    where: 'ledgerName = ?', 
    whereArgs: [ledgerName],
  );
}

Future<List<Map<String, dynamic>>> getFilteredAccTrans(String atType) async {
    final db = await database; // Ensure you have the correct database instance
    return await db.query(
      'Account_Transactions', // Replace with your table name
      where: 'atType = ?',  // Filter by atType column
      whereArgs: [atType],
    );
  }

Future<void> updateOpeningBalances() async {
  final db = await database;

  try {
    final ledgers = await db.rawQuery('SELECT DISTINCT atLedCode FROM Account_Transactions');

    for (var ledger in ledgers) {
      final ledcode = ledger['atLedCode'] as String;
      final creditResult = await db.rawQuery(
        'SELECT SUM(atCreditAmount) AS totalCredit FROM Account_Transactions WHERE atLedCode = ?',
        [ledcode],
      );
      final debitResult = await db.rawQuery(
        'SELECT SUM(atDebitAmount) AS totalDebit FROM Account_Transactions WHERE atLedCode = ?',
        [ledcode],
      );

      final totalCredit = creditResult.first['totalCredit'] as num? ?? 0;
      final totalDebit = debitResult.first['totalDebit'] as num? ?? 0;
      final openingBalance = totalCredit - totalDebit;

      print('LedCode: $ledcode');
      print('Total Credit: $totalCredit');
      print('Total Debit: $totalDebit');
      print('Calculated Opening Balance: $openingBalance');

      await db.update(
        'LedgerNames',
        {'OpeningBalance': openingBalance},
        where: 'Ledcode = ?',
        whereArgs: [ledcode],
      );
    }
    print('Opening balances updated successfully.');
  } catch (e) {
    print('Error updating opening balances: $e');
  }
}



}
