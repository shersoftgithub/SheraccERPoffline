// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:intl/intl.dart';
// import 'package:mssql_connection/mssql_connection_platform_interface.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class LedgerTransactionsDatabaseHelper {
//   static Database? _database;
//   static final LedgerTransactionsDatabaseHelper _instance = LedgerTransactionsDatabaseHelper._internal();

//   LedgerTransactionsDatabaseHelper._internal();
//   static LedgerTransactionsDatabaseHelper get instance => _instance;

//   // Database for Ledger and Account Transactions
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase('ledgerTransactionsDB.db');
//     return _database!;
//   }

//   // Initialize database
//   Future<Database> _initDatabase(String dbName) async {
//     final databasesPath = await getDatabasesPath();
//     final path = join(databasesPath, dbName);

//     return openDatabase(
//       path,
//       version: 9,
//       onCreate: (db, version) async {
//         await _createDatabase(db);
//       },
//        onUpgrade: (db, oldVersion, newVersion) async {
//     if (oldVersion < 9) {
//         await db.execute("ALTER TABLE Account_Transactions ADD COLUMN atLedName TEXT");
//         print('Column atLedName added to Account_Transactions table.');
//          //await db.execute("ALTER TABLE Account_Transactions ADD COLUMN  id INTEGER PRIMARY KEY AUTOINCREMENT ''");
//          await db.execute("ALTER TABLE Account_Transactions ADD COLUMN Caccount TEXT DEFAULT ''");
//       }
//   },
//     );
//   }

//   // Create tables
//  Future<void> _createDatabase(Database db) async {
//   try {
//     // Create LedgerNames table
//     await db.execute(''' 
//       CREATE TABLE IF NOT EXISTS LedgerNames (
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
//         OpeningBalance REAL,
//         under TEXT,
//         Debit REAL DEFAULT 0,
//         date TEXT,
//         balance REAL DEFAULT 0
//       );
//     ''');

//     // Create Account_Transactions table
//     await db.execute(''' 
//       CREATE TABLE IF NOT EXISTS Account_Transactions (
//        Auto TEXT,
//         atDate TEXT,
//         atLedCode TEXT,
//         atType TEXT,
//         atEntryno TEXT,
//         atDebitAmount REAL,
//         atCreditAmount REAL,
//         atNarration TEXT,
//         atOpposite TEXT,
//         atSalesEntryno TEXT,
//         atSalesType TEXT,
//         atLocation TEXT,
//         atChequeNo TEXT,
//         atProject TEXT,
//         atBankEntry TEXT,
//         atInvestor TEXT,
//         atFyID TEXT,
//         atFxDebit TEXT,
//         atFxCredit TEXT
//         Caccount TEXT,
//         atDiscount REAL,
//         atNaration TEXT
//       );
//     ''');

//     print('Tables created successfully.');
//   } catch (e) {
//     print('Error creating tables: $e');
//     rethrow;
//   }
//   }

// // Insert data into LedgerNames table with debugging
// Future<void> insertLedgerData(Map<String, dynamic> ledgerData) async {
//   final db = await database;

//   try {
//     // Debugging: Print the data to be inserted
//     print('Inserting LedgerData: $ledgerData');

//     // Insert the data into the LedgerNames table
//     final result = await db.insert(
//       'LedgerNames',
//       ledgerData,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

//     if (result > 0) {
//       print('Insertion successful. Row inserted with ID: $result');
//     } else {
//       print('Insertion failed. No row inserted.');
//     }

//     final checkResult = await db.query(
//       'LedgerNames',
//       where: 'Ledcode = ?',
//       whereArgs: [ledgerData['Ledcode']],
//     );

//     if (checkResult.isNotEmpty) {
//       print('Data successfully inserted: ${checkResult.first}');
//     } else {
//       print('Data insertion was unsuccessful. Unable to find the inserted record.');
//     }
//   } catch (e) {
//     print('Error inserting ledger data: $e');
//   }
// }

// ////////////////////////////////Account traancsaction functions ///////////////////////////////

