import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SaleDatabaseHelper {
  static const _databaseName = "salescredit.db";
  static const _databaseVersion = 2;

  static const table = 'salescredit_table';

  // Column names
  static const columnId = 'invoice_id';
  static const columnDate = 'date';
  static const columnSaleRate = 'sales_rate';
  static const columnCustomer = 'customer';
  static const columnPhoneNo = 'phoneNo';
  static const columnItemName = 'item_name';
  static const columnQTY = 'qty';
  static const columnUnit = 'unit';
  static const columnRate = 'rate';
  static const columnTax = 'tax';
  static const columnTotalAmt = 'total_amt';

  // Singleton instance
  static final SaleDatabaseHelper instance = SaleDatabaseHelper._privateConstructor();
  static Database? _database;

  SaleDatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDate TEXT NOT NULL,
        $columnSaleRate REAL NOT NULL,
        $columnCustomer TEXT NOT NULL,
        $columnPhoneNo TEXT NOT NULL,
        $columnItemName TEXT NOT NULL,
        $columnQTY INTEGER NOT NULL,
        $columnUnit TEXT NOT NULL,
        $columnRate REAL NOT NULL,
        $columnTax REAL NOT NULL,
        $columnTotalAmt REAL NOT NULL
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
  Future<List<String>> getAllUniqueItemname() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT DISTINCT $columnItemName FROM $table');
    List<String> uniqueUnder = result.map((row) => row[columnItemName] as String).toList();

    return uniqueUnder;
  }

Future<List<Map<String, String>>> getAll() async {
  Database db = await instance.database;

  // Query the database, selecting the necessary columns
  final List<Map<String, dynamic>> result = await db.query(
    table,
    columns: [columnCustomer, columnItemName],
  );

  // Create a list to store unique customers
  Set<String> seenCustomers = Set();
  List<Map<String, String>> uniqueLedgerNames = [];

  // Loop through the result and add only unique customer-item pairs
  for (var row in result) {
    String customer = row[columnCustomer] as String;
    String itemName = row[columnItemName] as String;

    if (!seenCustomers.contains(customer)) {
      // Add this customer to the set (it will only be added once)
      seenCustomers.add(customer);

      // Add the unique customer-item pair to the list
      uniqueLedgerNames.add({
        'customer': customer,
        'item_name': itemName,
      });
    }
  }

  return uniqueLedgerNames;
}


Future<Map<String, dynamic>?> getRowById(int id) async {
  final db = await database;
  final result = await db.query(
    'salescredit_table', // Replace with your sales table name
    where: 'invoice_id = ?', // Assuming 'id' is the column name for the primary key
    whereArgs: [id],
  );
  return result.isNotEmpty ? result.first : null;
}

Future<List<Map<String, dynamic>>> queryFilteredRows({
  DateTime? fromDate, 
  DateTime? toDate, 
  String? ledgerName,
  String? customer,
  String? itemName,
}) async {
  Database db = await instance.database;

  List<String> whereClauses = [];
  List<dynamic> whereArgs = [];

  // Build the WHERE clause based on the provided filters
  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('$columnCustomer LIKE ?');
    whereArgs.add('%$ledgerName%');
  }

  if (customer != null && customer.isNotEmpty) {
    whereClauses.add('$columnCustomer = ?');
    whereArgs.add(customer);
  }

  if (fromDate != null) {
    whereClauses.add('$columnDate >= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
  }

  if (toDate != null) {
    whereClauses.add('$columnDate <= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
  }

  if (itemName != null && itemName.isNotEmpty) {
    whereClauses.add('$columnItemName = ?');
    whereArgs.add(itemName);
  }

  String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

  try {
    return await db.query(
      table,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}

  Future<List<Map<String, dynamic>>> queryFilteredRows2(String? fromDate, String? toDate, String ledgerName) async {
  Database db = await instance.database;

  String whereClause = '';
  List<dynamic> whereArgs = [];

  // Filter by ledger name if provided
  if (ledgerName.isNotEmpty) {
    whereClause = '$columnCustomer LIKE ?';
    whereArgs.add('%$ledgerName%');
  }

  // Filter by date range if both fromDate and toDate are provided
  if (fromDate != null && toDate != null) {
    if (whereClause.isNotEmpty) whereClause += ' AND ';
    whereClause += '$columnDate BETWEEN ? AND ?';
    whereArgs.add(fromDate);  // Use formatted date
    whereArgs.add(toDate);    // Use formatted date
  }

  return await db.query(
    table,
    where: whereClause.isNotEmpty ? whereClause : null,
    whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
  );
}

Future<List<int>> getAllLedgerIds() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      table,
      columns: [columnId], 
    );

    List<int> ledgerIds = result.map((row) => row[columnId] as int).toList();

    return ledgerIds;
  }
  Future<List<Map<String, dynamic>>> queryTodayRows() async {
  Database db = await instance.database;

  // Get today's date in the format stored in your database
  String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

  return await db.query(
    table,
    where: '$columnDate = ?',
    whereArgs: [today],
  );
}

}
