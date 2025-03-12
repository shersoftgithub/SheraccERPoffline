import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LedgerReportDatabaseHelper {
  static final LedgerReportDatabaseHelper instance = LedgerReportDatabaseHelper._init();
  static Database? _database;

  LedgerReportDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ledger.db');
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
      CREATE TABLE LedgerReport (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ledCode TEXT, 
          ledName TEXT, 
          date TEXT,
          particulars TEXT,
          voucher TEXT,
          entryNo INTEGER,
          debit REAL,
          credit REAL,
          balance TEXT,
          narration TEXT
      )
    ''');
  }

 Future<void> insertLedgerReport(List<Map<String, dynamic>> ledgerData) async {
  final db = await database;
  try {
    print('Inserting LedgerData: $ledgerData');

    // Loop through each item in the list and insert individually
    for (var row in ledgerData) {
      final result = await db.insert(
        'LedgerReport',
        row, 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('LedgerReport Inserted: $row');
      } else {
        print('Failed to insert LedgerReport.');
      }
    }
  } catch (e) {
    print('Error inserting into LedgerReport: $e');
  }
}


  Future<List<Map<String, dynamic>>> getLedgerReport(String ledCode) async {
    final db = await database;
    return await db.query('LedgerReport', where: 'ledCode = ?', whereArgs: [ledCode]);
  }


  Future<void> initializeLedgerTable() async {
  final db = await openDatabase(
    'ledgernew.db',
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ledger (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ledgerId INTEGER,
          entryNo TEXT,
          name TEXT,
          amount REAL,
          discount REAL,
          total REAL,
          narration TEXT,
          ddate TEXT,
          fyID INTEGER,
          frmID INTEGER
        )
      ''');
    },
  );
}

}