//   // Insert data into Account_Transactions table
//  Future<void> insertAccTrans(Map<String, dynamic> newTableData) async {
//     final db = await database;
//     await db.insert('Account_Transactions', newTableData, conflictAlgorithm: ConflictAlgorithm.replace);
//   }
// Future<void> insertData(List<Map<String, dynamic>> data) async {
//   final db = await database; // Get the SQLite database instance

//   for (final row in data) {
//     await db.insert(
//       'Account_Transactions',
//       {
//         'Auto': row['Auto'] ?? '',
//         'atDate': row['atDate'] ?? '',
//         'atLedCode': row['atLedCode'] ?? '',       
//         'atType': row['atType'] ?? '',
//         'atEntryno': row['atEntryno'] ?? '',
//         'atDebitAmount': row['atDebitAmount'] ?? 0.0,
//         'atCreditAmount': row['atCreditAmount'] ?? 0.0,
//         'atNarration': row['atNarration'] ?? '',
//         'atOpposite': row['atOpposite'] ?? '',
//         'atSalesEntryno': row['atSalesEntryno'] ?? '',
//         'atSalesType': row['atSalesType'] ?? '',
//         'atLocation': row['atLocation'] ?? '',
//         'atChequeNo': row['atChequeNo'] ?? '',
//         'atProject': row['atProject'] ?? '',
//         'atBankEntry': row['atBankEntry'] ?? '',
//         'atInvestor': row['atInvestor'] ?? '',
//         'atFyID': row['atFyID'] ?? '',
//         'atFxDebit': row['atFxDebit'] ?? '',
//         'atFxCredit': row['atFxCredit'] ?? '',
//       },
//       conflictAlgorithm: ConflictAlgorithm.ignore, // Use IGNORE to prevent overwriting duplicates
//     );
//   }

//   print('Data inserted successfully into SQLite.');
// }



// Future<List<Map<String, dynamic>>> getAllTransactions() async {
//     final db = await database;
//     return await db.query('Account_Transactions');
//   }
// Future<int> getRowCount() async {
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
//   Future<List<Map<String, dynamic>>> getFilteredAccTrans(String atType) async {
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

//   // Always filter by atType = 'PAYMENT'
//   whereClauses.add('atType = ?');
//   whereArgs.add('RECIEPT');

//   // Add ledgerName filter if provided
//   if (ledgerName != null && ledgerName.isNotEmpty) {
//     whereClauses.add('atLedName LIKE ?');
//     whereArgs.add('%$ledgerName%');
//   }

//   // Add fromDate filter if provided
//   if (fromDate != null) {
//     whereClauses.add('atDate >= ?');
//     whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
//   }

//   // Add toDate filter if provided
//   if (toDate != null) {
//     whereClauses.add('atDate <= ?');
//     whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
//   }

//   // Combine all where clauses
//   String whereClause = whereClauses.join(' AND ');

//   try {
//     return await db.query(
//       'Account_Transactions',
//       where: whereClause,
//       whereArgs: whereArgs,
//     );
//   } catch (e) {
//     print("Error fetching filtered data: $e");
//     rethrow;
//   }
// }
// Future<List<Map<String, dynamic>>> queryFilteredRowsPay({
//   DateTime? fromDate, 
//   DateTime? toDate, 
//   String? ledgerName,
// }) async {
//   Database db = await instance.database;

//   List<String> whereClauses = [];
//   List<dynamic> whereArgs = [];

//   // Always filter by atType = 'PAYMENT'
//   whereClauses.add('atType = ?');
//   whereArgs.add('PAYMENT');

//   // Add ledgerName filter if provided
//   if (ledgerName != null && ledgerName.isNotEmpty) {
//     whereClauses.add('atLedName LIKE ?');
//     whereArgs.add('%$ledgerName%');
//   }

//   // Add fromDate filter if provided
//   if (fromDate != null) {
//     whereClauses.add('atDate >= ?');
//     whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
//   }

//   // Add toDate filter if provided
//   if (toDate != null) {
//     whereClauses.add('atDate <= ?');
//     whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
//   }

//   // Combine all where clauses
//   String whereClause = whereClauses.join(' AND ');

