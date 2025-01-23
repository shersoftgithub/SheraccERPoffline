// import 'dart:typed_data';
// import 'dart:io';
// import 'package:intl/intl.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class LedgerDatabaseHelper {
//   static Database? _database;
//   static Database? _backupDatabase;
//   static final LedgerDatabaseHelper _instance = LedgerDatabaseHelper._internal();

//   LedgerDatabaseHelper._internal();
//   static LedgerDatabaseHelper get instance => _instance;

//   // Database for the main ledger
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase('ledgerDB.db');
//     return _database!;
//   }

//   Future<Database> get backupDatabase async {
//     if (_backupDatabase != null) return _backupDatabase!;
//     _backupDatabase = await _initDatabase('ledgerDBBackup.db');
//     return _backupDatabase!;
//   }

//   // Initialize both databases
//   Future<Database> _initDatabase(String dbName) async {
//     final databasesPath = await getDatabasesPath();
//     final path = join(databasesPath, dbName);
    
//     return openDatabase(
//       path,
//       version: 7,
//       onCreate: (db, version) async {
//         await _createDatabase(db);
//         // You can create views here as well
//         //await _createViews(db);
//       },
//       onUpgrade: _onUpgrade,
//     );
//   }

//   Future<void> _createDatabase(Database db) async {
//     await db.execute(''' 
//       CREATE TABLE LedgerNames (
//         Ledcode TEXT PRIMARY KEY,
//         LedName TEXT,
//         lh_id TEXT,
//         add1 TEXT,
//         add2 TEXT,
//         add3 TEXT,
//         add4 TEXT,
//         city TEXT,
//         route TEXT,
//         state TEXT,
//         Mobile TEXT,
//         pan TEXT,
//         Email TEXT,
//         gstno TEXT,
//         CAmount REAL,
//         Active INTEGER,
//         SalesMan TEXT,
//         Location TEXT,
//         OrderDate TEXT,
//         DeliveryDate TEXT,
//         CPerson TEXT,
//         CostCenter TEXT,
//         Franchisee TEXT,
//         SalesRate REAL,
//         SubGroup TEXT,
//         SecondName TEXT,
//         UserName TEXT,
//         Password TEXT,
//         CustomerType TEXT,
//         OTP TEXT,
//         maxDiscount REAL,
//         OpeningBalance REAL
//       );
//     ''');

   
//   }

//   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     print('Upgrading database from version $oldVersion to $newVersion');

//     if (oldVersion < 7) {
      
//       await db.execute("ALTER TABLE LedgerNames ADD COLUMN under TEXT;");
//       await db.execute("ALTER TABLE LedgerNames ADD COLUMN Debit REAL DEFAULT 0;");
//       await db.execute("ALTER TABLE LedgerNames ADD COLUMN date TEXT;");
//       await db.execute("ALTER TABLE LedgerNames ADD COLUMN balance REAL DEFAULT 0;");
//     }
//   }


//   Future<List<Map<String, dynamic>>> getLedgersWithTransactions() async {
//     final db = await database;  // Use the primary database or backup as needed
//     final result = await db.rawQuery('SELECT * FROM LedgerWithTransactions');
//     return result;
//   }

//   // Insert data into LedgerNames table
//   Future<void> insertLedgerData(Map<String, dynamic> ledgerData) async {
//     final db = await database;
//     await db.insert('LedgerNames', ledgerData, conflictAlgorithm: ConflictAlgorithm.replace);
//   }


//   // Fetch all Ledger Names
//   Future<List<String>> getAllNames() async {
//     final db = await instance.database;
//     final result = await db.query('LedgerNames', columns: ['LedName']);
//     return result.map((item) => item['LedName'] as String).toList();
//   }

//   // Fetch ledger details by name
//   Future<Map<String, dynamic>?> getLedgerDetailsByName(String ledgerName) async {
//     final db = await instance.database;
//     final result = await db.query(
//       'LedgerNames',
//       columns: ['Ledcode AS LedId', 'Mobile','OpeningBalance'],
//       where: 'LedName = ?',
//       whereArgs: [ledgerName],
//     );
//     if (result.isNotEmpty) {
//       return result.first;
//     }
//     return null;
//   }

// Future<List<Map<String, dynamic>>> queryFilteredRows({
//   DateTime? fromDate, 
//   DateTime? toDate, 
//   String? ledgerName,
  
// }) async {
//   Database db = await instance.database;

//   List<String> whereClauses = [];
//   List<dynamic> whereArgs = [];

//   // Build the WHERE clause based on the provided filters
//   if (ledgerName != null && ledgerName.isNotEmpty) {
//     whereClauses.add('LedName LIKE ?');
//     whereArgs.add('%$ledgerName%');
//   }


//   if (fromDate != null) {
//     whereClauses.add('date >= ?');
//     whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
//   }

//   if (toDate != null) {
//     whereClauses.add('date <= ?');
//     whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
//   }



