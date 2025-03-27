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
    onOpen: (db) async {
      try {
        var result = await db.rawQuery('PRAGMA journal_mode=WAL;');
        print("WAL Mode Status: ${result.first.values.first}"); // Should print 'wal'
      } catch (e) {
        print("Error enabling WAL mode: $e");
      }
    },
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

   Future<void> insertProductRegistrationData2(Map<String, dynamic> data) async {
     final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO product_registration (
        itemcode,
        hsncode,
        itemname ,
        Catagory_id ,
        unit_id,
        taxgroup_id ,
        tax ,
        cgst ,
        sgst ,
        igst,
        cess ,
        cessper,
        adcessper,
        mrp,
        retail,
        wsrate,
        sprate,
        branch ,
        stockvaluation,
        typeofsupply,
        RegItemName,
        StockQty,
        TaxGroup_Name,
        IsWarranty,
        TotalWarrantyMonth,
        ReplaceWarrantyMonth,
        ProRataWarrantyMonth ,
        prSupplier,
        isInventory ,
        ItemGroup1,
        ItemGroup2,
        ItemGroup3,
        ItemGroup4 ,
        ItemGroup5 ,
        Series_Id ,
        isMOP 
         ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,? ,? , ? ,? , ?, ?, ? ,? ,?,?,?,?,?,?,?,?)
      ''', [
        data['itemcode']?.toString() ?? '',
        data['hsncode']?.toString() ?? '',
        data['itemname']?.toString() ?? '',
        data['Catagory_id']?.toString() ?? '',
        data['unit_id']?.toString() ?? '',
        data['taxgroup_id']?.toString() ?? '',
        data['tax']?.toString() ?? '',
        data['cgst']?.toString() ?? '',
        data['sgst']?.toString() ?? '',
        data['igst']?.toString() ?? '',
        data['cess']?.toString() ?? '',
        data['cessper']?.toString() ?? '',
        data['adcessper']?.toString() ?? '',
        data['mrp']?.toString() ?? '',
        data['retail']?.toString() ?? '',
        data['wsrate']?.toString() ?? '',
        data['sprate']?.toString() ?? '',
        data['branch']?.toString() ?? '',
        data['stockvaluation']?.toString() ?? '',
        data['typeofsupply']?.toString() ?? '',
        data['RegItemName']?.toString() ?? '',
        data['StockQty']?.toString() ?? '',
        data['TaxGroup_Name']?.toString() ?? '',
        data['IsWarranty']?.toString() ?? '',
        data['TotalWarrantyMonth']?.toString() ?? '',
        data['ReplaceWarrantyMonth']?.toString() ?? '',
        data['ProRataWarrantyMonth']?.toString() ?? '',
        data['prSupplier']?.toString() ?? '',
        data['isInventory']?.toString() ?? '',
        data['ItemGroup1']?.toString() ?? '',
        data['ItemGroup2']?.toString() ?? '',
        data['ItemGroup3']?.toString() ?? '',
        data['ItemGroup4']?.toString() ?? '',
        data['ItemGroup5']?.toString() ?? '',
        data['Series_Id']?.toString() ?? '',
        data['isMOP']?.toString() ?? '',
      ]);
    });

    print('product_registration Inserted Successfully');
  } catch (e) {
    print('Error inserting product_registration data: $e');
  }
  }

  Future<int> insertProductRegistrationData(Map<String, dynamic> data) async {
    final db = await database;
     try {
    final result = await db.insert(
      'product_registration',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('product_registration Inserted: $data');
    } else {
      print('Failed to insert product_registration.');
    }

    return result; 
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

  Future<void> insertDataStock(Map<String, dynamic> data) async {
  final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO stock (
        ItemId ,
        serialno ,
        supplier,
        Qty ,
        Disc,
        Free,
        Prate ,
        Amount,
        TaxType,
        Category ,
        SRate ,
        Mrp ,
        Retail ,
        SpRetail,
        WsRate ,
        Branch ,
        RealPrate ,
        Location ,
        EstUnique,
        Locked ,
        expDate ,
        Brand,
        Company,
        Size ,
        Color,
        obarcode ,
        todevice ,
        Pdate ,
        Cbarcode,
        SktSales  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,? ,? , ? ,? , ?, ?, ? ,? ,?,?)
      ''', [
        data['ItemId']?.toString() ?? '',
        data['serialno']?.toString() ?? '',
        data['supplier']?.toString() ?? '',
        data['Qty']?.toString() ?? '',
        data['Disc']?.toString() ?? '',
        data['Free']?.toString() ?? '',
        data['Prate']?.toString() ?? '',
        data['Amount']?.toString() ?? '',
        data['TaxType']?.toString() ?? '',
        data['Category']?.toString() ?? '',
        data['SRate']?.toString() ?? '',
        data['Mrp']?.toString() ?? '',
        data['Retail']?.toString() ?? '',
        data['SpRetail']?.toString() ?? '',
        data['WsRate']?.toString() ?? '',
        data['Branch']?.toString() ?? '',
        data['RealPrate']?.toString() ?? '',
        data['Location']?.toString() ?? '',
        data['EstUnique']?.toString() ?? '',
        data['Locked']?.toString() ?? '',
        data['expDate']?.toString() ?? '',
        data['Brand']?.toString() ?? '',
        data['Company']?.toString() ?? '',
        data['Size']?.toString() ?? '',
        data['Color']?.toString() ?? '',
        data['obarcode']?.toString() ?? '',
        data['todevice']?.toString() ?? '',
        data['Pdate']?.toString() ?? '',
        data['Cbarcode']?.toString() ?? '',
        data['SktSales']?.toString() ?? '',
      ]);
    });

    print('stock Inserted Successfully');
  } catch (e) {
    print('Error inserting stock data: $e');
  }
}

 Future<int> insertData(Map<String, dynamic> data) async {
  data['supplier'] ??= 'Unknown';
  data['Category'] ??= 'Uncategorized';
  data['EstUnique'] ??= 'DefaultEstUnique';
  data['Cbarcode'] ??= 'Default';
  
  final db = await database;

  try {
    final result = await db.insert(
      'stock',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('Stock Inserted: $data');
    } else {
      print('Failed to insert stock.');
    }

    return result; 
  } catch (e) {
    print("Failed to insert data into stock: $e");
    return -1; 
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

   Future<Map<String, dynamic>?> getStockDetailsByName(String ledgerName) async {
    final db = await instance.database;
    final result = await db.query(
      'product_registration',
      columns: ['itemcode','retail','wsrate','sprate'],
      where: 'itemname = ?',
      whereArgs: [ledgerName],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> clearStockTable() async {
    final db = await instance.database;
    await db.delete('stock');
  }
   Future<void> clearPregTable() async {
    final db = await instance.database;
    await db.delete('product_registration');
  }

  Future<Map<String, dynamic>?> getProductByIdAndItemId(int id, String itemId) async {
  final db = await database; // Ensure database instance is initialized

  final result = await db.query(
    'stock', 
    where: 'id = ? AND ItemId = ?',
    whereArgs: [id, itemId],
    limit: 1,
  );

  return result.isNotEmpty ? result.first : null;
}
  Future<List<Map<String, dynamic>>> getItemDetails() async {
    final db = await database;
    
    String query = '''
      SELECT 
        s.ItemId AS stockItemId, 
        pr.itemcode AS productItemId, 
        pr.itemname, 
        s.Qty AS stockQty, 
        pr.StockQty AS productQty
      FROM stock s
      LEFT JOIN product_registration pr
        ON s.ItemId = pr.itemcode;
    ''';

    final List<Map<String, dynamic>> result = await db.rawQuery(query);
    return result;
  }
Future<List<Map<String, dynamic>>> getItemDetails2() async {
  final db = await database;

  String query = '''
    SELECT 
      s.ItemId AS stockItemId, 
      pr.itemcode AS productItemId, 
      pr.itemname, 
      s.Qty AS stockQty, 
      pr.StockQty AS productQty
    FROM stock s
    LEFT JOIN product_registration pr
      ON s.ItemId = pr.itemcode;
  ''';

  final result = await db.rawQuery(query);
  return result;  
}

  getSalesParticulars() {}

}