//   try {
//     return await db.query(
//       'Account_Transactions',
//       where: whereClause,
//       whereArgs: whereArgs,
//     );
//   } catch (e) {
//     print("Error fetching filtered data: $e");
//     rethrow;
//   }
// }


// Future<void> enableWALMode() async {
//     final db = await database;
//     try {
//       await db.execute('PRAGMA journal_mode=WAL;');
//       print('WAL mode enabled.');
//     } catch (e) {
//       print('Error enabling WAL mode: $e');
//     }
//   }

// Future<double> getOpeningBalanceForLedger(String ledgerName) async {
//   final db = await database;
//   var result = await db.rawQuery(''' 
//     SELECT SUM(atDebitAmount) as OpeningBalance 
//     FROM Account_Transactions 
//     WHERE atLedName = ? 
//   ''', [ledgerName]);

//   if (result.isNotEmpty && result.first['OpeningBalance'] != null) {
//     return (result.first['OpeningBalance'] as num).toDouble(); // Cast to double
//   } else {
//     return 0.0;
//   }
// }
// Future<double> getDebitAmountForLedger(String ledgerName) async {
//   final db = await database;  // Assuming you have a database connection established

//   // Query to get the sum of all debit amounts for the given ledger name
//   var result = await db.rawQuery(
//     'SELECT SUM(atDebitAmount) FROM Account_Transactions WHERE atLedName = ?',
//     [ledgerName],
//   );

//   // If the result is not empty and contains a valid value
//   if (result.isNotEmpty && result.first['SUM(atDebitAmount)'] != null) {
//     // Safely return the sum as a double (ensuring null safety)
//     return result.first['SUM(atDebitAmount)'] as double? ?? 0.0;
//   } else {
//     // If the result is empty or null, return 0.0
//     return 0.0;
//   }
// }







//   ////////////////////////ledger names table functions ///////////////////
  

//   Future<List<Map<String, dynamic>>> getLedgersWithTransactions() async {
//     final db = await database;  // Use the primary database or backup as needed
//     final result = await db.rawQuery('SELECT * FROM LedgerWithTransactions');
//     return result;
//   }
  
//   // Get all Ledger Names
//   Future<List<String>> getAllNames() async {
//     final db = await instance.database;
//     final result = await db.query('LedgerNames', columns: ['LedName']);
//     return result.map((item) => item['LedName'] as String).toList();
//   }

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

// Future<List<Map<String, dynamic>>> queryFilteredRowsledger({
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
//   // Get filtered account transactions by type
//   Future<List<Map<String, dynamic>>> getFilteredAccountTransactions(String atType) async {
//     final db = await database;
//     return await db.query(
//       'Account_Transactions',
//       where: 'atType = ?',
//       whereArgs: [atType],
//     );
//   }

//   // Get account transactions by ledger code
//   Future<List<Map<String, dynamic>>> getAccountTransactionsByLedgerCode(String ledgerCode) async {
//     final db = await database;
//     return await db.query(
//       'Account_Transactions',
//       where: 'atLedCode = ?',
//       whereArgs: [ledgerCode],
//     );
//   }

//   // Update ledger balance
//   Future<void> updateLedgerBalance(String ledgerCode, double newBalance) async {
//     final db = await database;
//     await db.update(
//       'LedgerNames',
//       {'OpeningBalance': newBalance},
//       where: 'Ledcode = ?',
//       whereArgs: [ledgerCode],
//     );
//   }

//   // Update account transaction payment balance
//   Future<void> updatePaymentBalance(String ledgerCode, double total, double amt, double newBalance) async {
//     final db = await database;
//     await db.update(
//       'Account_Transactions',
//       {'atDebitAmount': newBalance, 'atCreditAmount': total, 'atDebitAmount': amt},
//       where: 'atLedCode = ?',
//       whereArgs: [ledgerCode],
//     );
//   }

//   // Query filtered rows from LedgerNames
//   Future<List<Map<String, dynamic>>> queryFilteredLedgerRows({
//     DateTime? fromDate,
//     DateTime? toDate,
//     String? ledgerName,
//   }) async {
//     final db = await database;
//     List<String> whereClauses = [];
//     List<dynamic> whereArgs = [];

