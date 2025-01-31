

// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart';
// import 'package:mssql_connection/mssql_connection_platform_interface.dart';
// import 'package:sqflite/sqflite.dart';

// class AccountTransactionsDatabaseHelper {
//   static Database? _database;
//   static final AccountTransactionsDatabaseHelper _instance = AccountTransactionsDatabaseHelper._internal();

//   AccountTransactionsDatabaseHelper._internal();
//   static AccountTransactionsDatabaseHelper get instance => _instance;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     print('Initializing database...');
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final databasesPath = await getDatabasesPath();
//     final path = join(databasesPath, 'accountTransactions.db');

//     return openDatabase(
//       path,
//       version: 2,
//       onCreate: (db, version) async {
//         await _createAccountTransactionsTable(db);
//       },
//        onUpgrade: (db, oldVersion, newVersion) async {
//       if (oldVersion < 2) {
//         await db.execute("ALTER TABLE Account_Transactions ADD COLUMN atLedName TEXT DEFAULT ''");
//         print('Column atLedName added to Account_Transactions table.');
//          await db.execute("ALTER TABLE Account_Transactions ADD COLUMN  id INTEGER PRIMARY KEY AUTOINCREMENT ''");
//       }
//     },
//     );
    
//   }

//   Future<void> _createAccountTransactionsTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE Account_Transactions (
//         atLedCode TEXT PRIMARY KEY,
//         atEntryno TEXT,
//         atDebitAmount REAL,
//         atCreditAmount REAL,
//         atOpposite TEXT,
//         atSalesType TEXT,
//         atDate REAL DEFAULT 0,
//         atType TEXT,
//         Caccount TEXT,
//         atDiscount REAL,
//         atNaration TEXT
//       );
//     '''
//     );
//     print('Account_Transactions table created.');
//   }
//  Future<void> insertAccTrans(Map<String, dynamic> newTableData) async {
//     final db = await database;
//     await db.insert('Account_Transactions', newTableData, conflictAlgorithm: ConflictAlgorithm.replace);
//   }

// Future<void> insertData(List<Map<String, dynamic>> data) async {
//   final db = await database;

//   for (var row in data) {
//     try {
//       await db.insert(
//         'Account_Transactions',
//         row,
//         conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore duplicate entries
//       );
//     } catch (e) {
//       print('Insert error for row with atLedCode ${row['atLedCode']}: $e');
//     }
//   }

//   print('All rows inserted successfully.');
// }




//   Future<List<Map<String, dynamic>>> getAllTransactions() async {
//     final db = await database;
//     return await db.query('Account_Transactions');
//   }

//   Future<int> getRowCount() async {
//     final db = await database;
//     try {
//       final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Account_Transactions'));
//       print('SQLite Row Count: $count');
//       return count ?? 0;
//     } catch (e) {
//       print('Error fetching row count: $e');
//       return 0;
//     }
//   }

// Future<List<Map<String, dynamic>>> getFilteredAccTrans(String atType) async {
//     final db = await database; 
//     return await db.query(
//       'Account_Transactions', 
//       where: 'atType = ?', 
//       whereArgs: [atType],
//     );
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
//     whereClauses.add('atLedName LIKE ?');
//     whereArgs.add('%$ledgerName%');
//   }


//   if (fromDate != null) {
//     whereClauses.add('atDate >= ?');
//     whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
//   }

//   if (toDate != null) {
//     whereClauses.add('atDate <= ?');
//     whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
//   }



//   String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

//   try {
//     return await db.query(
//       'Account_Transactions',
//       where: whereClause.isNotEmpty ? whereClause : null,
//       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//     );
//   } catch (e) {
//     print("Error fetching filtered data: $e");
//     rethrow;
//   }
// }

//   Future<void> enableWALMode() async {
//     final db = await database;
//     try {
//       await db.execute('PRAGMA journal_mode=WAL;');
//       print('WAL mode enabled.');
//     } catch (e) {
//       print('Error enabling WAL mode: $e');
//     }
//   }

//   Future<void> updateOpeningBalances() async {
//   final db = await database;

//   try {
//     // Fetch unique ledger codes from Account_Transactions, ignoring NULL or blank values
//     final ledgerCodes = await db.rawQuery(
//       '''
//       SELECT DISTINCT atLedCode 
//       FROM Account_Transactions 
//       WHERE atLedCode IS NOT NULL AND atLedCode != ""
//       '''
//     );

//     if (ledgerCodes.isEmpty) {
//       print('No valid ledger codes found in Account_Transactions table.');
//       return;
//     }

//     for (var ledger in ledgerCodes) {
//       final ledgerCode = ledger['atLedCode'];

//       // Calculate the opening balance for this ledger
//       final result = await db.rawQuery(
//         '''
//         SELECT 
//           COALESCE(SUM(atCreditAmount), 0) AS totalCredits,
//           COALESCE(SUM(atDebitAmount), 0) AS totalDebits
//         FROM Account_Transactions
//         WHERE atLedCode = ?
//         ''',
//         [ledgerCode],
//       );

