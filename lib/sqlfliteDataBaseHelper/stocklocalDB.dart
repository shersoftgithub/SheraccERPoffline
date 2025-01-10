import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

class StocklocaldbHelper {
  static const _databaseName = "StockLocal.db";
  static const _databaseVersion = 2; // Increment this if you're making schema changes
  static const table = 'stock_table';

  static const columnId = 'Uniquecode';
  static const columnItemid = 'ItemId';
  static const columnserialno = 'serialno';
  static const columnsuppiler = 'supplier';
  static const columnQty = 'Qty';
  static const columnDiscount = 'Disc';
  static const columnfree = 'Free';
  static const columnPrate = 'Prate';
  static const columnAmount = 'Amount';
  static const columnTaxtype = 'TaxType';
  static const columncategory = 'Catagory';
  static const columnSrate = 'SRate';
  static const columnMrp = 'Mrp';
  static const columnRetail = 'Retail';
  static const columnSpRetail = 'SpRetail';
  static const columnWSrate = 'WsRate';
  static const columnBranch = 'Branch';
  static const columnRealrate = 'RealPrate';
  static const columnlocation = 'Locat';

  static final StocklocaldbHelper instance = StocklocaldbHelper._privateConstructor();
  static Database? _database;

  StocklocaldbHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Open the database and initialize if not already done.
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    // Initialize the database, create it if it doesn't exist
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create the table in the database
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        $columnId TEXT PRIMARY KEY,
        $columnItemid TEXT NOT NULL,
        $columnserialno TEXT NOT NULL,
        $columnsuppiler TEXT NOT NULL,
        $columnQty REAL NOT NULL DEFAULT 0.0,
        $columnDiscount REAL NOT NULL DEFAULT 0.0,
        $columnfree REAL NOT NULL DEFAULT 0.0,
        $columnPrate REAL NOT NULL DEFAULT 0.0,
        $columnAmount REAL NOT NULL DEFAULT 0.0,
        $columnTaxtype TEXT NOT NULL,
        $columncategory TEXT NOT NULL,
        $columnSrate REAL NOT NULL DEFAULT 0.0,
        $columnMrp REAL NOT NULL DEFAULT 0.0,
        $columnRetail REAL NOT NULL DEFAULT 0.0,
        $columnSpRetail REAL NOT NULL DEFAULT 0.0,
        $columnWSrate REAL NOT NULL DEFAULT 0.0,
        $columnBranch TEXT NOT NULL,
        $columnRealrate REAL NOT NULL DEFAULT 0.0,
        $columnlocation TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Perform schema upgrade, such as dropping tables or modifying columns
      await db.execute('DROP TABLE IF EXISTS $table');
      await _createDB(db, newVersion); // Recreate the table after upgrading
    }
  }

  Future<void> insertData(Map<String, dynamic> data) async {
    try {
      final db = await database;

      // Check if the table exists
      var tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='$table'");
      if (tables.isEmpty) {
        print('Table $table does not exist');
      } else {
        // If the table exists, insert data
        await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
        print('Data inserted into $table');
      }
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await database;
    return await db.query(table);
  }
}