//     if (ledgerName != null && ledgerName.isNotEmpty) {
//       whereClauses.add('LedName LIKE ?');
//       whereArgs.add('%$ledgerName%');
//     }

//     if (fromDate != null) {
//       whereClauses.add('date >= ?');
//       whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
//     }

//     if (toDate != null) {
//       whereClauses.add('date <= ?');
//       whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
//     }

//     String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

//     try {
//       return await db.query(
//         'LedgerNames',
//         where: whereClause.isNotEmpty ? whereClause : null,
//         whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
//       );
//     } catch (e) {
//       print("Error fetching filtered data: $e");
//       rethrow;
//     }
//   }

//   Future<void> insertOrUpdateLedgerData(Map<String, dynamic> ledgerData) async {
//     final db = await database;
//     await db.insert(
//       'LedgerNames',
//       ledgerData,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
//    Future<bool> _doesColumnExist(Database db, String tableName, String columnName) async {
//     final result = await db.rawQuery('PRAGMA table_info($tableName)');
//     return result.any((column) => column['name'] == columnName);
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
// Future<void> insertDataIntoSQLite(List<Map<String, dynamic>> data) async {
//   final database = await openDatabase('ledgerTransactionsDB.db');

//   for (final row in data) {
//     await database.insert(
//       'Account_Transactions',
//       {
//         'Auto': row['Auto']?.toString() ?? '',
//     'atDate': row['atDate']?.toString() ?? '',
//     'atLedCode': row['atLedCode']?.toString() ?? '', 
//       'atType': row['atType']?.toString() ?? '',
//     'atEntryno': row['atEntryno']?.toString() ?? '', 
//     'atDebitAmount': row['atDebitAmount'] != null ? row['atDebitAmount'] : 0.0, 
//     'atCreditAmount': row['atCreditAmount'] != null ? row['atCreditAmount'] : 0.0, 
//      'atNarration': row['atNarration']?.toString() ?? '',
//     'atOpposite': row['atOpposite']?.toString() ?? '',     
//     'atSalesEntryno': row['atSalesEntryno']?.toString() ?? '',
//     'atSalesType': row['atSalesType']?.toString() ?? 'Default SalesType',
//     'atLocation': row['atLocation']?.toString() ?? '',
//     'atChequeNo': row['atChequeNo']?.toString() ?? '',
//     'atProject': row['atProject']?.toString() ?? '',
//     'atBankEntry': row['atBankEntry']?.toString() ?? '',
//     'atInvestor': row['atInvestor']?.toString() ?? '',
//     'atFyID': row['atFyID']?.toString() ?? '',
//     'atFxDebit': row['atFxDebit']?.toString() ?? '',
//     'atFxCredit': row['atFxCredit']?.toString() ?? '',
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   print('Data inserted successfully into SQLite.');
// }

// Future<List<Map<String, dynamic>>> fetchSQLiteData() async {
//   final db = await getDatabase(); // Implement this to initialize SQLite database
//   return await db.query('ledgernames');
// }
// Future<Database> getDatabase() async {
//   return database;
// }
// Future<void> fetchDataFromMSSQLCompany() async {
//   try {
//     final query =
//         'SELECT Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state, Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location, OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate, SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount FROM LedgerNames';
//     final rawData = await MsSQLConnectionPlatform.instance.getData(query);

//     if (rawData is String) {
//       final decodedData = jsonDecode(rawData);
//       if (decodedData is List) {
//         final records = decodedData.map((row) => Map<String, dynamic>.from(row)).toList();

//         // Insert into SQLite
//         final db = await getDatabase(); // Implement this function to initialize SQLite database
//         for (var record in records) {
//           await db.insert(
//             'ledgernames',
//             record,
//             conflictAlgorithm: ConflictAlgorithm.replace, // Prevent duplication
//           );
//         }
//         print('Data synchronized to SQLite successfully.');
//       } else {
//         throw Exception('Unexpected JSON format for LedgerNames data: $decodedData');
//       }
//     } else {
//       throw Exception('Unexpected data format for LedgerNames: $rawData');
//     }
//   } catch (e) {
//     print('Error fetching and syncing data: $e');
//     rethrow;
//   }
// }

