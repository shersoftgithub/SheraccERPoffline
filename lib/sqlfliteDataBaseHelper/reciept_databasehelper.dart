import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RV_DatabaseHelper {
  static const _databaseName = "RV_database.db";
  static const _databaseVersion = 2;

  // Singleton pattern
  RV_DatabaseHelper._privateConstructor();
  static final RV_DatabaseHelper instance = RV_DatabaseHelper._privateConstructor();

  // Database instance
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create tables
  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate,onUpgrade: _onUpgrade);
  }

  // Create tables in the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS RV_Particulars (
        auto TEXT PRIMARY KEY,
        EntryNo TEXT,
        Name TEXT,
        Amount REAL,
        Discount REAL,
        Total REAL,
        Narration TEXT,
        ddate TEXT,
        CashAccount TEXT,
        FyID TEXT,
        FrmID TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS RV_Information (
        RealEntryNo INTEGER PRIMARY KEY AUTOINCREMENT,
        DDATE TEXT,
        AMOUNT TEXT,
        Discount REAL,
        Total REAL,
        DEBITACCOUNT TEXT,
        takeuser TEXT,
        Location INTEGER,
        Project INTEGER,
        SalesMan INTEGER,
        MonthDate TEXT,
        app INTEGER,
        Transfer_Status INTEGER,
        FyID INTEGER,
        EntryNo INTEGER,
        FrmID INTEGER,
        pviCurrency INTEGER,
        pviCurrencyValue INTEGER,
        pdate TEXT
      );
    ''');

  }
 Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {  
    await db.execute('''
      ALTER TABLE PV_Particulars
      ADD COLUMN FyID TEXT;
      ADD COLUMN FrmID TEXT;
    ''');
  }
}
  Future<void> insertPVParticulars(List<Map<String, dynamic>> data) async {
    final db = await database;
        Batch batch = db.batch();
    for (var row in data) {
      batch.insert(
        'RV_Particulars',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<void> insertRVParticulars(Map<String, dynamic> payData) async {
  final db = await database;

  try {
    print('Inserting LedgerData: $payData');

    final result = await db.insert(
      'RV_Particulars',
      payData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('Insertion successful. Row inserted with ID: $result');
    } else {
      print('Insertion failed. No row inserted.');
    }

    // Check if the data exists
    final checkResult = await db.query(
      'RV_Particulars',
      where: 'auto = ?',
      whereArgs: [payData['auto']],
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
  
  Future<List<Map<String, dynamic>>> fetchPVParticulars() async {
    final db = await database;
    return await db.query('RV_Particulars');
  }

  Future<List<Map<String, dynamic>>> fetchRVParticulars() async {
    final db = await database;
    return await db.query('RV_Particulars');
  }
  Future<void> insertRVInformation(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'RV_Information',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('RV_Information Inserted: $data');
      } else {
        print(' Failed to insert RV_Information.');
      }
    } catch (e) {
      print(' Error inserting into RV_Information: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRVInformation() async {
    final db = await database;
    return await db.query("RV_Information");
  }

   Future<List<Map<String, dynamic>>> fetch_R_vPerticularsDataFromMSSQL() async {
    try {
      final query = 'SELECT  auto,EntryNo,Name,Amount,Discount,Total,Narration,ddate FROM RV_Particulars';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for RV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for RV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from RV_Particulars: $e');
      rethrow;
    }
  }

     Future<List<Map<String, dynamic>>> fetch_R_vInformationsDataFromMSSQL() async {
    try {
      final query = 'SELECT RealEntryNo, DDATE, AMOUNT, Discount, Total, DEBITACCOUNT, takeuser, Location,Project,SalesMan,MonthDate,app,Transfer_Status,FyID,EntryNo,FrmID,pviCurrency,pviCurrencyValue,pdate FROM RV_Information';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for RV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for RV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from RV_Particulars: $e');
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

  // Date filtering
  if (fromDate != null && toDate != null) {
    String fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
    String toDateString = DateFormat('yyyy-MM-dd').format(toDate);

    whereClauses.add("DATE(ddate) BETWEEN DATE(?) AND DATE(?)");
    whereArgs.addAll([fromDateString, toDateString]);
  }

  // Ledger name filtering
  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('Name LIKE ?');
    whereArgs.add('%$ledgerName%');
  }

  // Construct WHERE clause
  String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

  try {
    return await db.query(
      'RV_Particulars',
      where: whereClause.isNotEmpty ? whereClause : null, 
      whereArgs: whereClause.isNotEmpty ? whereArgs : null,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}
Future<List<Map<String, dynamic>>> fetchNewRVParticulars(int lastMssqlAuto) async {
  final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
    'RV_Particulars',
    where: 'auto > ?',
    whereArgs: [lastMssqlAuto],
    orderBy: 'auto ASC',
  );

  return result;
}

Future<List<Map<String, dynamic>>> fetchNewRVInformation(int lastMssqlAuto) async {
  final db = await database;
  
  // Fetch only newly added rows where auto > last MSSQL auto
  final List<Map<String, dynamic>> result = await db.query(
    'RV_Information',
    where: 'RealEntryNo > ?',
    whereArgs: [lastMssqlAuto],
    orderBy: 'RealEntryNo ASC',
  );

  return result;
}
}