//   String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

//   try {
//     return await db.query(
//       'LedgerNames',
//       where: whereClause.isNotEmpty ? whereClause : null,
//       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//     );
//   } catch (e) {
//     print("Error fetching filtered data: $e");
//     rethrow;
//   }
// }

//   Future<List<Map<String, dynamic>>> getAccTrans() async {
//     final db = await database;
//     final result = await db.query('account_Transactions');

//     return result;
//   }

//    Future<List<Map<String, dynamic>>> getLedgerData() async {
//     final db = await database;
//     final result = await db.query('LedgerNames');

//     return result.map((row) {
//       if (row['Photo'] != null) {
//         row['Photo'] = row['Photo'] as Uint8List;
//       }
//       return row;
//     }).toList();
//   }

//   // Helper function to check if a column exists in a table
//   Future<bool> _doesColumnExist(Database db, String tableName, String columnName) async {
//     final result = await db.rawQuery('PRAGMA table_info($tableName)');
//     return result.any((column) => column['name'] == columnName);
//   }

//   // Example of how to fetch data from the backup database
//   Future<List<Map<String, dynamic>>> getBackupLedgersWithTransactions() async {
//     final db = await backupDatabase;
//     final result = await db.rawQuery('SELECT * FROM LedgerWithTransactions');
//     return result;
//   }

// Future<Map<String, dynamic>?> getLedgerByName(String ledgerName) async {
//   final db = await instance.database;
//   final result = await db.query(
//     'LedgerNames', 
//     where: 'LedName = ?', 
//     whereArgs: [ledgerName],
//   );
//   return result.isNotEmpty ? result.first : null;
// }
// Future<void> updateLedgerBalance(String ledgerName, double newBalance) async {
//   final db = await database;
//   await db.update(
//     'LedgerNames', // Your ledger table name
//     {'OpeningBalance': newBalance}, // Use the correct column name for opening balance
//     where: 'Ledcode = ?', 
//     whereArgs: [ledgerName],
//   );
// }
// Future<bool> doesLedgerExist(String ledgerName) async {
//   Database db = await instance.database;
//   var result = await db.query(
//     'LedgerNames',
//     where: 'LedName = ?',
//     whereArgs: [ledgerName],
//   );
//   return result.isNotEmpty;
// }
// Future<void> updatePaymentBalance(String ledgerName,String total,String amt, double newBalance) async {
//   final db = await database;
//   await db.update(
//     'Account_Transactions', 
//     {'atDebitAmount': newBalance,
//     'atCreditAmount':total,
//     'atDebitAmount':amt,
//     }, 
//     where: 'ledgerName = ?', 
//     whereArgs: [ledgerName],
//   );
// }

// Future<List<Map<String, dynamic>>> getFilteredAccTrans(String atType) async {
//     final db = await database; // Ensure you have the correct database instance
//     return await db.query(
//       'Account_Transactions', // Replace with your table name
//       where: 'atType = ?',  // Filter by atType column
//       whereArgs: [atType],
//     );
//   }

// Future<void> insertLedgerDataIntoLedgerTable() async {
//   final ledgerDb = await database; // Ledger database instance
//   final companyLedgerDb = await LedgerDatabaseHelper.instance.database; // Company ledger database instance

//   // Fetch all data from LedgerNames
//   final ledgerNamesData = await companyLedgerDb.query('LedgerNames');

//   for (var ledger in ledgerNamesData) {
//     final ledgerName = ledger['LedName'] as String? ?? '';
//     final address = ledger['add1'] as String? ?? '';
//     final contact = ledger['Mobile'] as String? ?? '';
//     final mail = ledger['Email'] as String? ?? '';
//     final openingBalance = ledger['OpeningBalance'] as double? ?? 0.0;

//     // Fetch all transactions for the current ledger code
//     final accountTransactionsData = await companyLedgerDb.query(
//       'Account_Transactions',
//       where: 'atLedCode = ?',
//       whereArgs: [ledger['Ledcode']],
//     );

//     double receivedBalance = 0.0;
//     double payAmount = 0.0;

//     // Calculate receivedBalance and payAmount
//     for (var transaction in accountTransactionsData) {
//       receivedBalance += transaction['atDebitAmount'] as double? ?? 0.0;
//       payAmount += transaction['atCreditAmount'] as double? ?? 0.0;
//     }

//     // Prepare data for insertion into ledger_table
//     final ledgerRow = {
//       'ledger_name': ledgerName,
//       'address': address,
//       'contact': contact,
//       'mail': mail,
//       'opening_balance': openingBalance,
//       'received_balance': receivedBalance,
//       'pay_amount': payAmount,
//       'date': DateTime.now().toIso8601String(), // Example: Adding a default date
//     };

//     // Insert or update the ledger_table
//     await ledgerDb.insert(
//       'LedgerNames',
//       ledgerRow,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   print('Data successfully imported into LedgerNames.');
// }









// }