// Future<void> fetchAndInsertIntoSQLite() async {
//   final dbHelper = LedgerTransactionsDatabaseHelper.instance;

//   try {
//     // Fetch data from MSSQL (returns List<Map<String, dynamic>>)
//     final List<Map<String, dynamic>> fetchedData = await fetchDataFromMSSQLAccTransations();

//     if (fetchedData.isEmpty) {
//       print('No data fetched from MSSQL.');
//       return;
//     }

//     // Insert or update the data into SQLite's LedgerNames table
//     await dbHelper.insertOrUpdateLedgerDataInSQLite(fetchedData);

//     print('Fetched and inserted data from MSSQL to SQLite.');
//   } catch (e) {
//     print('Error in fetchAndInsertIntoSQLite: $e');
//   }
// }

// Future<void> insertOrUpdateLedgerDataInSQLite(List<Map<String, dynamic>> ledgerDataList) async {
//   final db = await database;

//   for (var ledgerData in ledgerDataList) {
//     final result = await db.insert(
//       'LedgerNames', 
//       ledgerData,
//       conflictAlgorithm: ConflictAlgorithm.replace, 
//     );

//     if (result > 0) {
//       print('Ledger data inserted or updated successfully.');
//     } else {
//       print('Failed to insert/update ledger data.');
//     }
//   }
// }


// Future<void> syncLedgerNamesToMSSQL() async {
//   final db = await database;
//   final modifiedData = await db.query('LedgerNames'); 

//   for (var data in modifiedData) {
  
//     final ledgerCode = data['Ledcode'];
//         await updateMSSQLLedger(data);
//   }
// }

// Future<void> updateMSSQLLedger(Map<String, dynamic> ledgerData) async {
//   try {
//     // Helper function to escape strings and handle nulls
//     String escapeString(String? value, {bool allowNull = false}) {
//       if (value == null || value.isEmpty) {
//         return allowNull ? 'NULL' : "''"; // Handle NULL and empty string
//       }
//       return "'${value.replaceAll("'", "''")}'"; // Escape single quotes
//     }

//     // Ensure that critical fields are non-null
//     final ledcode = ledgerData['Ledcode'];
//     final ledName = ledgerData['LedName'];

//     if (ledcode == null || ledcode.isEmpty) {
//       throw Exception('Ledcode is required and cannot be null or empty');
//     }
//     if (ledName == null || ledName.isEmpty) {
//       throw Exception('LedName is required and cannot be null or empty');
//     }

//     // Null handling and escaping for all fields
//     final lhId = ledgerData['lh_id'] ?? 0;
//     final add1 = escapeString(ledgerData['add1'], allowNull: true);
//     final add2 = escapeString(ledgerData['add2'], allowNull: true);
//     final add3 = escapeString(ledgerData['add3'], allowNull: true);
//     final add4 = escapeString(ledgerData['add4'], allowNull: true);
//     final city = escapeString(ledgerData['city'], allowNull: true);
//     final route = escapeString(ledgerData['route'], allowNull: true);
//     final state = escapeString(ledgerData['state'], allowNull: true);
//     final mobile = escapeString(ledgerData['Mobile'], allowNull: true);
//     final pan = escapeString(ledgerData['pan'], allowNull: true);
//     final email = escapeString(ledgerData['Email'], allowNull: true);
//     final gstno = escapeString(ledgerData['gstno'], allowNull: true);
//     final cAmount = ledgerData['CAmount'] ?? 0.0;
//     final active = ledgerData['Active'] ?? false;
//     final salesMan = escapeString(ledgerData['SalesMan'], allowNull: true);
//     final location = escapeString(ledgerData['Location'], allowNull: true);
//     final orderDate = escapeString(ledgerData['OrderDate'], allowNull: true);
//     final deliveryDate = escapeString(ledgerData['DeliveryDate'], allowNull: true);
//     final cPerson = escapeString(ledgerData['CPerson'], allowNull: true);
//     final costCenter = escapeString(ledgerData['CostCenter'], allowNull: true);
//     final franchisee = escapeString(ledgerData['Franchisee'], allowNull: true);
//     final salesRate = ledgerData['SalesRate'] ?? 0.0;
//     final subGroup = escapeString(ledgerData['SubGroup'], allowNull: true);
//     final secondName = escapeString(ledgerData['SecondName'], allowNull: true);
//     final userName = escapeString(ledgerData['UserName'], allowNull: true);
//     final password = escapeString(ledgerData['Password'], allowNull: true);
//     final customerType = escapeString(ledgerData['CustomerType'], allowNull: true);
//     final otp = escapeString(ledgerData['OTP'], allowNull: true);
//     final maxDiscount = ledgerData['maxDiscount'] ?? 0.0;

