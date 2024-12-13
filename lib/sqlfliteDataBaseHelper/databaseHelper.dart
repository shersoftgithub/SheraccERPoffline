// import 'dart:async';
// import 'package:sheraaccerpoff/models/sgraccoffmodel.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class DatabaseHelper {
//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   _initDatabase() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = join(directory.path, 'sheraccoff.db');
//     return await openDatabase(path, version: 1, onCreate: _onCreate);
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE sheraccoff (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         address TEXT,
//         contactno TEXT,
//         mailid TEXT,
//         taxno TEXT,
//         pricelevel TEXT,
//         balance TEXT
//       );
//     ''');
//   }

//   Future<int> insertSheraccoff(Sheraccoff sheraccoff) async {
//     final db = await database;
//     return await db.insert('sheraccoff', sheraccoff.toMap());
//   }

//   Future<List<Sheraccoff>> getSheraccoffs() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('sheraccoff');
//     return List.generate(maps.length, (i) {
//       return Sheraccoff.fromMap(maps[i]);
//     });
//   }
// }
