import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SyncDataServer extends StatefulWidget {
  final MssqlConnection connection;
  final String? dbName; // Receive the database name passed from ServerConfig

  // Pass the MSSQL connection instance and database name from the previous screen
  SyncDataServer({required this.connection, this.dbName});

  @override
  _SyncDataServerState createState() => _SyncDataServerState();
}

class _SyncDataServerState extends State<SyncDataServer> {
  bool isSyncing = false;
  Database? localDb;

  @override
  void initState() {
    super.initState();
    initializeLocalDb();
  }

  Future<void> initializeLocalDb() async {
    localDb = await openDatabase(
      join(await getDatabasesPath(), 'local.db'),
      version: 1,
    );
  }

Future<void> syncAllTables() async {
  if (isSyncing) return; // Prevent multiple syncs
  setState(() {
    isSyncing = true;
  });

  try {
    // Confirm the current database context
    final currentDatabase = await widget.connection.getData("SELECT DB_NAME() AS CurrentDatabase");
    print("Current database: $currentDatabase");

    // Fetch all table names from the connected database with case-insensitive collation
    final tables = await widget.connection.getData(
      "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' COLLATE Latin1_General_CI_AS"
    );

    // Check if tables is a List of Map<String, dynamic> (to safely access 'TABLE_NAME')
    if (tables is List) {
      if (tables.isNotEmpty && tables[0] is Map<String, dynamic>) {
        for (var table in tables as Iterable) {
          final tableName = table['TABLE_NAME'];

          if (tableName != null) {
            // Fetch table schema
            final columns = await widget.connection.getData(
              "SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$tableName' COLLATE Latin1_General_CI_AS",
            );

            // Create SQLite table
            String createTableQuery = "CREATE TABLE IF NOT EXISTS $tableName (";
            for (var column in columns as Iterable) {
              String columnName = column['COLUMN_NAME'];
              String columnType = mapSqlTypeToSQLite(column['DATA_TYPE']);
              createTableQuery += "$columnName $columnType, ";
            }
            createTableQuery = createTableQuery.substring(0, createTableQuery.length - 2) + ")";
            await localDb?.execute(createTableQuery);

            // Fetch data from MSSQL table
            final tableData = await widget.connection.getData("SELECT * FROM $tableName");

            // Insert data into SQLite
            await localDb?.delete(tableName); // Clear old data
            for (var row in tableData as Iterable) {
              String columns = row.keys.join(', ');
              String placeholders = row.keys.map((_) => '?').join(', ');
              List<dynamic> values = row.values.toList();

              String insertQuery = "INSERT INTO $tableName ($columns) VALUES ($placeholders)";
              await localDb?.rawInsert(insertQuery, values);
            }
          }
        }

        // Show success toast after successful synchronization
        Fluttertoast.showToast(
          msg: "Data synced successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        throw Exception("Unexpected table data format: ${tables.runtimeType}");
      }
    } else {
      throw Exception("Unexpected tables data format: ${tables.runtimeType}");
    }
  } catch (e) {
    // Show error toast
    Fluttertoast.showToast(
      msg: 'Error syncing data: $e',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } finally {
    setState(() {
      isSyncing = false;
    });
  }
}


  String mapSqlTypeToSQLite(String sqlType) {
    switch (sqlType.toLowerCase()) {
      case 'int':
        return 'INTEGER';
      case 'nvarchar':
      case 'varchar':
      case 'text':
        return 'TEXT';
      case 'datetime':
        return 'TEXT'; // Store datetime as string in SQLite
      case 'float':
      case 'decimal':
        return 'REAL';
      default:
        return 'TEXT';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sync Data Server"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Click the button below to sync data from the connected server.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSyncing ? null : syncAllTables,
              child: isSyncing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Sync Data'),
            ),
          ],
        ),
      ),
    );
  }
}