//     // Convert the `active` field to 1 (true) or 0 (false) for the SQL query
//     final activeForQuery = active ? 1 : 0;

//     // Constructing the SQL query
//     final query = '''
//       MERGE INTO LedgerNames AS target
//       USING (VALUES ($ledcode, $ledName, $lhId, $add1, $add2, $add3, $add4, $city, $route, $state, 
//                      $mobile, $pan, $email, $gstno, $cAmount, $activeForQuery, $salesMan, $location, 
//                      $orderDate, $deliveryDate, $cPerson, $costCenter, $franchisee, $salesRate, 
//                      $subGroup, $secondName, $userName, $password, $customerType, $otp, $maxDiscount)) 
//       AS source (
//           Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state, Mobile, pan, Email, gstno,
//           CAmount, Active, SalesMan, Location, OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee,
//           SalesRate, SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount
//       )
//       ON target.Ledcode = source.Ledcode
//       WHEN MATCHED THEN 
//           UPDATE SET 
//               target.LedName = source.LedName, target.lh_id = source.lh_id, 
//               target.add1 = source.add1, target.add2 = source.add2, target.add3 = source.add3,
//               target.add4 = source.add4, target.city = source.city, target.route = source.route,
//               target.state = source.state, target.Mobile = source.Mobile, target.pan = source.pan,
//               target.Email = source.Email, target.gstno = source.gstno, target.CAmount = source.CAmount,
//               target.Active = source.Active, target.SalesMan = source.SalesMan, target.Location = source.Location,
//               target.OrderDate = source.OrderDate, target.DeliveryDate = source.DeliveryDate, 
//               target.CPerson = source.CPerson, target.CostCenter = source.CostCenter, 
//               target.Franchisee = source.Franchisee, target.SalesRate = source.SalesRate, 
//               target.SubGroup = source.SubGroup, target.SecondName = source.SecondName,
//               target.UserName = source.UserName, target.Password = source.Password,
//               target.CustomerType = source.CustomerType, target.OTP = source.OTP, 
//               target.maxDiscount = source.maxDiscount
//       WHEN NOT MATCHED BY TARGET THEN
//           INSERT (Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state, Mobile, pan, Email, gstno,
//                   CAmount, Active, SalesMan, Location, OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee,
//                   SalesRate, SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount)
//           VALUES (source.Ledcode, source.LedName, source.lh_id, source.add1, source.add2, source.add3, 
//                   source.add4, source.city, source.route, source.state, source.Mobile, source.pan, source.Email, 
//                   source.gstno, source.CAmount, source.Active, source.SalesMan, source.Location, source.OrderDate, 
//                   source.DeliveryDate, source.CPerson, source.CostCenter, source.Franchisee, source.SalesRate, 
//                   source.SubGroup, source.SecondName, source.UserName, source.Password, source.CustomerType, 
//                   source.OTP, source.maxDiscount);
//     ''';

//     // Log the SQL query for debugging
//     print('Executing SQL query: $query');

//     // Ensure connection is properly initialized (check if it's null)
//     final connection = MsSQLConnectionPlatform.instance;
//     if (connection == null) {
//       throw Exception('Database connection is not initialized.');
//     }

//     // Try executing the query using writeData
//     final result = await connection.writeData(query);
//     if (result == null) {
//       print('Error: Query execution failed.');
//     } else {
//       print('MSSQL Ledger updated/inserted successfully.');
//     }

