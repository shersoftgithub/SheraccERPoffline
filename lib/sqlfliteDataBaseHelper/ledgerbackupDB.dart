// import 'dart:typed_data';
// import 'dart:io';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class CompanyLEdgerDatabaseHelper {
//   static Database? _database;
//   static final CompanyLEdgerDatabaseHelper _instance = CompanyLEdgerDatabaseHelper._internal();

//   CompanyLEdgerDatabaseHelper._internal();
//   static CompanyLEdgerDatabaseHelper get instance => _instance;
  
//   Future<Database> get database async {
//     if (_database != null) return _database!;
    
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final databasesPath = await getDatabasesPath();
//     final path = join(databasesPath, 'companyLedger.db');
    
//     return openDatabase(
//       path,
//       version: 3, 
//       onCreate: _createDatabase,
//       onUpgrade: _onUpgrade, 
//     );
//   }

//   Future<void> _createDatabase(Database db, int version) async {
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
//         OpeningBalance
//       );
//     ''');

//     await db.execute('''
//       CREATE TABLE Account_Transactions (
//         atLedCode TEXT PRIMARY KEY,
//         atEntryno TEXT,
//         atDebitAmount REAL,
//         atCreditAmount REAL,
//         atOpposite TEXT,
//         atSalesType TEXT,
//       );
//     ''');
//   }

// Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//   print('Upgrading database from version $oldVersion to $newVersion');

//   if (oldVersion < 4) {
//     // Version 3: Create the `account_Transactions` table
//     try {
//       await db.execute('''
//         CREATE TABLE IF NOT EXISTS account_Transactions (
//           atLedCode TEXT PRIMARY KEY,
//           atEntryno TEXT,
//           atDebitAmount REAL,
//           atCreditAmount REAL,
//           atOpposite TEXT,
//           atSalesType TEXT,
//           atDate REAL DEFAULT 0,
//           atType TEXT
//         );
//       ''');
//       print('Table account_Transactions created successfully.');
//     } catch (e) {
//       print('Error creating account_Transactions table: $e');
//     }
//   }

// }

// /// Helper function to check if a column exists in a table
// Future<bool> _doesColumnExist(Database db, String tableName, String columnName) async {
//   final result = await db.rawQuery('PRAGMA table_info($tableName)');
//   return result.any((column) => column['name'] == columnName);
// }





//   // Insert data into LedgerNames table
//   Future<void> insertLedgerData(Map<String, dynamic> ledgerData) async {
//     final db = await database;

//     await db.insert(
//       'LedgerNames',
//       ledgerData,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // Fetch all data from LedgerNames table
//   Future<List<Map<String, dynamic>>> getLedgerData() async {
//     final db = await database;
//     final result = await db.query('LedgerNames');

//     return result.map((row) {
//       if (row['Photo'] != null) {
//         row['Photo'] = row['Photo'] as Uint8List;
//       }
//       return row;
//     }).toList();
//   }

//   // Fetch all Ledger Names
//   Future<List<String>> getAllNames() async {
//     final db = await instance.database;
//     final result = await db.query('LedgerNames', columns: ['LedName']);
//     return result.map((item) => item['LedName'] as String).toList();
//   }

//   Future<Map<String, dynamic>?> getLedgerDetailsByName(String ledgerName) async {
//     final db = await instance.database;

//     final result = await db.query(
//       'LedgerNames',
//       columns: ['Ledcode AS LedId', 'Mobile'],
//       where: 'LedName = ?',
//       whereArgs: [ledgerName],
//     );

//     if (result.isNotEmpty) {
//       return result.first;
//     }

//     return null; 
//   }

//   Future<void> insertAccTrans(Map<String, dynamic> newTableData) async {
//     final db = await database;

//     await db.insert(
//       'account_Transactions',
//       newTableData,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<Map<String, dynamic>>> getAccTrans() async {
//     final db = await database;
//     final result = await db.query('account_Transactions');

//     return result;
//   }

// Future<void> updateOpeningBalanceForLedcode() async {
//   final db = await database;