//       final totalCredits = (result.first['totalCredits'] as num).toDouble();
//       final totalDebits = (result.first['totalDebits'] as num).toDouble();
//       final openingBalance = totalCredits - totalDebits;

//       // Check if the ledger code exists in LedgerNames
//       final ledgerExists = await db.query(
//         'LedgerNames',
//         columns: ['Ledcode'],
//         where: 'Ledcode = ?',
//         whereArgs: [ledgerCode],
//       );

//       if (ledgerExists.isNotEmpty) {
//         // Update the opening balance in LedgerNames
//         await db.update(
//           'LedgerNames',
//           {'OpeningBalance': openingBalance},
//           where: 'Ledcode = ?',
//           whereArgs: [ledgerCode],
//         );

//         print('Updated ledger $ledgerCode with opening balance: $openingBalance');
//       } else {
//         print('Ledger $ledgerCode does not exist in LedgerNames table.');
//       }
//     }

//     print('Opening balances updated successfully.');
//   } catch (e) {
//     print('Error updating opening balances: $e');
//   }
// }
// }

// Future<List<Map<String, dynamic>>> fetchDataFromMSSQLAccTransations() async {
//   try {
//     final query = '''
//       SELECT atLedCode, atDate, atType, atEntryno, atDebitAmount, 
//              atCreditAmount, atOpposite, atSalesType 
//       FROM Account_Transactions
//     ''';

//     // Fetch data using MsSQLConnectionPlatform
//     final rawData = await MsSQLConnectionPlatform.instance.getData(query);

//     if (rawData is String) {
//       final decodedData = jsonDecode(rawData);

//       if (decodedData is List) {
//         final completeData = decodedData.map((row) {
//           // Ensure that null values are replaced with default values
//           return {
//             'atLedCode': row['atLedCode'] ?? '',
//             'atDate': row['atDate'] ?? '',
//             'atType': row['atType'] ?? '',
//             'atEntryno': row['atEntryno'] ?? '',
//             'atDebitAmount': row['atDebitAmount'] ?? 0.0,
//             'atCreditAmount': row['atCreditAmount'] ?? 0.0,
//             'atOpposite': row['atOpposite'] ?? '',
//             'atSalesType': row['atSalesType'] ?? '',
//           };
//         }).toList();

//         // Debug log for validation
//         if (completeData.isNotEmpty) {
//           print('First Row: ${completeData.first}');
//           print('Total Rows Fetched: ${completeData.length}');
//         } else {
//           print('No rows fetched from MSSQL table.');
//         }

//         return completeData;
//       } else {
//         throw Exception('Unexpected JSON format received: $decodedData');
//       }
//     } else {
//       throw Exception('Invalid data format received: $rawData');
//     }
//   } catch (e) {
//     print('Error fetching data from MSSQL: $e');
//     rethrow;
//   }
// }


// Future<void> backupMSSQLToSQLite() async {
//   final dbHelper = AccountTransactionsDatabaseHelper.instance;
//   await dbHelper.enableWALMode();

//   try {
//     final completeData = await fetchDataFromMSSQLAccTransations();

//     if (completeData.isEmpty) {
//       print('No data to backup. Exiting.');
//       return;
//     }

//     print('Total data to insert: ${completeData.length}');
//     await dbHelper.insertData(completeData);

//     final sqliteRowCount = await dbHelper.getRowCount();
//     print('SQLite contains $sqliteRowCount rows after backup.');

//     if (sqliteRowCount != completeData.length) {
//       print('Mismatch in row count! Fetched: ${completeData.length}, Inserted: $sqliteRowCount');
//     } else {
//       print('Backup successful. All rows are backed up.');
//     }
//   } catch (e) {
//     print('Error during backup: $e');
//   }
// }




import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AccountTransactionsDatabaseHelper {
  static final AccountTransactionsDatabaseHelper instance =
      AccountTransactionsDatabaseHelper._init();

  static Database? _database;

  AccountTransactionsDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('account_transactions.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accountTransactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Auto TEXT,
        atDate TEXT,
        atLedCode TEXT,
        atType TEXT,
        atEntryno TEXT,
        atDebitAmount REAL,
        atCreditAmount REAL,
        atNarration TEXT,
        atOpposite TEXT,
        atSalesEntryno TEXT,
        atSalesType TEXT,
        atLocation TEXT,
        atChequeNo TEXT,
        atProject TEXT,
        atBankEntry TEXT,
        atInvestor TEXT,
        atFyID TEXT,
        atFxDebit TEXT,
        atFxCredit TEXT
        
      )
    ''');
  }
Future<int> insertTransaction(Map<String, dynamic> data) async {
  final db = await database;
    try {
      return await db.insert(
        'accountTransactions',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Failed to insert data into Product_Registration: $e");
    }
}






  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await instance.database;
    return await db.query('accountTransactions');
  }
}
