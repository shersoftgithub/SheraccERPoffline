import 'dart:convert';

import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SalesInformationDatabaseHelper {
  static final SalesInformationDatabaseHelper instance = SalesInformationDatabaseHelper._init();
  static Database? _database;

  SalesInformationDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sales_information.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Sales_Information (
        RealEntryNo INTEGER PRIMARY KEY AUTOINCREMENT,
        InvoiceNo TEXT NOT NULL,
        DDate TEXT NOT NULL,
        Customer TEXT NOT NULL,
        Toname TEXT NOT NULL,
        Discount REAL NOT NULL,
        NetAmount REAL NOT NULL,
        Total REAL NOT NULL,
        TotalQty INTEGER NOT NULL
      )
    ''');
      await db.execute('''
    CREATE TABLE Sales_Particulars (
      ParticularID INTEGER PRIMARY KEY AUTOINCREMENT,
      DDate TEXT NOT NULL,
      EntryNo REAL,
      UniqueCode REAL,
      ItemID INTEGER,
      serialno TEXT,
      Rate REAL,
      RealRate REAL,
      Qty REAL,
      freeQty REAL,
      GrossValue REAL,
      DiscPersent REAL,
      Disc REAL,
      RDisc REAL,
      Net REAL,
      Vat REAL,
      freeVat REAL,
      cess REAL,
      Total REAL,
      Profit REAL,
      Auto INTEGER,
      Unit INTEGER,
      UnitValue REAL,
      Funit INTEGER,
      FValue REAL,
      commision REAL,
      GridID INTEGER,
      takeprintstatus TEXT,
      QtyDiscPercent REAL,
      QtyDiscount REAL,
      ScheemDiscPercent REAL,
      ScheemDiscount REAL,
      CGST REAL,
      SGST REAL,
      IGST REAL,
      adcess REAL,
      netdisc REAL,
      taxrate INTEGER,
      SalesmanId TEXT,
      Fcess REAL,
      Prate REAL,
      Rprate REAL,
      location INTEGER,
      Stype INTEGER,
      LC REAL,
      ScanBarcode TEXT,
      Remark TEXT,
      FyID INTEGER,
      Supplier TEXT,
      Retail REAL,
      spretail REAL,
      wsrate REAL
    )
  ''');
  }

  // // **Insert Data**
  // Future<int> insertSale(Map<String, dynamic> sale) async {
  //   final db = await instance.database;
  //   return await db.insert('Sales_Information', sale);
  // }
Future<void> insertSale(Map<String, dynamic> payData) async {
  final db = await database;

  try {
    print('Inserting LedgerData: $payData');

    final result = await db.insert(
      'Sales_Information',
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
      'Sales_Information',
      where: 'RealEntryNo = ?',
      whereArgs: [payData['RealEntryNo']],
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
  // **Fetch Data**
  Future<List<Map<String, dynamic>>> getSalesData() async {
    final db = await instance.database;
    return await db.query('Sales_Information');
  }

  Future<void> clearSalesTable() async {
    final db = await instance.database;
    await db.delete('Sales_Information');
  }

  Future<void> insertParticular(Map<String, dynamic> particularData) async {
  final db = await database;

  try {
    print('Inserting Particular Data: $particularData');

    final result = await db.insert(
      'Sales_Particulars',
      particularData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('Insertion successful. Row inserted with ID: $result');
    } else {
      print('Insertion failed. No row inserted.');
    }
        final checkResult = await db.query(
      'Sales_Particulars',
      where: 'ParticularID = ?',
      whereArgs: [result],
    );

    if (checkResult.isNotEmpty) {
      print('Data successfully inserted: ${checkResult.first}');
    } else {
      print('Data insertion was unsuccessful.');
    }
  } catch (e) {
    print('Error inserting particular data: $e');
  }
}

Future<List<Map<String, dynamic>>> getSalesDataperticular() async {
    final db = await instance.database;
    return await db.query('Sales_Particulars');
  }

  Future<List<Map<String, dynamic>>> fetch_sale_informationDataFromMSSQL() async {
   try {
      final query = 'SELECT  RealEntryNo,InvoiceNo,DDate,Customer,Toname,Discount,NetAmount,Total,TotalQty FROM Sales_Information';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for Sales_Information data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for Sales_Information: $rawData');
    } catch (e) {
      print('Error fetching data from Sales_Information: $e');
      rethrow;
    }
}

}
