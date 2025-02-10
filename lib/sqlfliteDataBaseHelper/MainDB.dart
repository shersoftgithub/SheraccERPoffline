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

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('ledgerTransactionsDB.db');
    return _database!;
  }

  Future<Database> _initDatabase(String dbName) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createDatabase(db);
      },
       onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 3) {
       await db.execute("ALTER TABLE Account_Transactions ADD COLUMN Caccount TEXT");
      }
  },
    );
  }

 Future<void> _createDatabase(Database db) async {
  try {
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

    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS Account_Transactions (
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
        atFxCredit TEXT,
        Caccount TEXT,
        atDiscount REAL,
        atNaration TEXT,
        atLedName TEXT
      );
    ''');

    print('Tables created successfully.');
  } catch (e) {
    print('Error creating tables: $e');
    rethrow;
  }
  }

Future<void> insertAccTrans(Map<String, dynamic> newTableData) async {
  final db = await database;

  try {
    // Fetch the last Auto value
    final List<Map<String, dynamic>> lastRecord = await db.rawQuery(
      "SELECT Auto FROM Account_Transactions ORDER BY CAST(Auto AS INTEGER) DESC LIMIT 1"
    );

    int newAuto = 1; // Default value if table is empty
    if (lastRecord.isNotEmpty && lastRecord.first['Auto'] != null) {
      newAuto = (int.tryParse(lastRecord.first['Auto'].toString()) ?? 0) + 1;
    }

    // Add the new Auto value to the transaction data
    newTableData['Auto'] = newAuto.toString();

    // Insert the new record
    await db.insert('Account_Transactions', newTableData, conflictAlgorithm: ConflictAlgorithm.replace);
    
    print('Transaction inserted successfully with Auto: $newAuto');

    // After inserting, update LedgerNames table
    await insertLedgerData({
      'Ledcode': newTableData['atLedCode'],
      'LedName': newTableData['atLedName'],
      'balance': newTableData['atDebitAmount'] - newTableData['atCreditAmount'],
    });

    // Finally, sync the new transaction with MSSQL
    await syncAccountTransactionsToMSSQL(newTableData);

  } catch (e) {
    print('Error inserting transaction: $e');
  }
}

Future<void> insertLedgerData(Map<String, dynamic> ledgerData) async {
  final db = await database;

  try {
    print('Inserting LedgerData: $ledgerData');

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

    // Check if the data exists
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


Future<void> insertData(List<Map<String, dynamic>> data) async {
  final db = await database; 

  int insertedCount = 0;

  for (final row in data) {
    // Check if the Auto already exists to avoid duplicates
    final existing = await db.query(
      'Account_Transactions',
      where: 'Auto = ?',
      whereArgs: [row['Auto']],
    );

    if (existing.isEmpty) {
      int result = await db.insert(
        'Account_Transactions',
        {
          'Auto': row['Auto'] ?? '',
          'atDate': row['atDate'] ?? '',
          'atLedCode': row['atLedCode'] ?? '',       
          'atType': row['atType'] ?? '',
          'atEntryno': row['atEntryno'] ?? '',
          'atDebitAmount': row['atDebitAmount'] ?? 0.0,
          'atCreditAmount': row['atCreditAmount'] ?? 0.0,
          'atNarration': row['atNarration'] ?? '',
          'atOpposite': row['atOpposite'] ?? '',
          'atSalesEntryno': row['atSalesEntryno'] ?? '',
          'atSalesType': row['atSalesType'] ?? '',
          'atLocation': row['atLocation'] ?? '',
          'atChequeNo': row['atChequeNo'] ?? '',
          'atProject': row['atProject'] ?? '',
          'atBankEntry': row['atBankEntry'] ?? '',
          'atInvestor': row['atInvestor'] ?? '',
          'atFyID': row['atFyID'] ?? '',
          'atFxDebit': row['atFxDebit'] ?? '',
          'atFxCredit': row['atFxCredit'] ?? '',
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, 
      );

      if (result != -1) {
        insertedCount++;
      }
    } else {
      print('Duplicate record found and ignored: ${row["Auto"]}');
    }
  }

  print('Total rows inserted: $insertedCount');

  // Fetch and compare with MSSQL count
  final List<Map<String, dynamic>> storedData = await db.query('Account_Transactions');
  print('Total stored rows in SQLite: ${storedData.length}');
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
  required DateTime fromDate, 
  required DateTime toDate, 
  String? ledgerName,
}) async {
  Database db = await instance.database;

  List<String> whereClauses = ['atType = ?'];
  List<dynamic> whereArgs = ['RECEIPT'];

  // Format dates properly
  String fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
  String toDateString = DateFormat('yyyy-MM-dd ').format(toDate);

  whereClauses.add("datetime(atDate) BETWEEN datetime(?) AND datetime(?)");
  whereArgs.addAll([fromDateString, toDateString]);

  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('atLedName LIKE ?');
    whereArgs.add('%$ledgerName%');
  }

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

  List<String> whereClauses = ['atType = ?'];
  List<dynamic> whereArgs = ['PAYMENT'];

  // Format dates properly
  String fromDateString = DateFormat('yyyy-MM-dd').format(fromDate!);
  String toDateString = DateFormat('yyyy-MM-dd ').format(toDate!);

  whereClauses.add("datetime(atDate) BETWEEN datetime(?) AND datetime(?)");
  whereArgs.addAll([fromDateString, toDateString]);

  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('atLedName LIKE ?');
    whereArgs.add('%$ledgerName%');
  }

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
    return (result.first['OpeningBalance'] as num).toDouble(); 
  } else {
    return 0.0;
  }
}
Future<double> getDebitAmountForLedger(String ledgerName) async {
  final db = await database;  

  var result = await db.rawQuery(
    'SELECT SUM(atDebitAmount) FROM Account_Transactions WHERE atLedName = ?',
    [ledgerName],
  );

  if (result.isNotEmpty && result.first['SUM(atDebitAmount)'] != null) {
    return result.first['SUM(atDebitAmount)'] as double? ?? 0.0;
  } else {
    return 0.0;
  }
}







  ////////////////////////ledger names table functions ///////////////////
  

  Future<List<Map<String, dynamic>>> getLedgersWithTransactions() async {
    final db = await database;  
    final result = await db.rawQuery('SELECT * FROM LedgerWithTransactions');
    return result;
  }
  
  Future<List<String>> getAllNames() async {
    final db = await instance.database;
    final result = await db.query('LedgerNames', columns: ['LedName']);
    return result.map((item) => item['LedName'] as String).toList();
  }

  Future<Map<String, dynamic>?> getLedgerDetailsByName(String ledgerName) async {
    final db = await instance.database;
    final result = await db.query(
      'LedgerNames',
      columns: ['Ledcode AS LedId', 'Mobile','OpeningBalance','add1','add2','add3','add4'],
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
  Future<List<Map<String, dynamic>>> getFilteredAccountTransactions(String atType) async {
    final db = await database;
    return await db.query(
      'Account_Transactions',
      where: 'atType = ?',
      whereArgs: [atType],
    );
  }

  Future<List<Map<String, dynamic>>> getAccountTransactionsByLedgerCode(String ledgerCode) async {
    final db = await database;
    return await db.query(
      'Account_Transactions',
      where: 'atLedCode = ?',
      whereArgs: [ledgerCode],
    );
  }

  Future<void> updateLedgerBalance(String ledgerCode, double newBalance) async {
    final db = await database;
    await db.update(
      'LedgerNames',
      {'OpeningBalance': newBalance},
      where: 'Ledcode = ?',
      whereArgs: [ledgerCode],
    );
  }

  Future<void> updatePaymentBalance(String ledgerCode, double total, double amt, double newBalance) async {
    final db = await database;
    await db.update(
      'Account_Transactions',
      {'atDebitAmount': newBalance, 'atCreditAmount': total, 'atDebitAmount': amt},
      where: 'atLedCode = ?',
      whereArgs: [ledgerCode],
    );
  }

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
      final openingBalance = (totalCredits - totalDebits).abs();

      final ledgerExists = await db.query(
        'LedgerNames',
        columns: ['Ledcode'],
        where: 'Ledcode = ?',
        whereArgs: [ledgerCode],
      );

      if (ledgerExists.isNotEmpty) {
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
Future<void> insertDataIntoSQLite(List<Map<String, dynamic>> data) async {
  final database = await openDatabase('ledgerTransactionsDB.db');

  for (final row in data) {
    await database.insert(
      'Account_Transactions',
      {
        'Auto': row['Auto']?.toString() ?? '',
    'atDate': row['atDate']?.toString() ?? '',
    'atLedCode': row['atLedCode']?.toString() ?? '', 
      'atType': row['atType']?.toString() ?? '',
    'atEntryno': row['atEntryno']?.toString() ?? '', 
    'atDebitAmount': row['atDebitAmount'] != null ? row['atDebitAmount'] : 0.0, 
    'atCreditAmount': row['atCreditAmount'] != null ? row['atCreditAmount'] : 0.0, 
     'atNarration': row['atNarration']?.toString() ?? '',
    'atOpposite': row['atOpposite']?.toString() ?? '',     
    'atSalesEntryno': row['atSalesEntryno']?.toString() ?? '',
    'atSalesType': row['atSalesType']?.toString() ?? 'Default SalesType',
    'atLocation': row['atLocation']?.toString() ?? '',
    'atChequeNo': row['atChequeNo']?.toString() ?? '',
    'atProject': row['atProject']?.toString() ?? '',
    'atBankEntry': row['atBankEntry']?.toString() ?? '',
    'atInvestor': row['atInvestor']?.toString() ?? '',
    'atFyID': row['atFyID']?.toString() ?? '',
    'atFxDebit': row['atFxDebit']?.toString() ?? '',
    'atFxCredit': row['atFxCredit']?.toString() ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  print('Data inserted successfully into SQLite.');
}

Future<List<Map<String, dynamic>>> fetchSQLiteData() async {
  final db = await getDatabase(); 
  return await db.query('LedgerNames');
}
Future<Database> getDatabase() async {
  return database;
}
Future<void> fetchDataFromMSSQLCompany() async {
  try {
    final query =
        'SELECT Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state, Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location, OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate, SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount FROM LedgerNames';
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);
      if (decodedData is List) {
        final records = decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        final db = await getDatabase(); 
        for (var record in records) {
          await db.insert(
            'LedgerNames',
            record,
            conflictAlgorithm: ConflictAlgorithm.replace, 
          );
        }
        print('Data synchronized to SQLite successfully.');
      } else {
        throw Exception('Unexpected JSON format for LedgerNames data: $decodedData');
      }
    } else {
      throw Exception('Unexpected data format for LedgerNames: $rawData');
    }
  } catch (e) {
    print('Error fetching and syncing data: $e');
    rethrow;
  }
}

Future<void> fetchAndInsertIntoSQLite() async {
  final dbHelper = LedgerTransactionsDatabaseHelper.instance;

  try {
    final List<Map<String, dynamic>> fetchedData = await fetchDataFromMSSQLAccTransations();

    if (fetchedData.isEmpty) {
      print('No data fetched from MSSQL.');
      return;
    }
    await dbHelper.insertOrUpdateLedgerDataInSQLite(fetchedData);

    print('Fetched and inserted data from MSSQL to SQLite.');
  } catch (e) {
    print('Error in fetchAndInsertIntoSQLite: $e');
  }
}

Future<void> insertOrUpdateLedgerDataInSQLite(List<Map<String, dynamic>> ledgerDataList) async {
  final db = await database;

  for (var ledgerData in ledgerDataList) {
    final result = await db.insert(
      'LedgerNames', 
      ledgerData,
      conflictAlgorithm: ConflictAlgorithm.replace, 
    );

    if (result > 0) {
      print('Ledger data inserted or updated successfully.');
    } else {
      print('Failed to insert/update ledger data.');
    }
  }
}


Future<void> syncLedgerNamesToMSSQL() async {
  final db = await database;
  final modifiedData = await db.query('LedgerNames'); 
  final modifiedData2 = await db.query('Account_Transactions');
  // for (var data in modifiedData) {
  
  //   final ledgerCode = data['Ledcode'];
  //       await updateMSSQLLedger(data);
  // }
  for (var data in modifiedData2) {
  
    final atledgerCode = data['Auto'];
        await syncAccountTransactionsToMSSQL(data);
  }
}

Future<void> updateMSSQLLedger(Map<String, dynamic> ledgerData) async {
  try {
    if (ledgerData['Ledcode'] == null || ledgerData['Ledcode'].toString().trim().isEmpty) {
      throw Exception('Ledcode is required and cannot be null or empty');
    }
    if (ledgerData['LedName'] == null || ledgerData['LedName'].toString().trim().isEmpty) {
      throw Exception('LedName is required and cannot be null or empty');
    }
    String escapeString(String? value) {
      return value != null ? "'${value.replaceAll("'", "''")}'" : "NULL";
    }

    final ledcode = ledgerData['Ledcode'];
    final ledName = escapeString(ledgerData['LedName']);
    final lhId = ledgerData['lh_id'] ?? 0;
    final add1 = escapeString(ledgerData['add1']);
    final add2 = escapeString(ledgerData['add2']);
    final add3 = escapeString(ledgerData['add3']);
    final add4 = escapeString(ledgerData['add4']);
    final city = escapeString(ledgerData['city']);
    final route = escapeString(ledgerData['route']);
    final state = escapeString(ledgerData['state']);
    final mobile = escapeString(ledgerData['Mobile']);
    final pan = escapeString(ledgerData['pan']);
    final email = escapeString(ledgerData['Email']);
    final gstno = escapeString(ledgerData['gstno']);
    final cAmount = ledgerData['CAmount'] ?? 0.0;
    final active = (ledgerData['Active'] == true) ? 1 : 0; 
    final salesMan = escapeString(ledgerData['SalesMan']);
    final location = escapeString(ledgerData['Location']);
    final orderDate = escapeString(ledgerData['OrderDate']);
    final deliveryDate = escapeString(ledgerData['DeliveryDate']);
    final cPerson = escapeString(ledgerData['CPerson']);
    final costCenter = escapeString(ledgerData['CostCenter']);
    final franchisee = escapeString(ledgerData['Franchisee']);
    final salesRate = ledgerData['SalesRate'] ?? 0.0;
    final subGroup = escapeString(ledgerData['SubGroup']);
    final secondName = escapeString(ledgerData['SecondName']);
    final userName = escapeString(ledgerData['UserName']);
    final password = escapeString(ledgerData['Password']);
    final customerType = escapeString(ledgerData['CustomerType']);
    final otp = escapeString(ledgerData['OTP']);
    final maxDiscount = ledgerData['maxDiscount'] ?? 0.0;

   final query = '''
  SET IDENTITY_INSERT LedgerNames ON;

  MERGE INTO LedgerNames AS target
  USING (VALUES (
    '$ledcode', $ledName, $lhId, $add1, $add2, $add3, $add4, $city, $route, $state,
    $mobile, $pan, $email, $gstno, $cAmount, $active, $salesMan, $location,
    $orderDate, $deliveryDate, $cPerson, $costCenter, $franchisee, $salesRate,
    $subGroup, $secondName, $userName, $password, $customerType, $otp, $maxDiscount
  )) 
  AS source (
    Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state,
    Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location,
    OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate,
    SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount
  )
  ON target.Ledcode = source.Ledcode
  WHEN MATCHED THEN
    UPDATE SET
      LedName = source.LedName, lh_id = source.lh_id, add1 = source.add1,
      add2 = source.add2, add3 = source.add3, add4 = source.add4, city = source.city,
      route = source.route, state = source.state, Mobile = source.Mobile, pan = source.pan,
      Email = source.Email, gstno = source.gstno, CAmount = source.CAmount,
      Active = source.Active, SalesMan = source.SalesMan, Location = source.Location,
      OrderDate = source.OrderDate, DeliveryDate = source.DeliveryDate,
      CPerson = source.CPerson, CostCenter = source.CostCenter, Franchisee = source.Franchisee,
      SalesRate = source.SalesRate, SubGroup = source.SubGroup, SecondName = source.SecondName,
      UserName = source.UserName, Password = source.Password, CustomerType = source.CustomerType,
      OTP = source.OTP, maxDiscount = source.maxDiscount
  WHEN NOT MATCHED THEN
    INSERT (
      Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state,
      Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location,
      OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate,
      SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount
    )
    VALUES (
      source.Ledcode, source.LedName, source.lh_id, source.add1, source.add2, source.add3,
      source.add4, source.city, source.route, source.state, source.Mobile, source.pan,
      source.Email, source.gstno, source.CAmount, source.Active, source.SalesMan, source.Location,
      source.OrderDate, source.DeliveryDate, source.CPerson, source.CostCenter, source.Franchisee,
      source.SalesRate, source.SubGroup, source.SecondName, source.UserName, source.Password,
      source.CustomerType, source.OTP, source.maxDiscount
    );

  SET IDENTITY_INSERT LedgerNames OFF;
''';

    print('Executing SQL query: $query');
    final result = await MsSQLConnectionPlatform.instance!.writeData(query);
    if (result != null) {
      print('Query executed successfully: $result');
    } else {
      throw Exception('Query execution failed with null result');
    }
  } catch (e) {
    print('Error executing query: $e');
  }
}

Future<void> syncAccountTransactionsToMSSQL(Map<String, dynamic> transaction) async {
  try {
    // Validate 'Auto' value
    var auto = transaction['Auto'];
    if (auto == null || auto.toString().trim().isEmpty) {
      throw Exception('Auto is required for updates.');
    }

    final autoValue = int.tryParse(auto.toString());
    if (autoValue == null) {
      throw Exception('Invalid Auto value: $auto. It must be numeric.');
    }

    // Function to escape strings for SQL
    String escapeString(String? value) {
      return value != null && value.isNotEmpty ? "'${value.replaceAll("'", "''")}'" : "NULL";
    }

    // Function to parse numbers safely
    num? parseNumber(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) return null;
      return num.tryParse(value.toString());
    }

    // Prepare fields
    final atDate = escapeString(transaction['atDate']);
    final atLedCode = escapeString(transaction['atLedCode']);
    final atType = escapeString(transaction['atType']);
    final atEntryno = transaction['atEntryno'] != null ? "'${transaction['atEntryno']}'" : "NULL";
    final atDebitAmount = parseNumber(transaction['atDebitAmount']) ?? 0;
    final atCreditAmount = parseNumber(transaction['atCreditAmount']) ?? 0;
    final atNarration = escapeString(transaction['atNarration']);
    final atOpposite = escapeString(transaction['atOpposite']);
    final atSalesEntryno = escapeString(transaction['atSalesEntryno']);
    final atSalesType = escapeString(transaction['atSalesType']);
    final atLocation = escapeString(transaction['atLocation']);
    final atChequeNo = escapeString(transaction['atChequeNo']);
    final atProject = escapeString(transaction['atProject']);
    final atBankEntry = escapeString(transaction['atBankEntry']);
    final atInvestor = escapeString(transaction['atInvestor']);
    final atFyID = escapeString(transaction['atFyID']);
    final atFxDebit = parseNumber(transaction['atFxDebit']) ?? 0;
    final atFxCredit = parseNumber(transaction['atFxCredit']) ?? 0;

    // SQL Query
    final query = '''
    SET IDENTITY_INSERT Account_Transactions ON;

    MERGE INTO Account_Transactions AS target
    USING (SELECT 
      $autoValue AS Auto, $atDate AS atDate, $atLedCode AS atLedCode, $atType AS atType,
      $atEntryno AS atEntryno, $atDebitAmount AS atDebitAmount, $atCreditAmount AS atCreditAmount,
      $atNarration AS atNarration, $atOpposite AS atOpposite, $atSalesEntryno AS atSalesEntryno,
      $atSalesType AS atSalesType, $atLocation AS atLocation, $atChequeNo AS atChequeNo,
      $atProject AS atProject, $atBankEntry AS atBankEntry, $atInvestor AS atInvestor,
      $atFyID AS atFyID, $atFxDebit AS atFxDebit, $atFxCredit AS atFxCredit
    ) AS source
    ON target.Auto = source.Auto
    WHEN MATCHED THEN
      UPDATE SET 
        atDate = source.atDate, atLedCode = source.atLedCode, atType = source.atType,
        atEntryno = source.atEntryno, atDebitAmount = source.atDebitAmount, 
        atCreditAmount = source.atCreditAmount, atNarration = source.atNarration, 
        atOpposite = source.atOpposite, atSalesEntryno = source.atSalesEntryno, 
        atSalesType = source.atSalesType, atLocation = source.atLocation, 
        atChequeNo = source.atChequeNo, atProject = source.atProject, 
        atBankEntry = source.atBankEntry, atInvestor = source.atInvestor, 
        atFyID = source.atFyID, atFxDebit = source.atFxDebit, atFxCredit = source.atFxCredit
    WHEN NOT MATCHED THEN
      INSERT (Auto, atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
              atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
              atChequeNo, atProject, atBankEntry, atInvestor, atFyID, 
              atFxDebit, atFxCredit)
      VALUES ($autoValue, $atDate, $atLedCode, $atType, $atEntryno, 
              $atDebitAmount, $atCreditAmount, $atNarration, $atOpposite, 
              $atSalesEntryno, $atSalesType, $atLocation, $atChequeNo, 
              $atProject, $atBankEntry, $atInvestor, $atFyID, 
              $atFxDebit, $atFxCredit);

    SET IDENTITY_INSERT Account_Transactions OFF;
    ''';

    // Debugging output
    print('Executing SQL query: $query');

    // Ensure MSSQL connection is available
    if (MsSQLConnectionPlatform.instance == null) {
      throw Exception('MsSQLConnectionPlatform is not initialized');
    }

    // Execute the query
    final result = await MsSQLConnectionPlatform.instance!.writeData(query);

    // Log success
    if (result != null) {
      print('Query executed successfully: $result');
    } else {
      throw Exception('Query execution failed with null result');
    }
  } catch (e) {
    print('Error executing query: $e');
  }
}




Future<void> fetchDataAndSyncToSQLite() async {
  try {
    final query =
        'SELECT Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state, Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location, OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate, SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount FROM LedgerNames';
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);
      if (decodedData is List) {
        final records = decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        final db = await getDatabase(); 
        for (var record in records) {
          await db.insert(
            'ledgernames',
            record,
            conflictAlgorithm: ConflictAlgorithm.replace, 
          );
        }
        print('Data synchronized to SQLite successfully.');
      } else {
        throw Exception('Unexpected JSON format for LedgerNames data: $decodedData');
      }
    } else {
      throw Exception('Unexpected data format for LedgerNames: $rawData');
    }
  } catch (e) {
    print('Error fetching and syncing data: $e');
    rethrow;
  }
}




Future<List<Map<String, dynamic>>> fetchLedgerDataFromSQLite() async {
  final db = await LedgerTransactionsDatabaseHelper.instance.database;
  return await db.query('LedgerNames');
}
String formatValue(dynamic value) {
  if (value == null) {
    return 'NULL';
  } else if (value is String) {
    return "'${value.replaceAll("'", "''")}'"; 
  } else {
    return value.toString();
  }
}



}

Future<List<Map<String, dynamic>>> fetchDataFromMSSQLAccTransations() async {
  try {
    final query = '''
      SELECT DISTINCT Auto, atDate, atLedCode, atType, atEntryno, atDebitAmount, 
             atCreditAmount, atNarration, atOpposite, atSalesEntryno, atSalesType, 
             atLocation, atChequeNo, atProject, atBankEntry, atInvestor, atFyID, 
             atFxDebit, atFxCredit 
      FROM Account_Transactions
      WHERE Auto IS NOT NULL 
      ORDER BY Auto ASC
    ''';

    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);

      if (decodedData is List) {
        List<String> expectedColumns = [
          "Auto", "atDate", "atLedCode", "atType", "atEntryno", "atDebitAmount",
          "atCreditAmount", "atNarration", "atOpposite", "atSalesEntryno",
          "atSalesType", "atLocation", "atChequeNo", "atProject", "atBankEntry",
          "atInvestor", "atFyID", "atFxDebit", "atFxCredit"
        ];

        List<Map<String, dynamic>> validData = [];

        for (var row in decodedData) {
          if (row is Map<String, dynamic>) {
            bool isValid = expectedColumns.every((col) => row.containsKey(col));

            if (isValid) {
              String formattedDate = row["atDate"].toString();

              try {
                DateTime parsedDate = DateTime.parse(formattedDate);
                formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
              } catch (e) {
                print('Invalid date format for Auto ${row["Auto"]}: $formattedDate');
                formattedDate = ""; 
              }

              row["atDate"] = formattedDate;
              validData.add(Map<String, dynamic>.from(row));
            } else {
              print('Invalid row detected and ignored: $row');
            }
          }
        }

        // Remove duplicates based on "Auto"
        Map<String, Map<String, dynamic>> uniqueDataMap = {
          for (var item in validData) item["Auto"].toString(): item
        };
        final uniqueData = uniqueDataMap.values.toList();

        print('Fetched ${uniqueData.length} unique rows from Account_Transactions.');
        return uniqueData;
      } else {
        throw Exception('Unexpected JSON format in MSSQL data: $decodedData');
      }
    } else {
      throw Exception('Unexpected data format received from MSSQL: $rawData');
    }
  } catch (e) {
    print('Error fetching data from Account_Transactions: $e');
    rethrow;
  }
}







Future<void> backupMSSQLToSQLite() async {
  final dbHelper = LedgerTransactionsDatabaseHelper.instance;
  await dbHelper.enableWALMode(); 
  try {
    final fetchedData = await fetchDataFromMSSQLAccTransations();

    if (fetchedData.isEmpty) {
      print('No data to backup. Exiting.');
      return;
    }

    print('Total rows fetched: ${fetchedData.length}');

    await dbHelper.insertData(fetchedData);

    final sqliteRowCount = await dbHelper.getRowCount();
    print('SQLite contains $sqliteRowCount rows after backup.');

    if (sqliteRowCount != fetchedData.length) {
      print('Warning: Mismatch in row count! Fetched: ${fetchedData.length}, Inserted: $sqliteRowCount');
    } else {
      print('Backup successful. All rows are backed up.');
    }
  } catch (e) {
    print('Error during backup: $e');
  }
}