//   } catch (e) {
//     print('Error updating ledger in MSSQL: $e');
//   }
// }







// Future<void> fetchDataAndSyncToSQLite() async {
//   try {
//     final query =
//         'SELECT Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state, Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location, OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate, SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount FROM LedgerNames';
//     final rawData = await MsSQLConnectionPlatform.instance.getData(query);

//     if (rawData is String) {
//       final decodedData = jsonDecode(rawData);
//       if (decodedData is List) {
//         final records = decodedData.map((row) => Map<String, dynamic>.from(row)).toList();

//         // Insert into SQLite
//         final db = await getDatabase(); // Implement this function to initialize SQLite database
//         for (var record in records) {
//           await db.insert(
//             'ledgernames',
//             record,
//             conflictAlgorithm: ConflictAlgorithm.replace, // Prevent duplication
//           );
//         }
//         print('Data synchronized to SQLite successfully.');
//       } else {
//         throw Exception('Unexpected JSON format for LedgerNames data: $decodedData');
//       }
//     } else {
//       throw Exception('Unexpected data format for LedgerNames: $rawData');
//     }
//   } catch (e) {
//     print('Error fetching and syncing data: $e');
//     rethrow;
//   }
// }


// }

// Future<List<Map<String, dynamic>>> fetchDataFromMSSQLAccTransations() async {
//   try {
//     final query = '''
//       SELECT DISTINCT TOP 499 Auto, atDate, atLedCode, atType, atEntryno, atDebitAmount, 
//              atCreditAmount, atNarration, atOpposite, atSalesEntryno, atSalesType, 
//              atLocation, atChequeNo, atProject, atBankEntry, atInvestor, atFyID, 
//              atFxDebit, atFxCredit 
//       FROM Account_Transactions
//       WHERE Auto IS NOT NULL -- Exclude rows with NULL Auto
//         AND atDebitAmount >= 0 -- Exclude invalid debit amounts
//         AND atCreditAmount >= 0 -- Exclude invalid credit amounts
//         -- Add any additional filters as needed
//       ORDER BY Auto ASC -- Ensure a consistent row order
//     ''';

//     // Fetch raw data from the database
//     final rawData = await MsSQLConnectionPlatform.instance.getData(query);

//     // Check and decode the data
//     if (rawData is String) {
//       final decodedData = jsonDecode(rawData);

//       if (decodedData is List) {
//         // Convert rows to a list of maps
//         final completeData = decodedData
//             .map((row) => Map<String, dynamic>.from(row))
//             .toList();

//         // Remove any duplicates programmatically (if required)
//         final uniqueData = completeData.toSet().toList();

//         print('Fetched ${uniqueData.length} unique rows from Account_Transactions.');
//         return uniqueData;
//       } else {
//         throw Exception(
//             'Unexpected JSON format for Account_Transactions data: $decodedData');
//       }
//     } else {
//       throw Exception('Unexpected data format for Account_Transactions: $rawData');
//     }
//   } catch (e) {
//     print('Error fetching data from Account_Transactions: $e');
//     rethrow;
//   }
// }




// Future<void> backupMSSQLToSQLite() async {
//   final dbHelper = LedgerTransactionsDatabaseHelper.instance;
//   await dbHelper.enableWALMode(); // Enable Write-Ahead Logging for performance

//   try {
//     final fetchedData = await fetchDataFromMSSQLAccTransations();

//     if (fetchedData.isEmpty) {
//       print('No data to backup. Exiting.');
//       return;
//     }

//     print('Total rows fetched: ${fetchedData.length}');

//     await dbHelper.insertData(fetchedData);

//     final sqliteRowCount = await dbHelper.getRowCount();
//     print('SQLite contains $sqliteRowCount rows after backup.');

//     if (sqliteRowCount != fetchedData.length) {
//       print('Warning: Mismatch in row count! Fetched: ${fetchedData.length}, Inserted: $sqliteRowCount');
//     } else {
//       print('Backup successful. All rows are backed up.');
//     }
//   } catch (e) {
//     print('Error during backup: $e');
//   }
// }

