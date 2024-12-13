import 'dart:io';

import 'package:sheraaccerpoff/models/paymant_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

 _initDatabase() async { 
  final directory = await getApplicationDocumentsDirectory();
  final path = join(directory.path, 'payment_form.db');

  if (File(path).existsSync()) {
    print("Database exists at: $path");
  } else {
    print("Creating new database at: $path");
  }

  return await openDatabase(
    path,
    version: 2,
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
    onOpen: (db) {
      print("Database opened successfully.");
    },
  );
}

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE payment_form (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        address TEXT,
        contactno TEXT,
        mailid TEXT,
        taxno TEXT,
        pricelevel TEXT,
        balance TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE supplier (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        suppliername TEXT
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
          print("Upgrading to version 2, creating supplier table...");

      await db.execute('''
        CREATE TABLE supplier (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          suppliername TEXT
        );
      ''');
    }
  }

  Future<int> insertPaymentForm(PaymentFormModel data) async {
    final db = await database;
    final result = await db.insert('payment_form', data.toMap());
    if (result > 0) {
      print('Affected rows = 1'); 
    } else {
      print('Insert failed, no rows affected');
    }
    return result;
  }

  Future<int> insertSupplier(SupplierModel supplier) async {
    final db = await database;
    final result = await db.insert('supplier', supplier.toMap());
    if (result > 0) {
      print('Supplier inserted: Affected rows = 1');
    } else {
      print('Insert failed, no rows affected');
    }
    return result;
  }

  Future<List<SupplierModel>> getSuppliers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('supplier');
    return List.generate(maps.length, (i) {
      return SupplierModel(
        id: maps[i]['id'],
        suppliername: maps[i]['suppliername'],
      );
    });
  }


}


