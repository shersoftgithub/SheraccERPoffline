import 'dart:convert';

import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CompanyDatabaseHelper {
  static final CompanyDatabaseHelper instance = CompanyDatabaseHelper._init();
  static Database? _database;

  CompanyDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('company.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,  
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
     await db.execute('''
      CREATE TABLE IF NOT EXISTS Company(
         Code TEXT PRIMARY KEY,
            Presumptive INTEGER,
            Sname TEXT,
            name TEXT,
            add1 TEXT,
            add2 TEXT,
            add3 TEXT,
            add4 TEXT,
            add5 TEXT,
            PrintName TEXT,
            telephone TEXT,
            email TEXT,
            mobile TEXT,
            tin TEXT,
            cst TEXT,
            kgst TEXT,
            pin TEXT,
            sdate DATETIME,
            edate DATETIME,
            DC INTEGER,
            GC INTEGER,
            TaxCollection INTEGER,
            TaxDueCollection INTEGER,
            BelowTurnOver INTEGER,
            TurnOverDate DATETIME,
            backhand TEXT,
            vbackhand TEXT,
            printerType TEXT,
            PrintModel TEXT,
            negativestock INTEGER,
            TaxCalcuLate INTEGER,
            Editoption INTEGER,
            TaxCalculation TEXT,
            profitshow INTEGER,
            cstPersentage REAL,
            Hidden INTEGER,
            PapperType TEXT,
            PrinterPort TEXT,
            Network INTEGER,
            NetWorkPort TEXT,
            AUTO INTEGER,
            DACC INTEGER,
            DLNO TEXT,
            DBName TEXT,
            MDFPath TEXT,
            LDFPath TEXT,
            VDBName TEXT,
            VMDFPath TEXT,
            VLDFPath TEXT,
            CType TEXT,
            CCompany INTEGER,
            EXDuty NUMERIC,
            DACCAll INTEGER,
            AddExDuty REAL,
            currencytype TEXT,
            stype TEXT,
            cess REAL,
            barcodecurrencytype TEXT,
            secondfont TEXT,
            s_currency TEXT,
            sheight TEXT,
            CustomerCode TEXT,
            insDate DATETIME
      )
    ''');
  
  }

  Future<void> insertCompany(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'Company',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('Company Inserted: $data');
      } else {
        print(' Failed to insert Company.');
      }
    } catch (e) {
      print(' Error inserting into Company: $e');
    }
  }

  // Get all sale references
  Future<List<Map<String, dynamic>>> getAllCompany() async {
    final db = await database;
    try {
      return await db.query('Company');
    } catch (e) {
      throw Exception("Failed to fetch sale references: $e");
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
   Future<int> getRowCount() async {
    final db = await database;
    try {
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Company'));
      print('SQLite Row Count: $count');
      return count ?? 0;
    } catch (e) {
      print('Error fetching row count: $e');
      return 0;
    }
  }
}


    Future<List<Map<String, dynamic>>> fetchDataCompanyFromMSSQL2() async {
    try {
      final query = '''
  SELECT DISTINCT Code, Presumptive, Sname, name, add1, add2, add3, add4, add5, 
         PrintName, telephone, email, mobile, tin, cst, kgst, pin, sdate, edate, 
         DC, GC, TaxCollection, TaxDueCollection, BelowTurnOver, TurnOverDate, 
         backhand, vbackhand, printerType, PrintModel, negativestock, TaxCalcuLate, 
         Editoption, TaxCalculation, profitshow, cstPercentage, Hidden, PapperType, 
         PrinterPort, Network, NetWorkPort, AUTO, DACC, DLNO, DBName, MDFPath, 
         LDFPath, VDBName, VMDFPath, VLDFPath, CType, CCompany, EXDuty, DACCAll, 
         AddExDuty, currencytype, stype, cess, barcodecurrencytype, secondfont, 
         s_currency, sheight, CustomerCode, insDate
  FROM Company
  ORDER BY Code ASC
''';

      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for Company data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for Company: $rawData');
    } catch (e) {
      print('Error fetching data from Company: $e');
      rethrow;
    }
  }
 Future<List<Map<String, dynamic>>> fetchDataCompanyFromMSSQL() async {
  try {
    final query = '''
      SELECT DISTINCT Code, Presumptive, Sname, name, add1, add2, add3, add4, add5, 
             PrintName, telephone, email, mobile, tin, cst, kgst, pin, sdate, edate, 
             DC, GC, TaxCollection, TaxDueCollection, BelowTurnOver, TurnOverDate, 
             backhand, vbackhand, printerType, PrintModel, negativestock, TaxCalcuLate, 
             Editoption, TaxCalculation, profitshow, cstPersentage, Hidden, PapperType, 
             PrinterPort, Network, NetWorkPort, AUTO, DACC, DLNO, DBName, MDFPath, 
             LDFPath, VDBName, VMDFPath, VLDFPath, CType, CCompany, EXDuty, DACCAll, 
             AddExDuty, currencytype, stype, cess, barcodecurrencytype, secondfont, 
             s_currency, sheight, CustomerCode, insDate
      FROM Company
      ORDER BY Code ASC
    ''';

    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);

      if (decodedData is List) {
        // Ensure each row has all expected fields
        return decodedData.map((row) {
          return {
            'Code': row['Code']?.toString() ?? '',
            'Presumptive': row['Presumptive'] ?? 0,
            'Sname': row['Sname']?.toString() ?? '',
            'name': row['name']?.toString() ?? '',
            'add1': row['add1']?.toString() ?? '',
            'add2': row['add2']?.toString() ?? '',
            'add3': row['add3']?.toString() ?? '',
            'add4': row['add4']?.toString() ?? '',
            'add5': row['add5']?.toString() ?? '',
            'PrintName': row['PrintName']?.toString() ?? '',
            'telephone': row['telephone']?.toString() ?? '',
            'email': row['email']?.toString() ?? '',
            'mobile': row['mobile']?.toString() ?? '',
            'tin': row['tin']?.toString() ?? '',
            'cst': row['cst']?.toString() ?? '',
            'kgst': row['kgst']?.toString() ?? '',
            'pin': row['pin']?.toString() ?? '',
            'sdate': row['sdate']?.toString() ?? '',
            'edate': row['edate']?.toString() ?? '',
            'DC': row['DC'] ?? 0,
            'GC': row['GC'] ?? 0,
            'TaxCollection': row['TaxCollection'] ?? 0,
            'TaxDueCollection': row['TaxDueCollection'] ?? 0,
            'BelowTurnOver': row['BelowTurnOver'] ?? 0,
            'TurnOverDate': row['TurnOverDate']?.toString() ?? '',
            'backhand': row['backhand']?.toString() ?? '',
            'vbackhand': row['vbackhand']?.toString() ?? '',
            'printerType': row['printerType']?.toString() ?? '',
            'PrintModel': row['PrintModel']?.toString() ?? '',
            'negativestock': row['negativestock'] ?? 0,
            'TaxCalcuLate': row['TaxCalcuLate'] ?? 0,
            'Editoption': row['Editoption'] ?? 0,
            'TaxCalculation': row['TaxCalculation']?.toString() ?? '',
            'profitshow': row['profitshow'] ?? 0,
            'cstPersentage': row['cstPersentage'] ?? 0.0,
            'Hidden': row['Hidden'] ?? 0,
            'PapperType': row['PapperType']?.toString() ?? '',
            'PrinterPort': row['PrinterPort']?.toString() ?? '',
            'Network': row['Network'] ?? 0,
            'NetWorkPort': row['NetWorkPort']?.toString() ?? '',
            'AUTO': row['AUTO'] ?? 0,
            'DACC': row['DACC'] ?? 0,
            'DLNO': row['DLNO']?.toString() ?? '',
            'DBName': row['DBName']?.toString() ?? '',
            'MDFPath': row['MDFPath']?.toString() ?? '',
            'LDFPath': row['LDFPath']?.toString() ?? '',
            'VDBName': row['VDBName']?.toString() ?? '',
            'VMDFPath': row['VMDFPath']?.toString() ?? '',
            'VLDFPath': row['VLDFPath']?.toString() ?? '',
            'CType': row['CType']?.toString() ?? '',
            'CCompany': row['CCompany'] ?? 0,
            'EXDuty': row['EXDuty'] ?? 0.0,
            'DACCAll': row['DACCAll'] ?? 0,
            'AddExDuty': row['AddExDuty'] ?? 0.0,
            'currencytype': row['currencytype']?.toString() ?? '',
            'stype': row['stype']?.toString() ?? '',
            'cess': row['cess'] ?? 0.0,
            'barcodecurrencytype': row['barcodecurrencytype']?.toString() ?? '',
            'secondfont': row['secondfont']?.toString() ?? '',
            's_currency': row['s_currency']?.toString() ?? '',
            'sheight': row['sheight']?.toString() ?? '',
            'CustomerCode': row['CustomerCode']?.toString() ?? '',
            'insDate': row['insDate']?.toString() ?? '',
          };
        }).toList();
      }
    }
    throw Exception('Invalid data format from MSSQL');
  } catch (e) {
    print('Error fetching data from MSSQL: $e');
    return [];
  }
}

Future<void> backupMSSQLToSQLite2() async {
  final dbHelper = CompanyDatabaseHelper.instance;
  await dbHelper.enableWALMode(); 

  try {
    final fetchedData = await fetchDataCompanyFromMSSQL();

    if (fetchedData.isEmpty) {
      print('No data to backup.');
      return;
    }

    print('Total rows fetched: ${fetchedData.length}');

    final db = await dbHelper.database;
    final batch = db.batch();

    for (var row in fetchedData) {
      batch.insert('Company', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);

    final sqliteRowCount = await dbHelper.getRowCount();
    print('SQLite contains $sqliteRowCount rows after backup.');

    if (sqliteRowCount != fetchedData.length) {
      print('Warning: Mismatch in row count!');
    } else {
      print('Backup successful.');
    }
  } catch (e) {
    print('Error during backup: $e');
  }
}