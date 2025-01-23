import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LedgerTransactionsDatabaseHelper {
  static Database? _database;
  static final LedgerTransactionsDatabaseHelper _instance = LedgerTransactionsDatabaseHelper._internal();

  LedgerTransactionsDatabaseHelper._internal();
  static LedgerTransactionsDatabaseHelper get instance => _instance;

  // Database for Ledger and Account Transactions
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('ledgerTransactionsDB.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase(String dbName) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    return openDatabase(
      path,
      version: 7,
      onCreate: (db, version) async {
        await _createDatabase(db);
      },
       onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 7) {
        await db.execute("ALTER TABLE Account_Transactions ADD COLUMN atLedName TEXT DEFAULT ''");
        print('Column atLedName added to Account_Transactions table.');
         //await db.execute("ALTER TABLE Account_Transactions ADD COLUMN  id INTEGER PRIMARY KEY AUTOINCREMENT ''");
      }
  },
    );
  }

  // Create tables
 Future<void> _createDatabase(Database db) async {
  try {
    // Create LedgerNames table
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS LedgerNames (
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
        OpeningBalance REAL,
        under TEXT,
        Debit REAL DEFAULT 0,
        date TEXT,
        balance REAL DEFAULT 0
      );
    ''');

    // Create Account_Transactions table
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS Account_Transactions (
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

    print('Tables created successfully.');
  } catch (e) {
    print('Error creating tables: $e');
    rethrow;
  }
  }

// Insert data into LedgerNames table with debugging
Future<void> insertLedgerData(Map<String, dynamic> ledgerData) async {
  final db = await database;

  try {
    // Debugging: Print the data to be inserted
    print('Inserting LedgerData: $ledgerData');

    // Insert the data into the LedgerNames table
    final result = await db.insert(
      'LedgerNames',
      ledgerData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('Insertion successful. Row inserted with ID: $result');
    } else {
      print('Insertion failed. No row inserted.');
    }

    final checkResult = await db.query(
      'LedgerNames',
      where: 'Ledcode = ?',
      whereArgs: [ledgerData['Ledcode']],
    );

    if (checkResult.isNotEmpty) {
      print('Data successfully inserted: ${checkResult.first}');
    } else {
      print('Data insertion was unsuccessful. Unable to find the inserted record.');
    }
  } catch (e) {
    print('Error inserting ledger data: $e');
  }
}

////////////////////////////////Account traancsaction functions ///////////////////////////////

  // Insert data into Account_Transactions table
 Future<void> insertAccTrans(Map<String, dynamic> newTableData) async {
    final db = await database;
    await db.insert('Account_Transactions', newTableData, conflictAlgorithm: ConflictAlgorithm.replace);
  }
Future<void> insertData(List<Map<String, dynamic>> data) async {
  final db = await database;

  for (var row in data) {
    try {
      await db.insert(
        'Account_Transactions',
        row,
        conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore duplicate entries
      );
    } catch (e) {
      print('Insert error for row with atLedCode ${row['atLedCode']}: $e');
    }
  }

  print('All rows inserted successfully.');
}
Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('Account_Transactions');
  }
Future<int> getRowCount() async {
    final db = await database;
    try {
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Account_Transactions'));
      print('SQLite Row Count: $count');
      return count ?? 0;
    } catch (e) {
      print('Error fetching row count: $e');
      return 0;
    }
  }
  Future<List<Map<String, dynamic>>> getFilteredAccTrans(String atType) async {
    final db = await database; 
    return await db.query(
      'Account_Transactions', 
      where: 'atType = ?', 
      whereArgs: [atType],
    );
  }

Future<List<Map<String, dynamic>>> queryFilteredRows({
  DateTime? fromDate, 
  DateTime? toDate, 
  String? ledgerName,
}) async {
  Database db = await instance.database;

  List<String> whereClauses = [];
  List<dynamic> whereArgs = [];

  // Always filter by atType = 'PAYMENT'
  whereClauses.add('atType = ?');
  whereArgs.add('RECIEPT');

  // Add ledgerName filter if provided
  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('atLedName LIKE ?');
    whereArgs.add('%$ledgerName%');
  }

  // Add fromDate filter if provided
  if (fromDate != null) {
    whereClauses.add('atDate >= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
  }

  // Add toDate filter if provided
  if (toDate != null) {
    whereClauses.add('atDate <= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
  }

  // Combine all where clauses
  String whereClause = whereClauses.join(' AND ');

  try {
    return await db.query(
      'Account_Transactions',
      where: whereClause,
      whereArgs: whereArgs,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}
Future<List<Map<String, dynamic>>> queryFilteredRowsPay({
  DateTime? fromDate, 
  DateTime? toDate, 
  String? ledgerName,
}) async {
  Database db = await instance.database;

  List<String> whereClauses = [];
  List<dynamic> whereArgs = [];

  // Always filter by atType = 'PAYMENT'
  whereClauses.add('atType = ?');
  whereArgs.add('PAYMENT');

  // Add ledgerName filter if provided
  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('atLedName LIKE ?');
    whereArgs.add('%$ledgerName%');
  }

  // Add fromDate filter if provided
  if (fromDate != null) {
    whereClauses.add('atDate >= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
  }

  // Add toDate filter if provided
  if (toDate != null) {
    whereClauses.add('atDate <= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
  }

  // Combine all where clauses
  String whereClause = whereClauses.join(' AND ');

  try {
    return await db.query(
      'Account_Transactions',
      where: whereClause,
      whereArgs: whereArgs,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}


Future<void> enableWALMode() async {
    final db = await database;
    try {
      await db.execute('PRAGMA journal_mode=WAL;');
      print('WAL mode enabled.');
    } catch (e) {
      print('Error enabling WAL mode: $e');
    }
  }

Future<double> getOpeningBalanceForLedger(String ledgerName) async {
  final db = await database;
  var result = await db.rawQuery(''' 
    SELECT SUM(atDebitAmount) as OpeningBalance 
    FROM Account_Transactions 
    WHERE atLedName = ? 
  ''', [ledgerName]);

  if (result.isNotEmpty && result.first['OpeningBalance'] != null) {
    return (result.first['OpeningBalance'] as num).toDouble(); // Cast to double
  } else {
    return 0.0;
  }
}
Future<double> getDebitAmountForLedger(String ledgerName) async {
  final db = await database;  // Assuming you have a database connection established

  // Query to get the sum of all debit amounts for the given ledger name
  var result = await db.rawQuery(
    'SELECT SUM(atDebitAmount) FROM Account_Transactions WHERE atLedName = ?',
    [ledgerName],
  );

  // If the result is not empty and contains a valid value
  if (result.isNotEmpty && result.first['SUM(atDebitAmount)'] != null) {
    // Safely return the sum as a double (ensuring null safety)
    return result.first['SUM(atDebitAmount)'] as double? ?? 0.0;
  } else {
    // If the result is empty or null, return 0.0
    return 0.0;
  }
}







  ////////////////////////ledger names table functions ///////////////////
  

  Future<List<Map<String, dynamic>>> getLedgersWithTransactions() async {
    final db = await database;  // Use the primary database or backup as needed
    final result = await db.rawQuery('SELECT * FROM LedgerWithTransactions');
    return result;
  }
  
  // Get all Ledger Names
  Future<List<String>> getAllNames() async {
    final db = await instance.database;
    final result = await db.query('LedgerNames', columns: ['LedName']);
    return result.map((item) => item['LedName'] as String).toList();
  }

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

Future<List<Map<String, dynamic>>> queryFilteredRowsledger({
  DateTime? fromDate, 
  DateTime? toDate, 
  String? ledgerName,
  
}) async {
  Database db = await instance.database;

  List<String> whereClauses = [];
  List<dynamic> whereArgs = [];

  // Build the WHERE clause based on the provided filters
  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('LedName LIKE ?');
    whereArgs.add('%$ledgerName%');
  }


  if (fromDate != null) {
    whereClauses.add('date >= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
  }

  if (toDate != null) {
    whereClauses.add('date <= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
  }



  String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

  try {
    return await db.query(
      'LedgerNames',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
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
  // Get filtered account transactions by type
  Future<List<Map<String, dynamic>>> getFilteredAccountTransactions(String atType) async {
    final db = await database;
    return await db.query(
      'Account_Transactions',
      where: 'atType = ?',
      whereArgs: [atType],
    );
  }

  // Get account transactions by ledger code
  Future<List<Map<String, dynamic>>> getAccountTransactionsByLedgerCode(String ledgerCode) async {
    final db = await database;
    return await db.query(
      'Account_Transactions',
      where: 'atLedCode = ?',
      whereArgs: [ledgerCode],
    );
  }

  // Update ledger balance
  Future<void> updateLedgerBalance(String ledgerCode, double newBalance) async {
    final db = await database;
    await db.update(
      'LedgerNames',
      {'OpeningBalance': newBalance},
      where: 'Ledcode = ?',
      whereArgs: [ledgerCode],
    );
  }

  // Update account transaction payment balance
  Future<void> updatePaymentBalance(String ledgerCode, double total, double amt, double newBalance) async {
    final db = await database;
    await db.update(
      'Account_Transactions',
      {'atDebitAmount': newBalance, 'atCreditAmount': total, 'atDebitAmount': amt},
      where: 'atLedCode = ?',
      whereArgs: [ledgerCode],
    );
  }

  // Query filtered rows from LedgerNames
  Future<List<Map<String, dynamic>>> queryFilteredLedgerRows({
    DateTime? fromDate,
    DateTime? toDate,
    String? ledgerName,
  }) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (ledgerName != null && ledgerName.isNotEmpty) {
      whereClauses.add('LedName LIKE ?');
      whereArgs.add('%$ledgerName%');
    }

    if (fromDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
    }

    if (toDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
    }

    String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

    try {
      return await db.query(
        'LedgerNames',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );
    } catch (e) {
      print("Error fetching filtered data: $e");
      rethrow;
    }
  }

  // Insert or update ledger data into LedgerNames table
  Future<void> insertOrUpdateLedgerData(Map<String, dynamic> ledgerData) async {
    final db = await database;
    await db.insert(
      'LedgerNames',
      ledgerData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
   Future<bool> _doesColumnExist(Database db, String tableName, String columnName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }

  Future<void> updateOpeningBalances() async {
  final db = await database;

  try {
    // Fetch unique ledger codes from Account_Transactions, ignoring NULL or blank values
    final ledgerCodes = await db.rawQuery(
      '''
      SELECT DISTINCT atLedCode 
      FROM Account_Transactions 
      WHERE atLedCode IS NOT NULL AND atLedCode != ""
      '''
    );

    if (ledgerCodes.isEmpty) {
      print('No valid ledger codes found in Account_Transactions table.');
      return;
    }

    for (var ledger in ledgerCodes) {
      final ledgerCode = ledger['atLedCode'];

      // Calculate the opening balance for this ledger
      final result = await db.rawQuery(
        '''
        SELECT 
          COALESCE(SUM(atCreditAmount), 0) AS totalCredits,
          COALESCE(SUM(atDebitAmount), 0) AS totalDebits
        FROM Account_Transactions
        WHERE atLedCode = ?
        ''',
        [ledgerCode],
      );

      final totalCredits = (result.first['totalCredits'] as num).toDouble();
      final totalDebits = (result.first['totalDebits'] as num).toDouble();
      final openingBalance = totalCredits - totalDebits;

      // Check if the ledger code exists in LedgerNames
      final ledgerExists = await db.query(
        'LedgerNames',
        columns: ['Ledcode'],
        where: 'Ledcode = ?',
        whereArgs: [ledgerCode],
      );

      if (ledgerExists.isNotEmpty) {
        // Update the opening balance in LedgerNames
        await db.update(
          'LedgerNames',
          {'OpeningBalance': openingBalance},
          where: 'Ledcode = ?',
          whereArgs: [ledgerCode],
        );

        print('Updated ledger $ledgerCode with opening balance: $openingBalance');
      } else {
        print('Ledger $ledgerCode does not exist in LedgerNames table.');
      }
    }

    print('Opening balances updated successfully.');
  } catch (e) {
    print('Error updating opening balances: $e');
  }
}

}
Future<List<Map<String, dynamic>>> fetchDataFromMSSQLAccTransations() async {
  try {
    final query = '''
      SELECT atLedCode, atDate, atType, atEntryno, atDebitAmount, 
             atCreditAmount, atOpposite, atSalesType 
      FROM Account_Transactions
    ''';

    // Fetch data using MsSQLConnectionPlatform
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);

      if (decodedData is List) {
        final completeData = decodedData.map((row) {
          // Ensure that null values are replaced with default values
          return {
            'atLedCode': row['atLedCode'] ?? '',
            'atDate': row['atDate'] ?? '',
            'atType': row['atType'] ?? '',
            'atEntryno': row['atEntryno'] ?? '',
            'atDebitAmount': row['atDebitAmount'] ?? 0.0,
            'atCreditAmount': row['atCreditAmount'] ?? 0.0,
            'atOpposite': row['atOpposite'] ?? '',
            'atSalesType': row['atSalesType'] ?? '',
          };
        }).toList();

        // Debug log for validation
        if (completeData.isNotEmpty) {
          print('First Row: ${completeData.first}');
          print('Total Rows Fetched: ${completeData.length}');
        } else {
          print('No rows fetched from MSSQL table.');
        }

        return completeData;
      } else {
        throw Exception('Unexpected JSON format received: $decodedData');
      }
    } else {
      throw Exception('Invalid data format received: $rawData');
    }
  } catch (e) {
    print('Error fetching data from MSSQL: $e');
    rethrow;
  }
}


Future<void> backupMSSQLToSQLite() async {
  final dbHelper = LedgerTransactionsDatabaseHelper.instance;
  await dbHelper.enableWALMode();

  try {
    final completeData = await fetchDataFromMSSQLAccTransations();

    if (completeData.isEmpty) {
      print('No data to backup. Exiting.');
      return;
    }

    print('Total data to insert: ${completeData.length}');
    await dbHelper.insertData(completeData);

    final sqliteRowCount = await dbHelper.getRowCount();
    print('SQLite contains $sqliteRowCount rows after backup.');

    if (sqliteRowCount != completeData.length) {
      print('Mismatch in row count! Fetched: ${completeData.length}, Inserted: $sqliteRowCount');
    } else {
      print('Backup successful. All rows are backed up.');
    }
  } catch (e) {
    print('Error during backup: $e');
  }
}