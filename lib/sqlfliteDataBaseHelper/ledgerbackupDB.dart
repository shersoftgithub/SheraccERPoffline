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
      version: 4, 
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

    await db.execute('''
      CREATE TABLE Account_Transactions (
        atLedCode TEXT PRIMARY KEY,
        atEntryno TEXT,
        atDebitAmount REAL,
        atCreditAmount REAL,
        atOpposite TEXT,
        atSalesType TEXT
      );
    ''');
  }

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 3) {
    // This is where the Account_Transactions table is created (version 3).
    await db.execute(''' 
      CREATE TABLE Account_Transactions (
        atLedCode TEXT PRIMARY KEY,
        atEntryno TEXT,
        atDebitAmount REAL,
        atCreditAmount REAL,
        atOpposite TEXT,
        atSalesType TEXT
      );
    ''');
  }

  // Ensure the column is added only if it doesn't exist already.
  if (oldVersion < 4) {
    // We check for the existence of the OpeningBalance column and add it if missing.
    try {
      await db.execute('''
        ALTER TABLE LedgerNames ADD COLUMN OpeningBalance REAL DEFAULT 0;
      ''');
      print('Column OpeningBalance added successfully.');
    } catch (e) {
      print('Error adding OpeningBalance column: $e');
    }
  }
}



  // Insert data into LedgerNames table
  Future<void> insertLedgerData(Map<String, dynamic> ledgerData) async {
    final db = await database;

    await db.insert(
      'LedgerNames',
      ledgerData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all data from LedgerNames table
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

  // Fetch all Ledger Names
  Future<List<String>> getAllNames() async {
    final db = await instance.database;
    final result = await db.query('LedgerNames', columns: ['LedName']);
    return result.map((item) => item['LedName'] as String).toList();
  }

  Future<Map<String, dynamic>?> getLedgerDetailsByName(String ledgerName) async {
    final db = await instance.database;

    final result = await db.query(
      'LedgerNames',
      columns: ['Ledcode AS LedId', 'Mobile'],
      where: 'LedName = ?',
      whereArgs: [ledgerName],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null; 
  }

  Future<void> insertAccTrans(Map<String, dynamic> newTableData) async {
    final db = await database;

    await db.insert(
      'Account_Transactions',
      newTableData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAccTrans() async {
    final db = await database;
    final result = await db.query('Account_Transactions');

    return result;
  }

Future<void> updateOpeningBalanceForLedcode(String ledCode) async {
  final db = await database;

  // Get all transactions for the current ledCode
  final transactions = await db.query(
    'Account_Transactions',
    columns: ['atDebitAmount', 'atCreditAmount'],
    where: 'atLedCode = ?',
    whereArgs: [ledCode],
  );

  double totalDebit = 0.0;
  double totalCredit = 0.0;

  // Sum all debit and credit amounts
  for (var transaction in transactions) {
    totalDebit += transaction['atDebitAmount'] as double? ?? 0.0;
    totalCredit += transaction['atCreditAmount'] as double? ?? 0.0;
  }

  // Calculate the opening balance (Credit - Debit)
  final openingBalance = totalCredit - totalDebit;

  // Update the OpeningBalance in the LedgerNames table
  await db.update(
    'LedgerNames',
    {'OpeningBalance': openingBalance},
    where: 'Ledcode = ?',
    whereArgs: [ledCode],
  );

  print('Opening balance for $ledCode updated to $openingBalance');
}



Future<void> updateAllOpeningBalances() async {
  final db = await database;
  final ledgers = await db.query('LedgerNames', columns: ['Ledcode']);

  for (var ledger in ledgers) {
    final ledCode = ledger['Ledcode'] as String;
    await updateOpeningBalanceForLedcode(ledCode);
  }

  print('Opening balances updated successfully.');
}



}
