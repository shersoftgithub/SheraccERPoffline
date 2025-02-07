import 'dart:async';
import 'dart:convert';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PV_DatabaseHelper {
  static const _databaseName = "pv_database.db";
  static const _databaseVersion = 2;

  // Singleton pattern
  PV_DatabaseHelper._privateConstructor();
  static final PV_DatabaseHelper instance = PV_DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS PV_Particulars (
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
      CREATE TABLE IF NOT EXISTS Caccount (
        AccountName TEXT PRIMARY KEY
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS PV_Information (
        RealEntryNo INTEGER PRIMARY KEY AUTOINCREMENT,
        DDATE TEXT,
        AMOUNT REAL,
        Discount REAL,
        Total REAL,
        CreditAccount TEXT,
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


  Future<void> insertPVInformation(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'PV_Information',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print(' PV_Information Inserted: $data');
      } else {
        print(' Failed to insert PV_Information.');
      }
    } catch (e) {
      print(' Error inserting into PV_Information: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPVInformation() async {
    final db = await database;
    return await db.query("PV_Information");
  }

  Future<void> insertPVParticulars(Map<String, dynamic> payData) async {
    final db = await database;

    try {
      print('Inserting LedgerData: $payData');

      final result = await db.insert(
        'PV_Particulars',
        payData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print(' PV_Particulars Inserted: $payData');
      } else {
        print(' Failed to insert PV_Particulars.');
      }
    } catch (e) {
      print('Error inserting into PV_Particulars: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPVParticulars() async {
    final db = await database;
    return await db.query("PV_Particulars");
  }

  Future<void> insertCaccount(String accountName) async {
    final db = await database;
    try {
      await db.insert(
        'Caccount',
        {'AccountName': accountName},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print(' Caccount Inserted: $accountName');
    } catch (e) {
      print(' Error inserting into Caccount: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCaccount() async {
    final db = await database;
    return await db.query("Caccount");
  }

  Future<List<Map<String, dynamic>>> fetch_P_vPerticularsDataFromMSSQL() async {
    try {
      final query = 'SELECT auto, EntryNo, Name, Amount, Discount, Total, Narration, ddate FROM PV_Particulars';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for PV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for PV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from PV_Particulars: $e');
      rethrow;
    }
  }
Future<List<Map<String, dynamic>>> fetch_RV_InformationsDataFromMSSQL() async {
    try {
      final query = 'SELECT RealEntryNo, DDATE, AMOUNT, Discount, Total, CreditAccount, takeuser, Location,Project,SalesMan,MonthDate,app,Transfer_Status,FyID,EntryNo,FrmID,rviCurrency,rviCurrencyValue,pdate FROM RV_Information';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for PV_Particulars data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for PV_Particulars: $rawData');
    } catch (e) {
      print('Error fetching data from PV_Particulars: $e');
      rethrow;
    }
  }
    
}
