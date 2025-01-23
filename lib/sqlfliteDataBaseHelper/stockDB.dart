import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StockDatabaseHelper {
  static final StockDatabaseHelper instance = StockDatabaseHelper._init();
  static Database? _database;

  StockDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stock.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create stock table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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

    // Create product_registration table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_registration(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemcode TEXT NOT NULL,
        hsncode TEXT NOT NULL,
        itemname TEXT NOT NULL,
        Catagory_id TEXT NOT NULL,
        unit_id TEXT NOT NULL,
        taxgroup_id TEXT NOT NULL,
        tax REAL NOT NULL,
        cgst REAL NOT NULL,
        sgst REAL NOT NULL,
        igst REAL NOT NULL,
        cess REAL NOT NULL,
        cessper REAL NOT NULL,
        adcessper REAL NOT NULL,
        mrp REAL NOT NULL,
        retail REAL NOT NULL,
        wsrate REAL NOT NULL,
        sprate REAL NOT NULL,
        branch TEXT NOT NULL,
        stockvaluation TEXT NOT NULL,
        typeofsupply TEXT NOT NULL,
        RegItemName TEXT NOT NULL,
        StockQty REAL NOT NULL,
        TaxGroup_Name TEXT NOT NULL,
        IsWarranty INTEGER NOT NULL,
        TotalWarrantyMonth INTEGER NOT NULL,
        ReplaceWarrantyMonth INTEGER NOT NULL,
        ProRataWarrantyMonth INTEGER NOT NULL,
        prSupplier TEXT NOT NULL,
        isInventory INTEGER NOT NULL,
        ItemGroup1 TEXT NOT NULL,
        ItemGroup2 TEXT NOT NULL,
        ItemGroup3 TEXT NOT NULL,
        ItemGroup4 TEXT NOT NULL,
        ItemGroup5 TEXT NOT NULL,
        Series_Id TEXT NOT NULL,
        isMOP INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < newVersion) {
    // You can add checks here to ensure new tables are created if necessary
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS product_registration(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          itemcode TEXT NOT NULL,
          hsncode TEXT NOT NULL,
          itemname TEXT NOT NULL,
          Catagory_id TEXT NOT NULL,
          unit_id TEXT NOT NULL,
          taxgroup_id TEXT NOT NULL,
          tax REAL NOT NULL,
          cgst REAL NOT NULL,
          sgst REAL NOT NULL,
          igst REAL NOT NULL,
          cess REAL NOT NULL,
          cessper REAL NOT NULL,
          adcessper REAL NOT NULL,
          mrp REAL NOT NULL,
          retail REAL NOT NULL,
          wsrate REAL NOT NULL,
          sprate REAL NOT NULL,
          branch TEXT NOT NULL,
          stockvaluation TEXT NOT NULL,
          typeofsupply TEXT NOT NULL,
          RegItemName TEXT NOT NULL,
          StockQty REAL NOT NULL,
          TaxGroup_Name TEXT NOT NULL,
          IsWarranty INTEGER NOT NULL,
          TotalWarrantyMonth INTEGER NOT NULL,
          ReplaceWarrantyMonth INTEGER NOT NULL,
          ProRataWarrantyMonth INTEGER NOT NULL,
          prSupplier TEXT NOT NULL,
          isInventory INTEGER NOT NULL,
          ItemGroup1 TEXT NOT NULL,
          ItemGroup2 TEXT NOT NULL,
          ItemGroup3 TEXT NOT NULL,
          ItemGroup4 TEXT NOT NULL,
          ItemGroup5 TEXT NOT NULL,
          Series_Id TEXT NOT NULL,
          isMOP INTEGER NOT NULL
        )
      ''');
    }}}

  Future<int> insertStockData(Map<String, dynamic> data) async {
    final db = await database;
    try {
      return await db.insert(
        'stock',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Failed to insert data into stock: $e");
    }
  }

  Future<int> insertProductRegistrationData(Map<String, dynamic> data) async {
    final db = await database;
    try {
      return await db.insert(
        'product_registration',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Failed to insert data into Product_Registration: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllProductRegistration() async {
    final db = await database;
    try {
      return await db.query('product_registration');
    } catch (e) {
      throw Exception("Failed to fetch products from Product_Registration: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getProductByItemcode(String itemcode) async {
    final db = await database;
    try {
      return await db.query(
        'product_registration',
        where: 'itemcode = ?',
        whereArgs: [itemcode],
      );
    } catch (e) {
      throw Exception("Failed to fetch product with Itemcode $itemcode: $e");
    }
  }

  Future<int> insertData(Map<String, dynamic> data) async {
    data['supplier'] ??= 'Unknown';
    data['Category'] ??= 'Uncategorized';
    data['EstUnique'] ??= 'DefaultEstUnique';
    data['Cbarcode'] ??= 'Default';
    final db = await database;
    try {
      return await db.insert(
        'stock',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Failed to insert data into stock: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final db = await database;
      return await db.query('stock');
    } catch (e) {
      throw Exception("Failed to fetch products: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getProductByItemId(String itemId) async {
    try {
      final db = await database;
      return await db.query(
        'stock',
        where: 'ItemId = ?',
        whereArgs: [itemId],
      );
    } catch (e) {
      throw Exception("Failed to fetch product with ItemId $itemId: $e");
    }
  }

 Future<void> updateProductQuantity(String itemId, double newQuantity) async {
  final db = await database;
  await db.update(
    'stock',
    {'Qty': newQuantity},
    where: 'ItemId = ?',
    whereArgs: [itemId],
  );
}


  Future<int> deleteProduct(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'stock',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to delete product with ID $id: $e");
    }
  }
 Future<List<String>> getAllItemNames() async {
    final db = await instance.database;
    final result = await db.query('product_registration', columns: ['itemname']);
    return result.map((item) => item['itemname'] as String).toList();
  }
  Future<List<String>> getAllItemcode() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'stock',
      columns: ['ItemId'],
    );
    return result.map((row) => row['ItemId'] as String).toList();
  }

  Future<List<String>> getAllsupplier() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'stock',
      columns: ['supplier'],
    );
    return result.map((row) => row['supplier'] as String).toList();
  }

  Future<List<String>> getAllItemnames() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'product_registration',
      columns: ['itemname'],
    );
    return result.map((row) => row['itemname'] as String).toList();
  }

 Future<List<Map<String, String>>> getItemDetailsByName(String itemName) async {
  final db = await instance.database;
  final results = await db.query(
    'product_registration', 
    where: 'itemname = ?', 
    whereArgs: [itemName],
  );

  if (results.isEmpty) {
    return [];
  }

  return results.map((row) {
    return {
      "mrp": row["mrp"]?.toString() ?? "N/A",
      "retail": row["retail"]?.toString() ?? "N/A",
      "wsrate": row["wsrate"]?.toString() ?? "N/A",
      "sprate": row["sprate"]?.toString() ?? "N/A",
      "branch" :row["branch"]?.toString()??"N/A",
       "tax": row["tax"]?.toString() ?? "N/A", 
    };
  }).toList();
}

Future<void> updateProductQuantitystock(int id, double newQuantity) async {
  final db = await database;
  await db.update(
    'stock',
    {'Qty': newQuantity},
    where: 'ItemId = ?',
    whereArgs: [id],
  );
}

Future<String?> getItemIdByItemName(String itemName) async {
  final db = await database;
  final result = await db.query(
    'product_registration',
    where: 'itemname = ?',
    whereArgs: [itemName],
    limit: 1,
  );
  return result.isNotEmpty ? result.first['itemcode'] as String? : null;
}


// Step 2: Fetch stock data using ItemId from the stock table.
Future<Map<String, dynamic>?> getProductByItemId2(String itemId) async {
  final db = await database;
  final result = await db.query(
    'stock',
    where: 'ItemId = ?',
    whereArgs: [itemId],
    limit: 1,
  );
  return result.isNotEmpty ? result.first : null;
}

Future<List<Map<String, dynamic>>> getStockWithItemNames() async {
  final db = await database;
  try {
    return await db.rawQuery('''
      SELECT 
        stock.id, 
        stock.ItemId, 
        product_registration.itemname, 
        stock.Qty, 
        stock.Disc, 
        stock.Amount
      FROM 
        stock
      LEFT JOIN 
        product_registration 
      ON 
        stock.ItemId = product_registration.itemcode
    ''');
  } catch (e) {
    throw Exception("Failed to fetch joined stock data: $e");
  }
}

 Future<List<Map<String, dynamic>>> getFilteredStockData({
    required String itemcode,
    required String supplier,
    required DateTime? fromDate,
    required DateTime? toDate,
    required String itemname,
  }) async {
    final db = await database;

    String query = 'SELECT stock.id, stock.ItemId, product_registration.itemname, stock.Qty, stock.Disc, stock.Amount '
                   'FROM stock '
                   'LEFT JOIN product_registration ON stock.ItemId = product_registration.itemcode '
                   'WHERE 1=1'; 

    // Apply filters
    if (itemcode.isNotEmpty) {
      query += ' AND stock.ItemId = "$itemcode"';
    }
    if (supplier.isNotEmpty) {
      query += ' AND stock.supplier = "$supplier"';
    }
     if (itemname.isNotEmpty) {
      query += ' AND product_registration.itemname = "$itemname"';
    }
    if (fromDate != null && toDate != null) {
      query += ' AND stock.Pdate BETWEEN "${DateFormat('dd-MM-yyyy').format(fromDate)}" '
               'AND "${DateFormat('dd-MM-yyyy').format(toDate)}"';
    }

    final result = await db.rawQuery(query);
    return result;
  }
}
