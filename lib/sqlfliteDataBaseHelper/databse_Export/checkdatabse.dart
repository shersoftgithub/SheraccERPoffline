import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class CheckDatabaseScreen extends StatefulWidget {
  @override
  _CheckDatabaseScreenState createState() => _CheckDatabaseScreenState();
}

class _CheckDatabaseScreenState extends State<CheckDatabaseScreen> {
  late Database db;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkDatabase();
  }

  Future<void> checkDatabase() async {
    try {
      await initializeDatabase();

      // Ensure tables and columns exist
      await ensureTablesAndColumns();

      // Insert default data if necessary
      await insertDefaultData();

      // Update UI
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database checked successfully!')),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking database: $e')),
      );
    }
  }

  Future<void> initializeDatabase() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbPath = '${appDocDir.path}/SherAccERP.db';

    db = await openDatabase(dbPath, version: 1, onCreate: (db, version) {
      // Create initial tables if necessary
      db.execute('''
        CREATE TABLE IF NOT EXISTS Forms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          Form TEXT,
          Status INTEGER
        )
      ''');
      db.execute('''
        CREATE TABLE IF NOT EXISTS Form_Options (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          Form TEXT,
          Name TEXT,
          Status INTEGER
        )
      ''');
      db.execute('''
        CREATE TABLE IF NOT EXISTS General_Options (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          Name TEXT,
          Firm TEXT,
          Status INTEGER
        )
      ''');
      db.execute('''
        CREATE TABLE IF NOT EXISTS General_Settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          Name TEXT,
          Status INTEGER
        )
      ''');
    });
  }

  Future<void> ensureTablesAndColumns() async {
    // Check and add columns dynamically if they don't exist
    List<String> tables = ['Forms', 'Form_Options', 'General_Options', 'General_Settings'];

    for (String table in tables) {
      List<Map<String, dynamic>> columns = await db.rawQuery('PRAGMA table_info($table)');
      List<String> columnNames = columns.map((col) => col['name'] as String).toList();

      if (table == 'Forms' && !columnNames.contains('Form')) {
        await db.execute('ALTER TABLE $table ADD COLUMN Form TEXT');
      }

      if (table == 'Forms' && !columnNames.contains('Status')) {
        await db.execute('ALTER TABLE $table ADD COLUMN Status INTEGER');
      }
    }
  }

  Future<void> insertDefaultData() async {
    // Insert default data into Forms table if empty
    List<Map<String, dynamic>> forms = await db.query('Forms');
    if (forms.isEmpty) {
      List<String> defaultForms = ['Sale', 'Receipt', 'Ledger Report'];
      for (String form in defaultForms) {
        int state = form == 'Sale' ? 1 : 0;
        await db.insert('Forms', {'Form': form, 'Status': state});
      }
    }

    // Insert default data into General_Options table if empty
    List<Map<String, dynamic>> generalOptions = await db.query('General_Options');
    if (generalOptions.isEmpty) {
      List<String> defaultOptions = ['Option1', 'Option2', 'Option3'];
      for (String option in defaultOptions) {
        await db.insert('General_Options', {'Name': option, 'Status': 0, 'Firm': ''});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check Database')),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Text('Database is ready!'), 
      ),
    );
  }
}
