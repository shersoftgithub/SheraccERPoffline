import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SaleReferenceDatabaseHelper {
  static final SaleReferenceDatabaseHelper instance = SaleReferenceDatabaseHelper._init();
  static Database? _database;

  SaleReferenceDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('salereference.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,  
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
     await db.execute('''
      CREATE TABLE IF NOT EXISTS stock(
        Uniquecode TEXT NOT NULL,
        ItemId TEXT NOT NULL,
        serialno TEXT NOT NULL,
        supplier TEXT NOT NULL DEFAULT 'Unknown',
        Qty REAL NOT NULL DEFAULT 0.0,
        Disc REAL NOT NULL DEFAULT 0.0,
        Free REAL NOT NULL DEFAULT 0.0,
        Prate REAL NOT NULL DEFAULT 0.0,
        Amount REAL NOT NULL DEFAULT 0.0,
        TaxType TEXT NOT NULL,
        Category TEXT NOT NULL DEFAULT 'Uncategorized',
        SRate REAL NOT NULL DEFAULT 0.0,
        Mrp REAL NOT NULL DEFAULT 0.0,
        Retail REAL NOT NULL DEFAULT 0.0,
        SpRetail REAL NOT NULL DEFAULT 0.0,
        WsRate REAL NOT NULL DEFAULT 0.0,
        Branch TEXT NOT NULL,
        RealPrate REAL NOT NULL DEFAULT 0.0,
        Location TEXT NOT NULL,
        EstUnique TEXT NOT NULL DEFAULT 'DefaultEstUnique',
        Locked TEXT NOT NULL,
        expDate TEXT NOT NULL,
        Brand TEXT NOT NULL,
        Company TEXT NOT NULL,
        Size TEXT NOT NULL,
        Color TEXT NOT NULL,
        obarcode TEXT NOT NULL,
        todevice TEXT NOT NULL,
        Pdate TEXT NOT NULL,
        Cbarcode TEXT NOT NULL DEFAULT 'Default',
        SktSales TEXT NOT NULL
      )
    ''');
    await db.execute('''
  CREATE TABLE IF NOT EXISTS Unit_Details(
    ItemId TEXT NOT NULL,
    PUnit TEXT NOT NULL,
    SUnit TEXT NOT NULL,
    Unit TEXT NOT NULL,
    Conversion REAL NOT NULL,
    Auto INTEGER NOT NULL,
    Rate REAL NOT NULL,
    Barcode TEXT NOT NULL,
    IsGatePass INTEGER NOT NULL
  )
''');
  await db.execute('''
  CREATE TABLE IF NOT EXISTS FinancialYear(
    Fyid TEXT NOT NULL,
    Frmdate TEXT NOT NULL,
    Todate TEXT NOT NULL
   
  )
''');
 await db.execute('''
  CREATE TABLE IF NOT EXISTS LedgerHeads(
    lh_id TEXT NOT NULL,
    Mlh_id TEXT NOT NULL,
    lh_name TEXT NOT NULL,
    lh_Code TEXT NOT NULL
  )
''');
 await db.execute('''
  CREATE TABLE IF NOT EXISTS Settings(
    Name TEXT NOT NULL,
    Status TEXT NOT NULL
   
  )
''');


  }
  Future<void> insertSettings(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'Settings',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('Settings Inserted: $data');
      } else {
        print(' Failed to insert Settings.');
      }
    } catch (e) {
      print(' Error inserting into Settings: $e');
    }
  }
  Future<void> insertLedgerheads(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'LedgerHeads',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('LedgerHeads Inserted: $data');
      } else {
        print(' Failed to insert LedgerHeads.');
      }
    } catch (e) {
      print(' Error inserting into LedgerHeads: $e');
    }
  }
Future<void> insertfyid(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'FinancialYear',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('FinancialYear Inserted: $data');
      } else {
        print(' Failed to insert FinancialYear.');
      }
    } catch (e) {
      print(' Error inserting into FinancialYear: $e');
    }
  }
  Future<void> insertStock(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'stock',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('stock Inserted: $data');
      } else {
        print(' Failed to insert stock.');
      }
    } catch (e) {
      print(' Error inserting into stock: $e');
    }
  }
Future<void> insertunit(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'Unit_Details',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('Unit_Details Inserted: $data');
      } else {
        print(' Failed to insert Unit_Details.');
      }
    } catch (e) {
      print(' Error inserting into Unit_Details: $e');
    }
  }
  // Get all sale references
  Future<List<Map<String, dynamic>>> getAllSaleReferencesStock() async {
    final db = await database;
    try {
      return await db.query('stock');
    } catch (e) {
      throw Exception("Failed to fetch sale references: $e");
    }
  }
 Future<List<Map<String, dynamic>>> getAllfyid() async {
    final db = await database;
    try {
      return await db.query('FinancialYear');
    } catch (e) {
      throw Exception("Failed to fetch FinancialYear references: $e");
    }
  }
 Future<List<String>> getAllLedgerHeadNames() async {
  final db = await database;
  try {
    final List<Map<String, dynamic>> result =
        await db.query('LedgerHeads', columns: ['lh_name']);
    return result.map((row) => row['lh_name'] as String).toList();
  } catch (e) {
    throw Exception("Failed to fetch LedgerHead names: $e");
  }
}

  Future<List<Map<String, dynamic>>> getAllsettings() async {
    final db = await database;
    try {
      return await db.query('Settings');
    } catch (e) {
      throw Exception("Failed to fetch FinancialYear references: $e");
    }
  }
  Future<Map<String, dynamic>?> getSaleReferenceBySaleId(String saleId) async {
    final db = await database;
    try {
      final result = await db.query(
        'salereference',
        where: 'SaleId = ?',
        whereArgs: [saleId],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw Exception("Failed to fetch sale reference by SaleId: $e");
    }
  }
  Future<Map<String, dynamic>?> getStockSaleDetailsByName(String ledgerName) async {
    final db = await instance.database;
    final result = await db.query(
      'stock',
      columns: ['Uniquecode','Disc','Pdate','RealPrate','Prate'],
      where: 'ItemId = ?',
      whereArgs: [ledgerName],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
   Future<Map<String, dynamic>?> getStockunitDetailsByName(String ledgerName) async {
    final db = await instance.database;
    final result = await db.query(
      'Unit_Details',
      columns: ['Unit'],
      where: 'ItemId = ?',
      whereArgs: [ledgerName],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> updateSetting(String name, int status) async {
  final db = await database;
  await db.update(
    'Settings',
    {'Status': status.toString()},
    where: 'Name = ?',
    whereArgs: [name],
  );
}

}