//   try {
//     // Fetch distinct atLedCode values from Account_Transactions
//     final transactions = await db.rawQuery('''
//       SELECT 
//         atLedCode, 
//         SUM(atDebitAmount) AS totalDebit, 
//         SUM(atCreditAmount) AS totalCredit 
//       FROM Account_Transactions 
//       GROUP BY atLedCode
//     ''');

//     for (var transaction in transactions) {
//       final atLedCode = transaction['atLedCode'] as String?;
//       final totalDebit = (transaction['totalDebit'] as num?) ?? 0.0;
//       final totalCredit = (transaction['totalCredit'] as num?) ?? 0.0;

//       if (atLedCode != null) {
//         // Check if the atLedCode exists in LedgerNames
//         final ledgerExists = await db.rawQuery('''
//           SELECT COUNT(*) as count 
//           FROM LedgerNames 
//           WHERE Ledcode = ?
//         ''', [atLedCode]);

//         if ((ledgerExists.first['count'] as int) > 0) {
//           // Calculate opening balance
//           final openingBalance = totalCredit - totalDebit;
//           final balanceType = openingBalance > 0 ? 'Cr' : 'Dr';
//           final formattedBalance = '${openingBalance.abs()} $balanceType';

//           // Update OpeningBalance column
//           await db.update(
//             'LedgerNames',
//             {'OpeningBalance': openingBalance},
//             where: 'Ledcode = ?',
//             whereArgs: [atLedCode],
//           );

//           print('Updated $atLedCode with balance: $formattedBalance');
//         } else {
//           print('atLedCode $atLedCode does not exist in LedgerNames.');
//         }
//       }
//     }

//     print('All opening balances updated successfully.');
//   } catch (e) {
//     print('Error updating opening balances: $e');
//   }
// }


// Future<List<Map<String, dynamic>>> calculateOpeningBalances() async {
//   final db = await database;

//   try {
//     // Fetch distinct atLedCode values and their debit/credit totals
//     final transactions = await db.rawQuery('''
//       SELECT 
//         atLedCode, 
//         SUM(atDebitAmount) AS totalDebit, 
//         SUM(atCreditAmount) AS totalCredit 
//       FROM Account_Transactions 
//       GROUP BY atLedCode
//     ''');

//     // Initialize a list to store the results
//     List<Map<String, dynamic>> openingBalances = [];

//     for (var transaction in transactions) {
//       final atLedCode = transaction['atLedCode'] as String?;
//       final totalDebit = (transaction['totalDebit'] as num?) ?? 0.0;
//       final totalCredit = (transaction['totalCredit'] as num?) ?? 0.0;

//       if (atLedCode != null) {
//         // Calculate the opening balance
//         final openingBalance = totalCredit - totalDebit;
//         final balanceType = openingBalance > 0 ? 'Cr' : 'Dr';
//         final formattedBalance = '${openingBalance.abs()} $balanceType';

//         // Add the calculated balance to the list
//         openingBalances.add({
//           'atLedCode': atLedCode,
//           'totalDebit': totalDebit,
//           'totalCredit': totalCredit,
//           'openingBalance': formattedBalance,
//         });

//         print('atLedCode: $atLedCode, Opening Balance: $formattedBalance');
//       }
//     }

//     print('Calculated opening balances for all atLedCode values successfully.');
//     return openingBalances; // Return the list of opening balances
//   } catch (e) {
//     print('Error calculating opening balances: $e');
//     return [];
//   }
// }




// Future<void> updateAllOpeningBalances() async {
//   final db = await database;

//   try {
//     // Fetch all Ledcode values from the LedgerNames table
//     final ledgers = await db.query('LedgerNames', columns: ['Ledcode']);

//     for (var ledger in ledgers) {
//       final ledCode = ledger['Ledcode'] as String;

//       await updateOpeningBalanceForLedcode();
//     }

//     print('Opening balances for all Ledcodes updated successfully.');
//   } catch (e) {
//     print('Error updating all opening balances: $e');
//   }
// }


// }
