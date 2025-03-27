import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart' as xml;

class LedgerTransactionsDatabaseHelper {
  static Database? _database;
  static final LedgerTransactionsDatabaseHelper _instance = LedgerTransactionsDatabaseHelper._internal();

  LedgerTransactionsDatabaseHelper._internal();
  static LedgerTransactionsDatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('ledgerTransactionsDB.db');
    return _database!;
  }

  Future<Database> _initDatabase(String dbName) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createDatabase(db);
      },
       onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 3) {
      //  await db.execute("ALTER TABLE Account_Transactions ADD COLUMN Caccount TEXT");
      //   await db.execute("ALTER TABLE Account_Transactions ADD COLUMN xmlData TEXT");
      }
  },
    );
  }

 Future<void> _createDatabase(Database db) async {
  try {
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS LedgerNames (
        Ledcode TEXT PRIMARY KEY,
        LedName TEXT,
        lh_id TEXT,
        add1 TEXT,
        add2 TEXT,
        add3 TEXT,
        add4 TEXT,
        city TEXT,
        route TEXT,
        state TEXT,
        Mobile TEXT,
        pan TEXT,
        Email TEXT,
        gstno TEXT,
        CAmount REAL,
        Active INTEGER,
        SalesMan TEXT,
        Location TEXT,
        OrderDate TEXT,
        DeliveryDate TEXT,
        CPerson TEXT,
        CostCenter TEXT,
        Franchisee TEXT,
        SalesRate REAL,
        SubGroup TEXT,
        SecondName TEXT,
        UserName TEXT,
        Password TEXT,
        CustomerType TEXT,
        OTP TEXT,
        maxDiscount REAL,
        OpeningBalance REAL,
        under TEXT,
        Debit REAL DEFAULT 0,
        date TEXT,
        balance REAL DEFAULT 0
      );
    ''');

    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS Account_Transactions (
       Auto TEXT,
        atDate TEXT,
        atLedCode TEXT,
        atType TEXT,
        atEntryno TEXT,
        atDebitAmount REAL,
        atCreditAmount REAL,
        atNarration TEXT,
        atOpposite TEXT,
        atSalesEntryno TEXT,
        atSalesType TEXT,
        atLocation TEXT,
        atChequeNo TEXT,
        atProject TEXT,
        atBankEntry TEXT,
        atInvestor TEXT,
        atFyID TEXT,
        atFxDebit TEXT,
        atFxCredit TEXT,
        atDiscount REAL,
        atNaration TEXT,
        atLedName TEXT
       
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS RV_Particulars (
        auto TEXT PRIMARY KEY,
        EntryNo TEXT,
        Name TEXT,
        Amount REAL,
        Discount REAL,
        Total REAL,
        Narration TEXT,
        ddate TEXT,
        CashAccount TEXT,
        FyID TEXT,
        FrmID TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS RV_Information (
        RealEntryNo INTEGER PRIMARY KEY AUTOINCREMENT,
        DDATE TEXT,
        AMOUNT TEXT,
        Discount REAL,
        Total REAL,
        DEBITACCOUNT TEXT,
        takeuser TEXT,
        Location INTEGER,
        Project INTEGER,
        SalesMan INTEGER,
        MonthDate TEXT,
        app INTEGER,
        Transfer_Status INTEGER,
        FyID INTEGER,
        EntryNo INTEGER,
        FrmID INTEGER,
        pviCurrency INTEGER,
        pviCurrencyValue INTEGER,
        pdate TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS FormRegistration ( 
        fmrEntryNo TEXT,
        fmrName TEXT,
        fmrTypeOfVoucher TEXT,
        fmrAbbreviation TEXT
      );
    ''');

    db.execute('''CREATE TABLE IF NOT EXISTS tmp_voucher (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        ledgername TEXT,
        amount REAL,
        discount REAL,
        total REAL,
        narration TEXT,
        ledId INTEGER,
        FyID INTEGER
      )''');

         await db.execute('''
      CREATE TABLE IF NOT EXISTS PV_Particulars (
        auto TEXT PRIMARY KEY,
        EntryNo TEXT,
        Name TEXT,
        Amount REAL,
        Discount REAL,
        Total REAL,
        Narration TEXT,
        ddate TEXT,
        CashAccount TEXT,
        FyID TEXT,
        FrmID TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS PV_Information (
        RealEntryNo INTEGER PRIMARY KEY AUTOINCREMENT,
        DDATE TEXT,
        AMOUNT REAL,
        Discount REAL,
        Total REAL,
        CreditAccount TEXT,
        takeuser TEXT,
        Location INTEGER,
        Project INTEGER,
        SalesMan INTEGER,
        MonthDate TEXT,
        app INTEGER,
        Transfer_Status INTEGER,
        FyID INTEGER,
        EntryNo INTEGER,
        FrmID INTEGER,
        pviCurrency INTEGER,
        pviCurrencyValue INTEGER,
        pdate TEXT
      );
    ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS xml_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            xml_content TEXT NOT NULL
          )
        ''');
    

    print('Tables created successfully.');
  } catch (e) {
    print('Error creating tables: $e');
    rethrow;
  }
  }

  //////////////////////////delete/////////////////////////////
  Future<void> clearledger() async {
    final db = await instance.database;
    await db.delete('LedgerNames');
  }
  Future<void> clearPvinfo() async {
    final db = await instance.database;
    await db.delete('PV_Information');
  }
  Future<void> clearPvperti() async {
    final db = await instance.database;
    await db.delete('PV_Particulars');
  }
  Future<void> clearRvinfo() async {
    final db = await instance.database;
    await db.delete('RV_Information');
  }
  Future<void> clearRvperti() async {
    final db = await instance.database;
    await db.delete('RV_Particulars');
  }

  Future<void> clearAcccTrans() async {
    final db = await instance.database;
    await db.delete('Account_Transactions');
  }




  /////////////////////////////////////////////////////////////

  Future<void> insertRVParticulars2(Map<String, dynamic> payData2) async {
  final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO RV_Particulars (
          auto, EntryNo, Name, Amount, Discount, Total, Narration, ddate, FyID, FrmID
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        payData2['auto']?.toString() ?? '',
        payData2['EntryNo']?.toString() ?? '',
        payData2['Name']?.toString() ?? '',
        payData2['Amount']?.toString() ?? '',
        payData2['Discount']?.toString() ?? '',
        payData2['Total']?.toString() ?? '',
        payData2['Narration']?.toString() ?? '',
        payData2['ddate']?.toString() ?? '',
        payData2['FyID']?.toString() ?? '',
        payData2['FrmID']?.toString() ?? '',
      ]);
    });

    print('RV_Particulars Inserted Successfully');
  } catch (e) {
    print('Error inserting payment data: $e');
  }
}

Future<void> insertRVParticulars(Map<String, dynamic> payData) async {
    final db = await database;

    try {
      print('Inserting RV_Particulars: $payData');
      final result = await db.insert(
        'RV_Particulars',
        payData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('RV_Particulars Insertion successful. Row inserted with ID: $result');
        await _insertAccountTransaction(payData);
      } else {
        print('Insertion failed. No row inserted.');
      }

    } catch (e) {
      print('Error inserting RV_Particulars: $e');
    }
  }
/////////////////////////////////////////////////////////////////
Future<void> insertRVInformation2(Map<String, dynamic> data) async {
  final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO RV_Information (
       RealEntryNo, DDATE, AMOUNT, Discount, Total, DEBITACCOUNT, takeuser, Location,Project,SalesMan,MonthDate,app,Transfer_Status,FyID,EntryNo,FrmID,pviCurrency,pviCurrencyValue,pdate 
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        data['RealEntryNo']?.toString() ?? '',
        data['DDATE']?.toString() ?? '',
        data['AMOUNT']?.toString() ?? '',
        data['Discount']?.toString() ?? '',
        data['Total']?.toString() ?? '',
        data['DEBITACCOUNT']?.toString() ?? '',
        data['takeuser']?.toString() ?? '',
        data['Location']?.toString() ?? '',
        data['Project']?.toString() ?? '',
        data['SalesMan']?.toString() ?? '',
        data['MonthDate']?.toString() ?? '',
        data['app']?.toString() ?? '',
        data['Transfer_Status']?.toString() ?? '',
        data['FyID']?.toString() ?? '',
        data['EntryNo']?.toString() ?? '',
        data['FrmID']?.toString() ?? '',
        data['pviCurrency']?.toString() ?? '',
        data['pviCurrencyValue']?.toString() ?? '',
        data['pdate']?.toString() ?? '',
      ]);
    });

    print('RV_Information Inserted Successfully');
  } catch (e) {
    print(' Error inserting payment data: $e');
  }
}
   Future<void> insertRVInformation(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'RV_Information',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('RV_Information Inserted: $data');
      } else {
        print(' Failed to insert RV_Information.');
      }
    } catch (e) {
      print(' Error inserting into RV_Information: $e');
    }
  }
   Future<void> insertFormRegistration(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'FormRegistration',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print('FormRegistration Inserted: $data');
      } else {
        print(' Failed to insert FormRegistration.');
      }
    } catch (e) {
      print(' Error inserting into FormRegistration: $e');
    }
  }

 Future<void> insertXMLData(String xmlData) async {
    final db = await database;  
    try {
     final result = await db.insert(
      'Account_Transactions',  
      {'xmlData': xmlData},  
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

      if (result > 0) {
        print('RV_Information Inserted: $xmlData');
      } else {
        print(' Failed to insert RV_Information.');
      }
    } catch (e) {
      print(' Error inserting into RV_Information: $e');
    }
  }

Future<void> _insertAccountTransaction(Map<String, dynamic> payData) async {
  final results = await Future.wait([database, LedgerTransactionsDatabaseHelper.instance.database]);

  final db = results[0];
  final db2 = results[1];

  try {
    double amount = 0.0;
    if (payData['Amount'] != null) {
      amount = double.tryParse(payData['Amount'].toString()) ?? 0.0;
    }

    print("Amount parsed: $amount");

    await db.transaction((txn) async {
      if (amount > 0) {
        await txn.rawInsert('''
          INSERT INTO Account_Transactions (
            atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
            atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
            atChequeNo, atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit
          ) 
          SELECT 
            a.ddate, a.Name, b.fmrAbbreviation, a.EntryNo, 
            0, a.Amount, a.Narration, c.DEBITACCOUNT, 0, fmrAbbreviation, c.Location, 
            '', 0, 0, 0, a.FyID, 0, a.Amount
          FROM RV_Particulars a
          JOIN FormRegistration b ON a.FrmID = b.fmrEntryNo
          JOIN RV_Information c ON a.EntryNo = c.EntryNo AND a.FyID = c.FyID AND a.FrmID = c.FrmID
          WHERE a.Amount > 0 AND a.EntryNo = ? AND a.FyID = ? AND a.FrmID = ?;
        ''', [payData['EntryNo'], payData['FyID'], payData['FrmID']]);

        print('Account Transaction inserted for Amount');

        List<Map<String, dynamic>> insertedData = await txn.rawQuery(''' 
          SELECT * FROM Account_Transactions
          WHERE atEntryno = ? AND atFyID = ? AND atSalesEntryno = ?;
        ''', [payData['EntryNo'], payData['FyID'], payData['FrmID']]);

        print('Inserted Account Transaction Data for Amount: $insertedData');

        await txn.rawInsert('''
          INSERT INTO Account_Transactions (
            atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
            atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
            atChequeNo, atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit
          ) 
          SELECT 
            a.ddate, c.DEBITACCOUNT, b.fmrAbbreviation, a.EntryNo, 
            a.Amount, 0, a.Narration, a.Name, 0, fmrAbbreviation, c.Location, 
            '', 0, 0, 0, a.FyID, 0, a.Amount
          FROM RV_Particulars a
          JOIN FormRegistration b ON a.FrmID = b.fmrEntryNo
          JOIN RV_Information c ON a.EntryNo = c.EntryNo AND a.FyID = c.FyID AND a.FrmID = c.FrmID
          WHERE a.Amount > 0 AND a.EntryNo = ? AND a.FyID = ? AND a.FrmID = ?;
        ''', [payData['EntryNo'], payData['FyID'], payData['FrmID']]);

        print('Second AccountTransaction inserted for Amount');

        List<Map<String, dynamic>> secondInsertedData = await txn.rawQuery(''' 
          SELECT * FROM Account_Transactions
          WHERE atEntryno = ? AND atFyID = ? AND atSalesEntryno = ?;
        ''', [payData['EntryNo'], payData['FyID'], payData['FrmID']]);

        print('Inserted Account Transaction Data for Amount (Second): $secondInsertedData');
      }

      if (payData['Discount'] != null) {
        double discount = double.tryParse(payData['Discount'].toString()) ?? 0.0;

        if (discount > 0) {
          await txn.rawInsert('''
            INSERT INTO Account_Transactions (
              atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
              atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
              atChequeNo, atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit
            ) 
            SELECT 
              a.ddate, a.Name, b.fmrAbbreviation, a.EntryNo, 
              a.Discount, 0, a.Narration, 
              (SELECT ledcode FROM LedgerNames WHERE LedName = 'DISCOUNT ALLOWED'), 
              0, fmrAbbreviation, c.Location, '', 0, 0, 0, a.FyID, a.Discount, 0
            FROM RV_Particulars a
            JOIN FormRegistration b ON a.FrmID = b.fmrEntryNo
            JOIN RV_Information c ON a.EntryNo = c.EntryNo AND a.FyID = c.FyID AND a.FrmID = c.FrmID
            WHERE a.Discount > 0 AND a.EntryNo = ? AND a.FyID = ? AND a.FrmID = ?;
          ''', [payData['EntryNo'], payData['FyID'], payData['FrmID']]);

          print('Account Transaction inserted for Discount');

          List<Map<String, dynamic>> discountData = await txn.rawQuery(''' 
            SELECT * FROM Account_Transactions
            WHERE atEntryno = ? AND atFyID = ? AND atSalesEntryno = ?;
          ''', [payData['EntryNo'], payData['FyID'], payData['FrmID']]);

          print('Inserted Account Transaction Data for Discount: $discountData');

          await txn.rawInsert('''
            INSERT INTO Account_Transactions (
              atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
              atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
              atChequeNo, atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit
            ) 
            SELECT 
              a.ddate, (SELECT ledcode FROM LedgerNames WHERE LedName = 'DISCOUNT ALLOWED'), 
              b.fmrAbbreviation, a.EntryNo, 
              0, a.Discount, a.Narration, a.Name, 0, fmrAbbreviation, c.Location, 
              '', 0, 0, 0, a.FyID, a.Discount, 0
            FROM RV_Particulars a
            JOIN FormRegistration b ON a.FrmID = b.fmrEntryNo
            JOIN RV_Information c ON a.EntryNo = c.EntryNo AND a.FyID = c.FyID AND a.FrmID = c.FrmID
            WHERE a.Discount > 0 AND a.EntryNo = ? AND a.FyID = ? AND a.FrmID = ?;
          ''', [payData['EntryNo'], payData['FyID'], payData['FrmID']]);

          print('Second Account Transaction inserted for Discount');

          List<Map<String, dynamic>> secondDiscountData = await txn.rawQuery(''' 
            SELECT * FROM Account_Transactions
            WHERE atEntryno = ? AND atFyID = ? AND atSalesEntryno = ?;
          ''', [payData['EntryNo'], payData['FyID'], payData['FrmID']]);

          print('Inserted AccountTransaction Data for Discount (Second): $secondDiscountData');
        }
      }
    });
  } catch (e) {
    print('Error inserting into Account_Transactions: $e');
  }
}

   Future<List<Map<String, dynamic>>> queryFilteredRowsReci({
  DateTime? fromDate, 
  DateTime? toDate, 
  String? ledgerName,
}) async {
  Database db = await instance.database;

  List<String> whereClauses = [];
  List<dynamic> whereArgs = [];
  if (fromDate != null && toDate != null) {
    String fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
    String toDateString = DateFormat('yyyy-MM-dd').format(toDate);

    whereClauses.add("DATE(ddate) BETWEEN DATE(?) AND DATE(?)");
    whereArgs.addAll([fromDateString, toDateString]);
  }
  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('Name LIKE ?');
    whereArgs.add('%$ledgerName%');
  }
  String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

  try {
    return await db.query(
      'RV_Particulars',
      where: whereClause.isNotEmpty ? whereClause : null, 
      whereArgs: whereClause.isNotEmpty ? whereArgs : null,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////PV_TABLES////////////////////////////////////////////////////
Future<void> insertPVParticulars2(Map<String, dynamic> payData2) async {
  final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO PV_Particulars (
          auto, EntryNo, Name, Amount, Discount, Total, Narration, ddate, FyID, FrmID
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        payData2['auto']?.toString() ?? '',
        payData2['EntryNo']?.toString() ?? '',
        payData2['Name']?.toString() ?? '',
        payData2['Amount']?.toString() ?? '',
        payData2['Discount']?.toString() ?? '',
        payData2['Total']?.toString() ?? '',
        payData2['Narration']?.toString() ?? '',
        payData2['ddate']?.toString() ?? '',
        payData2['FyID']?.toString() ?? '',
        payData2['FrmID']?.toString() ?? '',
      ]);
    });

    print(' PV_Particulars Inserted Successfully');
  } catch (e) {
    print(' Error inserting payment data: $e');
  }
}

 Future<void> insertPVParticulars(Map<String, dynamic> payData2) async {
    final db = await database;

    try {
      print('Inserting LedgerData: $payData2');

      final result = await db.insert(
        'PV_Particulars',
        payData2,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print(' PV_Particulars Inserted: $payData2');
        await _insertAccountTransactionPV(payData2);
      } else {
        print(' Failed to insert PV_Particulars.');
      }
    } catch (e) {
      print('Error inserting into PV_Particulars: $e');
    }
  }
  ///////////////////////////////////////////
Future<void> insertPVInformation2(Map<String, dynamic> data) async {
  final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO PV_Information (
       RealEntryNo, DDATE, AMOUNT, Discount, Total, CreditAccount, takeuser, Location,Project,SalesMan,MonthDate,app,Transfer_Status,FyID,EntryNo,FrmID,pviCurrency,pviCurrencyValue,pdate
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [ 
        data['RealEntryNo']?.toString() ?? '',
        data['DDATE']?.toString() ?? '',
        data['AMOUNT']?.toString() ?? '',
        data['Discount']?.toString() ?? '',
        data['Total']?.toString() ?? '',
        data['CreditAccount']?.toString() ?? '',
        data['takeuser']?.toString() ?? '',
        data['Location']?.toString() ?? '',
        data['Project']?.toString() ?? '',
        data['SalesMan']?.toString() ?? '',
        data['MonthDate']?.toString() ?? '',
        data['app']?.toString() ?? '',
        data['Transfer_Status']?.toString() ?? '',
        data['FyID']?.toString() ?? '',
        data['EntryNo']?.toString() ?? '',
        data['FrmID']?.toString() ?? '',
        data['pviCurrency']?.toString() ?? '',
        data['pviCurrencyValue']?.toString() ?? '',
        data['pdate']?.toString() ?? '',
      ]);
    });

    print(' Payment Data Inserted Successfully');
  } catch (e) {
    print(' Error inserting payment data: $e');
  }
}
  Future<void> insertPVInformation(Map<String, dynamic> data) async {
    final db = await database;
    try {
      final result = await db.insert(
        'PV_Information',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        print(' PV_Information Inserted: $data');
      } else {
        print(' Failed to insert PV_Information.');
      }
    } catch (e) {
      print(' Error inserting into PV_Information: $e');
    }
  }


Future<void> _insertAccountTransactionPV(Map<String, dynamic> payData2) async {
  final results = await Future.wait([database, LedgerTransactionsDatabaseHelper.instance.database]);

  final db = results[0];
  final db2 = results[1];

  try {
    double amount = 0.0;
    if (payData2['Amount'] != null) {
      amount = double.tryParse(payData2['Amount'].toString()) ?? 0.0;
    }

    print("Amount parsed: $amount");

    await db.transaction((txn) async {
      if (amount > 0) {
        await txn.rawInsert('''
          INSERT INTO Account_Transactions (
            atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
            atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
            atChequeNo, atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit
          ) 
          SELECT 
            a.ddate, a.Name, b.fmrAbbreviation, a.EntryNo, 
            0, a.Amount, a.Narration, c.CreditAccount, 0, fmrAbbreviation, c.Location, 
            '', 0, 0, 0, a.FyID, 0, a.Amount
          FROM PV_Particulars a
          JOIN FormRegistration b ON a.FrmID = b.fmrEntryNo
          JOIN PV_Information c ON a.EntryNo = c.EntryNo AND a.FyID = c.FyID AND a.FrmID = c.FrmID
          WHERE a.Amount > 0 AND a.EntryNo = ? AND a.FyID = ? AND a.FrmID = ?;
         ''', [payData2['EntryNo'], payData2['FyID'], payData2['FrmID']]);

        print('Account Transaction inserted for Amount');

        List<Map<String, dynamic>> insertedData = await txn.rawQuery(''' 
          SELECT * FROM Account_Transactions
          WHERE atEntryno = ? AND atFyID = ? AND atSalesEntryno = ?;
        ''', [payData2['EntryNo'], payData2['FyID'], payData2['FrmID']]);

        print('Inserted Account Transaction Data for Amount: $insertedData');

        await txn.rawInsert('''
          INSERT INTO Account_Transactions (
            atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
            atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
            atChequeNo, atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit
          ) 
          SELECT 
            a.ddate, c.CreditAccount, b.fmrAbbreviation, a.EntryNo, 
            a.Amount, 0, a.Narration, a.Name, 0, fmrAbbreviation, c.Location, 
            '', 0, 0, 0, a.FyID, 0, a.Amount
          FROM PV_Particulars a
          JOIN FormRegistration b ON a.FrmID = b.fmrEntryNo
          JOIN PV_Information c ON a.EntryNo = c.EntryNo AND a.FyID = c.FyID AND a.FrmID = c.FrmID
          WHERE a.Amount > 0 AND a.EntryNo = ? AND a.FyID = ? AND a.FrmID = ?;
        ''', [payData2['EntryNo'], payData2['FyID'], payData2['FrmID']]);

        print('Second Account Transaction inserted for Amount');

        List<Map<String, dynamic>> secondInsertedData = await txn.rawQuery(''' 
          SELECT * FROM Account_Transactions
          WHERE atEntryno = ? AND atFyID = ? AND atSalesEntryno = ?;
        ''', [payData2['EntryNo'], payData2['FyID'], payData2['FrmID']]);

        print('Inserted Account Transaction Data for Amount (Second): $secondInsertedData');
      }

      if (payData2['Discount'] != null) {
        double discount = double.tryParse(payData2['Discount'].toString()) ?? 0.0;

        if (discount > 0) {
          await txn.rawInsert('''
            INSERT INTO Account_Transactions (
              atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
              atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
              atChequeNo, atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit
            ) 
            SELECT 
              a.ddate, a.Name, b.fmrAbbreviation, a.EntryNo, 
              a.Discount, 0, a.Narration, 
              (SELECT ledcode FROM LedgerNames WHERE LedName = 'DISCOUNT ALLOWED'), 
              0, fmrAbbreviation, c.Location, '', 0, 0, 0, a.FyID, a.Discount, 0
            FROM PV_Particulars a
            JOIN FormRegistration b ON a.FrmID = b.fmrEntryNo
            JOIN PV_Information c ON a.EntryNo = c.EntryNo AND a.FyID = c.FyID AND a.FrmID = c.FrmID
            WHERE a.Discount > 0 AND a.EntryNo = ? AND a.FyID = ? AND a.FrmID = ?;
          ''', [payData2['EntryNo'], payData2['FyID'], payData2['FrmID']]);

          print('Account Transaction inserted for Discount');

          List<Map<String, dynamic>> discountData = await txn.rawQuery(''' 
            SELECT * FROM Account_Transactions
            WHERE atEntryno = ? AND atFyID = ? AND atSalesEntryno = ?;
          ''', [payData2['EntryNo'], payData2['FyID'], payData2['FrmID']]);

          print('Inserted Account Transaction Data for Discount: $discountData');

          await txn.rawInsert('''
            INSERT INTO Account_Transactions (
              atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
              atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
              atChequeNo, atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit
            ) 
            SELECT 
              a.ddate, (SELECT ledcode FROM LedgerNames WHERE LedName = 'DISCOUNT ALLOWED'), 
              b.fmrAbbreviation, a.EntryNo, 
              0, a.Discount, a.Narration, a.Name, 0, fmrAbbreviation, c.Location, 
              '', 0, 0, 0, a.FyID, a.Discount, 0
            FROM PV_Particulars a
            JOIN FormRegistration b ON a.FrmID = b.fmrEntryNo
            JOIN PV_Information c ON a.EntryNo = c.EntryNo AND a.FyID = c.FyID AND a.FrmID = c.FrmID
            WHERE a.Discount > 0 AND a.EntryNo = ? AND a.FyID = ? AND a.FrmID = ?;
          ''', [payData2['EntryNo'], payData2['FyID'], payData2['FrmID']]);

          print('Second Account Transaction inserted for Discount');

          List<Map<String, dynamic>> secondDiscountData = await txn.rawQuery(''' 
            SELECT * FROM Account_Transactions
            WHERE atEntryno = ? AND atFyID = ? AND atSalesEntryno = ?;
          ''', [payData2['EntryNo'], payData2['FyID'], payData2['FrmID']]);

          print('Inserted Account Transaction Data for Discount (Second): $secondDiscountData');
        }
      }
    });
  } catch (e) {
    print('Error inserting into Account_Transactions: $e');
  }
}

  Future<List<Map<String, dynamic>>> queryFilteredRowsPV({
  DateTime? fromDate, 
  DateTime? toDate, 
  String? ledgerName,
}) async {
  Database db = await instance.database;

  List<String> whereClauses = [];
  List<dynamic> whereArgs = [];

  if (fromDate != null && toDate != null) {
    String fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
    String toDateString = DateFormat('yyyy-MM-dd').format(toDate);

    whereClauses.add("DATE(ddate) BETWEEN DATE(?) AND DATE(?)");
    whereArgs.addAll([fromDateString, toDateString]);
  }

  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('Name LIKE ?');
    whereArgs.add('%$ledgerName%');
  }

  String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

  try {
    return await db.query(
      'PV_Particulars',
      where: whereClause.isNotEmpty ? whereClause : null, 
      whereArgs: whereClause.isNotEmpty ? whereArgs : null,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
///

Future<void> inserttmp_voucher(Map<String, dynamic> payData) async {
  final db = await database;

  try {
    print('Inserting LedgerData: $payData');

    final result = await db.insert(
      'tmp_voucher',
      payData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('Insertion successful. Row inserted with ID: $result');
    } else {
      print('Insertion failed. No row inserted.');
    }

    final checkResult = await db.query(
      'tmp_voucher',
      where: 'id = ?',
      whereArgs: [payData['id']],
    );

    if (checkResult.isNotEmpty) {
      print('Data successfully inserted: ${checkResult.first}');
    } else {
      print('Data insertion was unsuccessful. Unable to find the inserted record.');
    }
  } catch (e) {
    print('Error inserting ledger data: $e');
  }
}



 Future<void> insertTransactionData({
    required String atDate,
    required String atLedCode,
    required String atType,
    required int atEntryno,
    required double atDebitAmount,
    required double atCreditAmount,
    required String atNarration,
    required String atOpposite,
    required String atSalesType,
    required String atLocation,
    required String atChequeNo,
    required String atProject,
    required int atFyID,
    required double atFxDebit,
    required double atFxCredit,
  }) async {
    final db = await database;

    await db.insert(
      'Account_Transactions',
      {
        'atDate': atDate,
        'atLedCode': atLedCode,
        'atType': atType,
        'atEntryno': atEntryno,
        'atDebitAmount': atDebitAmount,
        'atCreditAmount': atCreditAmount,
        'atNarration': atNarration,
        'atOpposite': atOpposite,
        'atSalesEntryno': atEntryno,  
        'atSalesType': atSalesType,
        'atLocation': atLocation,
        'atChequeNo': atChequeNo,
        'atProject': atProject,
        'atBankEntry': 0, 
        'atInvestor': 0,  
        'atFyID': atFyID,
        'atFxDebit': atFxDebit,
        'atFxCredit': atFxCredit,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }




Future<void> insertAccTrans(Map<String, dynamic> newTableData) async {
  final db = await database;

  try {
    final List<Map<String, dynamic>> lastRecord = await db.rawQuery(
      "SELECT Auto FROM Account_Transactions ORDER BY CAST(Auto AS INTEGER) DESC LIMIT 1"
    );

    int newAuto = 1; 
    if (lastRecord.isNotEmpty && lastRecord.first['Auto'] != null) {
      newAuto = (int.tryParse(lastRecord.first['Auto'].toString()) ?? 0) + 1;
    }

    newTableData['Auto'] = newAuto.toString();

    await db.insert('Account_Transactions', newTableData, conflictAlgorithm: ConflictAlgorithm.replace);
    
    print('Transaction inserted successfully with Auto: $newAuto');

    await insertLedgerData({
      'Ledcode': newTableData['atLedCode'],
      'LedName': newTableData['atLedName'],
      'balance': newTableData['atDebitAmount'] - newTableData['atCreditAmount'],
    });

    await syncAccountTransactionsToMSSQL(newTableData);

  } catch (e) {
    print('Error inserting transaction: $e');
  }
}
Future<void> insertLedgerData2(Map<String, dynamic> data) async {
  final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO LedgerNames (
        Ledcode,
        LedName ,
        lh_id ,
        add1 ,
        add2 ,
        add3 ,
        add4 ,
        city,
        route ,
        state ,
        Mobile,
        pan ,
        Email ,
        gstno ,
        CAmount ,
        Active ,
        SalesMan ,
        Location ,
        OrderDate ,
        DeliveryDate ,
        CPerson ,
        CostCenter ,
        Franchisee ,
        SalesRate ,
        SubGroup ,
        SecondName ,
        UserName,
        Password ,
        CustomerType,
        OTP ,
        maxDiscount  
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,? ,? , ? ,? , ?, ?, ? ,? ,?,?,?)
      ''', [
        data['Ledcode']?.toString() ?? '',
        data['LedName']?.toString() ?? '',
        data['lh_id']?.toString() ?? '',
        data['add1']?.toString() ?? '',
        data['add2']?.toString() ?? '',
        data['add3']?.toString() ?? '',
        data['add4']?.toString() ?? '',
        data['city']?.toString() ?? '',
        data['route']?.toString() ?? '',
        data['state']?.toString() ?? '',
        data['Mobile']?.toString() ?? '',
        data['pan']?.toString() ?? '',
        data['Email']?.toString() ?? '',
        data['gstno']?.toString() ?? '',
        data['CAmount']?.toString() ?? '',
        data['Active']?.toString() ?? '',
        data['SalesMan']?.toString() ?? '',
        data['Location']?.toString() ?? '',
        data['OrderDate']?.toString() ?? '',
        data['DeliveryDate']?.toString() ?? '',
        data['CPerson']?.toString() ?? '',
        data['CostCenter']?.toString() ?? '',
        data['Franchisee']?.toString() ?? '',
        data['SalesRate']?.toString() ?? '',
        data['SubGroup']?.toString() ?? '',
        data['SecondName']?.toString() ?? '',
        data['UserName']?.toString() ?? '',
        data['Password']?.toString() ?? '',
        data['OTP']?.toString() ?? '',
        data['maxDiscount']?.toString() ?? '',
      ]);
    });

    print('LedgerNames Inserted Successfully');
  } catch (e) {
    print('Error inserting LedgerNames data: $e');
  }
}
Future<void> insertLedgerData(Map<String, dynamic> ledgerData) async {
  final db = await database;

  try {
    print('Inserting LedgerData: $ledgerData');

    final result = await db.insert(
      'LedgerNames',
      ledgerData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('Insertion successful. Row inserted with ID: $result');
    } else {
      print('Insertion failed. No row inserted.');
    }
    final checkResult = await db.query(
      'LedgerNames',
      where: 'Ledcode = ?',
      whereArgs: [ledgerData['Ledcode']],
    );

    if (checkResult.isNotEmpty) {
      print('Data successfully inserted: ${checkResult.first}');
    } else {
      print('Data insertion was unsuccessful. Unable to find the inserted record.');
    }
  } catch (e) {
    print('Error inserting ledger data: $e');
  }
}

Future<void> insertData2(Map<String, dynamic> data ) async {
 final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO Account_Transactions (
       Auto, atDate, atLedCode, atType, atEntryno,
        atDebitAmount, atCreditAmount, atNarration, atOpposite, 
        atSalesEntryno, atSalesType, atLocation, atChequeNo, 
        atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        data['Auto'] ?? '',
        data['atDate'] ?? '',
        data['atLedCode'] ?? '',
        data['atType'] ?? '',
        data['atEntryno'] ?? '',
        data['atDebitAmount'] ?? 0.0,
        data['atCreditAmount'] ?? 0.0,
        data['atNarration'] ?? '',
        data['atOpposite'] ?? '',
        data['atSalesEntryno'] ?? '',
        data['atSalesType'] ?? '',
        data['atLocation'] ?? '',
        data['atChequeNo'] ?? '',
        data['atProject'] ?? '',
        data['atBankEntry'] ?? '',
        data['atInvestor'] ?? '',
        data['atFyID'] ?? '',
        data['atFxDebit'] ?? '',
        data['atFxCredit'] ?? '',
      ]);
    });

    print('Account_Transactions Inserted Successfully');
  } catch (e) {
    print('Error inserting Account_Transactions data: $e');
  }
}

Future<void> insertData(List<Map<String, dynamic>> data) async {
  final db = await database;

  await db.rawQuery("PRAGMA synchronous = OFF");  
  await db.rawQuery("PRAGMA journal_mode = WAL"); 
  await db.rawQuery("PRAGMA temp_store = MEMORY"); 
  await db.transaction((txn) async {
    StringBuffer sql = StringBuffer('INSERT OR IGNORE INTO Account_Transactions ('
        'Auto, atDate, atLedCode, atType, atEntryno, '
        'atDebitAmount, atCreditAmount, atNarration, atOpposite, '
        'atSalesEntryno, atSalesType, atLocation, atChequeNo, '
        'atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit'
        ') VALUES ');

    List<String> valueRows = [];
    List<dynamic> args = [];

    for (final row in data) {
      valueRows.add("(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
      args.addAll([
        row['Auto'] ?? '',
        row['atDate'] ?? '',
        row['atLedCode'] ?? '',
        row['atType'] ?? '',
        row['atEntryno'] ?? '',
        row['atDebitAmount'] ?? 0.0,
        row['atCreditAmount'] ?? 0.0,
        row['atNarration'] ?? '',
        row['atOpposite'] ?? '',
        row['atSalesEntryno'] ?? '',
        row['atSalesType'] ?? '',
        row['atLocation'] ?? '',
        row['atChequeNo'] ?? '',
        row['atProject'] ?? '',
        row['atBankEntry'] ?? '',
        row['atInvestor'] ?? '',
        row['atFyID'] ?? '',
        row['atFxDebit'] ?? '',
        row['atFxCredit'] ?? '',
      ]);

      if (valueRows.length >= 500) {
        sql.write(valueRows.join(","));
        await txn.rawInsert(sql.toString(), args);

        sql = StringBuffer('INSERT OR IGNORE INTO Account_Transactions ('
            'Auto, atDate, atLedCode, atType, atEntryno, '
            'atDebitAmount, atCreditAmount, atNarration, atOpposite, '
            'atSalesEntryno, atSalesType, atLocation, atChequeNo, '
            'atProject, atBankEntry, atInvestor, atFyID, atFxDebit, atFxCredit'
            ') VALUES ');
        valueRows.clear();
        args.clear();
      }
    }

    if (valueRows.isNotEmpty) {
      sql.write(valueRows.join(","));
      await txn.rawInsert(sql.toString(), args);
    }
  });

  int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Account_Transactions')) ?? 0;
  print(' Total rows inserted: $count');
}



Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('Account_Transactions');
  }
Future<int> getRowCount() async {
    final db = await database;
    try {
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM Account_Transactions'));
      print('SQLite Row Count: $count');
      return count ?? 0;
    } catch (e) {
      print('Error fetching row count: $e');
      return 0;
    }
  }
  Future<List<Map<String, dynamic>>> getFilteredAccTrans(String atType) async {
    final db = await database; 
    return await db.query(
      'Account_Transactions', 
      where: 'atType = ?', 
      whereArgs: [atType],
    );
  }

Future<List<Map<String, dynamic>>> queryFilteredRows({
  required DateTime fromDate, 
  required DateTime toDate, 
  String? ledgerName,
}) async {
  Database db = await instance.database;

  List<String> whereClauses = ['atType = ?'];
  List<dynamic> whereArgs = ['RECEIPT'];

  String fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
  String toDateString = DateFormat('yyyy-MM-dd ').format(toDate);

  whereClauses.add("datetime(atDate) BETWEEN datetime(?) AND datetime(?)");
  whereArgs.addAll([fromDateString, toDateString]);

  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('atLedName LIKE ?');
    whereArgs.add('%$ledgerName%');
  }

  String whereClause = whereClauses.join(' AND ');

  try {
    return await db.query(
      'Account_Transactions',
      where: whereClause,
      whereArgs: whereArgs,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> queryFilteredRowsPay({
  DateTime? fromDate, 
  DateTime? toDate, 
  String? ledgerName,
}) async {
  Database db = await instance.database;

  List<String> whereClauses = ['atType = ?'];
  List<dynamic> whereArgs = ['PAYMENT'];

  String fromDateString = DateFormat('yyyy-MM-dd').format(fromDate!);
  String toDateString = DateFormat('yyyy-MM-dd ').format(toDate!);

  whereClauses.add("datetime(atDate) BETWEEN datetime(?) AND datetime(?)");
  whereArgs.addAll([fromDateString, toDateString]);

  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('atLedName LIKE ?');
    whereArgs.add('%$ledgerName%');
  }

  String whereClause = whereClauses.join(' AND ');

  try {
    return await db.query(
      'Account_Transactions',
      where: whereClause,
      whereArgs: whereArgs,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}


Future<void> enableWALMode() async {
    final db = await database;
    try {
      await db.execute('PRAGMA journal_mode=WAL;');
      print('WAL mode enabled.');
    } catch (e) {
      print('Error enabling WAL mode: $e');
    }
  }

Future<double> getOpeningBalanceForLedger(String ledgerName) async {
  final db = await database;
  var result = await db.rawQuery(''' 
    SELECT SUM(atDebitAmount) as OpeningBalance 
    FROM Account_Transactions 
    WHERE atLedName = ? 
  ''', [ledgerName]);

  if (result.isNotEmpty && result.first['OpeningBalance'] != null) {
    return (result.first['OpeningBalance'] as num).toDouble(); 
  } else {
    return 0.0;
  }
}
Future<double> getDebitAmountForLedger(String ledgerName) async {
  final db = await database;  

  var result = await db.rawQuery(
    'SELECT SUM(atDebitAmount) FROM Account_Transactions WHERE atLedName = ?',
    [ledgerName],
  );

  if (result.isNotEmpty && result.first['SUM(atDebitAmount)'] != null) {
    return result.first['SUM(atDebitAmount)'] as double? ?? 0.0;
  } else {
    return 0.0;
  }
  
}


Future<double> getOpeningBalance(String ledgerName) async {
  final db = await database; 
  final List<Map<String, dynamic>> result = await db.query(
    'LedgerNames', 
    columns: ['OpeningBalance'],
    where: 'LedName = ?',
    whereArgs: [ledgerName],
  );

  if (result.isNotEmpty && result.first['OpeningBalance'] != null) {
    return double.tryParse(result.first['OpeningBalance'].toString()) ?? 0.0;
  } else {
    return 0.0; 
  }
}





  ////////////////////////ledger names table functions ///////////////////
  

  Future<List<Map<String, dynamic>>> getLedgersWithTransactions() async {
    final db = await database;  
    final result = await db.rawQuery('SELECT * FROM LedgerWithTransactions');
    return result;
  }
  
  Future<List<String>> getAllNames() async {
    final db = await instance.database;
    final result = await db.query('LedgerNames', columns: ['LedName']);
    return result.map((item) => item['LedName'] as String).toList();
  }

  Future<Map<String, dynamic>?> getLedgerDetailsByName(String ledgerName) async {
    final db = await instance.database;
    final result = await db.query(
      'LedgerNames',
      columns: ['Ledcode AS LedId', 'Mobile','OpeningBalance','add1','add2','add3','add4'],
      where: 'LedName = ?',
      whereArgs: [ledgerName],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
Future<List<Map<String, dynamic>>> fetchLedgerCodesAndNames() async {
  final db = await database;
  try {
    return await db.query(
      'LedgerNames',
      columns: ['Ledcode', 'LedName'], 
    );
  } catch (e) {
    print('Error fetching Ledcode and LedName: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> queryFilteredRowsledger({
  DateTime? fromDate, 
  DateTime? toDate, 
  String? ledgerName,
  
}) async {
  Database db = await instance.database;

  List<String> whereClauses = [];
  List<dynamic> whereArgs = [];

  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add('LedName LIKE ?');
    whereArgs.add('%$ledgerName%');
  }


  if (fromDate != null) {     
    whereClauses.add('date >= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
  }

  if (toDate != null) {
    whereClauses.add('date <= ?');
    whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
  }



  String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

  try {
    return await db.query(
      'LedgerNames',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}
  Future<List<Map<String, dynamic>>> getAccTrans() async {
    final db = await database;
    final result = await db.query('account_Transactions');

    return result;
  }

   Future<List<Map<String, dynamic>>> getLedgerData() async {
    final db = await database;
    final result = await db.query('LedgerNames');

    return result.map((row) {
      if (row['Photo'] != null) {
        row['Photo'] = row['Photo'] as Uint8List;
      }
      return row;
    }).toList();
  }
  Future<List<Map<String, dynamic>>> getFilteredAccountTransactions(String atType) async {
    final db = await database;
    return await db.query(
      'Account_Transactions',
      where: 'atType = ?',
      whereArgs: [atType],
    );
  }

  Future<List<Map<String, dynamic>>> getAccountTransactionsByLedgerCode(String ledgerCode) async {
    final db = await database;
    return await db.query(
      'Account_Transactions',
      where: 'atLedCode = ?',
      whereArgs: [ledgerCode],
    );
  }

  Future<void> updateLedgerBalance(String ledgerCode, double newBalance) async {
    final db = await database;
    await db.update(
      'LedgerNames',
      {'OpeningBalance': newBalance},
      where: 'Ledcode = ?',
      whereArgs: [ledgerCode],
    );
  }

  Future<void> updatePaymentBalance(String ledgerCode, double total, double amt, double newBalance) async {
    final db = await database;
    await db.update(
      'Account_Transactions',
      {'atDebitAmount': newBalance, 'atCreditAmount': total, 'atDebitAmount': amt},
      where: 'atLedCode = ?',
      whereArgs: [ledgerCode],
    );
  }

  Future<List<Map<String, dynamic>>> queryFilteredLedgerRows({
    DateTime? fromDate,
    DateTime? toDate,
    String? ledgerName,
  }) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (ledgerName != null && ledgerName.isNotEmpty) {
      whereClauses.add('LedName LIKE ?');
      whereArgs.add('%$ledgerName%');
    }

    if (fromDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(DateFormat('dd-MM-yyyy').format(fromDate));
    }

    if (toDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(DateFormat('dd-MM-yyyy').format(toDate));
    }

    String whereClause = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

    try {
      return await db.query(
        'LedgerNames',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );
    } catch (e) {
      print("Error fetching filtered data: $e");
      rethrow;
    }
  }

  Future<void> insertOrUpdateLedgerData(Map<String, dynamic> ledgerData) async {
    final db = await database;
    await db.insert(
      'LedgerNames',
      ledgerData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
   Future<bool> _doesColumnExist(Database db, String tableName, String columnName) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }

  Future<void> updateOpeningBalances() async {
  final db = await database;

  try {
    final ledgerCodes = await db.rawQuery(
      '''
      SELECT DISTINCT atLedCode 
      FROM Account_Transactions 
      WHERE atLedCode IS NOT NULL AND atLedCode != ""
      '''
    );

    if (ledgerCodes.isEmpty) {
      print('No valid ledger codes found in Account_Transactions table.');
      return;
    }

    for (var ledger in ledgerCodes) {
      final ledgerCode = ledger['atLedCode'];

      final result = await db.rawQuery(
        '''
        SELECT 
          COALESCE(SUM(atCreditAmount), 0) AS totalCredits,
          COALESCE(SUM(atDebitAmount), 0) AS totalDebits
        FROM Account_Transactions
        WHERE atLedCode = ?
        ''',
        [ledgerCode],
      );

      final totalCredits = (result.first['totalCredits'] as num).toDouble();
      final totalDebits = (result.first['totalDebits'] as num).toDouble();
      final openingBalance = (totalCredits - totalDebits).abs();

      final ledgerExists = await db.query(
        'LedgerNames',
        columns: ['Ledcode'],
        where: 'Ledcode = ?',
        whereArgs: [ledgerCode],
      );

      if (ledgerExists.isNotEmpty) {
        await db.update(
          'LedgerNames',
          {'OpeningBalance': openingBalance},
          where: 'Ledcode = ?',
          whereArgs: [ledgerCode],
        );

        print('Updated ledger $ledgerCode with opening balance: $openingBalance');
      } else {
        print('Ledger $ledgerCode does not exist in LedgerNames table.');
      }
    }

    print('Opening balances updated successfully.');
  } catch (e) {
    print('Error updating opening balances: $e');
  }
}
Future<void> insertDataIntoSQLite(List<Map<String, dynamic>> data) async {
  final database = await openDatabase('ledgerTransactionsDB.db');

  for (final row in data) {
    await database.insert(
      'Account_Transactions',
      {
        'Auto': row['Auto']?.toString() ?? '',
    'atDate': row['atDate']?.toString() ?? '',
    'atLedCode': row['atLedCode']?.toString() ?? '', 
      'atType': row['atType']?.toString() ?? '',
    'atEntryno': row['atEntryno']?.toString() ?? '', 
    'atDebitAmount': row['atDebitAmount'] != null ? row['atDebitAmount'] : 0.0, 
    'atCreditAmount': row['atCreditAmount'] != null ? row['atCreditAmount'] : 0.0, 
     'atNarration': row['atNarration']?.toString() ?? '',
    'atOpposite': row['atOpposite']?.toString() ?? '',     
    'atSalesEntryno': row['atSalesEntryno']?.toString() ?? '',
    'atSalesType': row['atSalesType']?.toString() ?? 'Default SalesType',
    'atLocation': row['atLocation']?.toString() ?? '',
    'atChequeNo': row['atChequeNo']?.toString() ?? '',
    'atProject': row['atProject']?.toString() ?? '',
    'atBankEntry': row['atBankEntry']?.toString() ?? '',
    'atInvestor': row['atInvestor']?.toString() ?? '',
    'atFyID': row['atFyID']?.toString() ?? '',
    'atFxDebit': row['atFxDebit']?.toString() ?? '',
    'atFxCredit': row['atFxCredit']?.toString() ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  print('Data inserted successfully into SQLite.');
}

Future<List<Map<String, dynamic>>> fetchSQLiteData() async {
  final db = await getDatabase(); 
  return await db.query('LedgerNames');
}
Future<Database> getDatabase() async {
  return database;
}
Future<void> fetchDataFromMSSQLCompany() async {
  try {
    final query =
        'SELECT Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state, Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location, OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate, SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount FROM LedgerNames';
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);
      if (decodedData is List) {
        final records = decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        final db = await getDatabase(); 
        for (var record in records) {
          await db.insert(
            'LedgerNames',
            record,
            conflictAlgorithm: ConflictAlgorithm.replace, 
          );
        }
        print('Data synchronized to SQLite successfully.');
      } else {
        throw Exception('Unexpected JSON format for LedgerNames data: $decodedData');
      }
    } else {
      throw Exception('Unexpected data format for LedgerNames: $rawData');
    }
  } catch (e) {
    print('Error fetching and syncing data: $e');
    rethrow;
  }
}

Future<void> fetchAndInsertIntoSQLite() async {
  final dbHelper = LedgerTransactionsDatabaseHelper.instance;

  try {
    final List<Map<String, dynamic>> fetchedData = await fetchDataFromMSSQLAccTransations();

    if (fetchedData.isEmpty) {
      print('No data fetched from MSSQL.');
      return;
    }
    await dbHelper.insertOrUpdateLedgerDataInSQLite(fetchedData);

    print('Fetched and inserted data from MSSQL to SQLite.');
  } catch (e) {
    print('Error in fetchAndInsertIntoSQLite: $e');
  }
}

Future<void> insertOrUpdateLedgerDataInSQLite(List<Map<String, dynamic>> ledgerDataList) async {
  final db = await database;

  for (var ledgerData in ledgerDataList) {
    final result = await db.insert(
      'LedgerNames', 
      ledgerData,
      conflictAlgorithm: ConflictAlgorithm.replace, 
    );

    if (result > 0) {
      print('Ledger data inserted or updated successfully.');
    } else {
      print('Failed to insert/update ledger data.');
    }
  }
}


Future<void> syncLedgerNamesToMSSQL() async {
  final db = await database;
  final modifiedData = await db.query('LedgerNames'); 
  final modifiedData2 = await db.query('Account_Transactions');
  for (var data in modifiedData) {
  
    final ledgerCode = data['Ledcode'];
        await updateMSSQLLedger(data);
  }
  for (var data in modifiedData2) {
  
    final atledgerCode = data['Auto'];
        await syncAccountTransactionsToMSSQL(data);
  }
}

Future<void> updateMSSQLLedger(Map<String, dynamic> ledgerData) async {
  try {
    if (ledgerData['Ledcode'] == null || ledgerData['Ledcode'].toString().trim().isEmpty) {
      throw Exception('Ledcode is required and cannot be null or empty');
    }
    if (ledgerData['LedName'] == null || ledgerData['LedName'].toString().trim().isEmpty) {
      throw Exception('LedName is required and cannot be null or empty');
    }
    String escapeString(String? value) {
      return value != null ? "'${value.replaceAll("'", "''")}'" : "NULL";
    }

    final ledcode = ledgerData['Ledcode'];
    final ledName = escapeString(ledgerData['LedName']);
    final lhId = ledgerData['lh_id'] ?? 0;
    final add1 = escapeString(ledgerData['add1']);
    final add2 = escapeString(ledgerData['add2']);
    final add3 = escapeString(ledgerData['add3']);
    final add4 = escapeString(ledgerData['add4']);
    final city = escapeString(ledgerData['city']);
    final route = escapeString(ledgerData['route']);
    final state = escapeString(ledgerData['state']);
    final mobile = escapeString(ledgerData['Mobile']);
    final pan = escapeString(ledgerData['pan']);
    final email = escapeString(ledgerData['Email']);
    final gstno = escapeString(ledgerData['gstno']);
    final cAmount = ledgerData['CAmount'] ?? 0.0;
    final active = (ledgerData['Active'] == true) ? 1 : 0; 
    final salesMan = escapeString(ledgerData['SalesMan']);
    final location = escapeString(ledgerData['Location']);
    final orderDate = escapeString(ledgerData['OrderDate']);
    final deliveryDate = escapeString(ledgerData['DeliveryDate']);
    final cPerson = escapeString(ledgerData['CPerson']);
    final costCenter = escapeString(ledgerData['CostCenter']);
    final franchisee = escapeString(ledgerData['Franchisee']);
    final salesRate = ledgerData['SalesRate'] ?? 0.0;
    final subGroup = escapeString(ledgerData['SubGroup']);
    final secondName = escapeString(ledgerData['SecondName']);
    final userName = escapeString(ledgerData['UserName']);
    final password = escapeString(ledgerData['Password']);
    final customerType = escapeString(ledgerData['CustomerType']);
    final otp = escapeString(ledgerData['OTP']);
    final maxDiscount = ledgerData['maxDiscount'] ?? 0.0;

   final query = '''
  SET IDENTITY_INSERT LedgerNames ON;

  MERGE INTO LedgerNames AS target
  USING (VALUES (
    '$ledcode', $ledName, $lhId, $add1, $add2, $add3, $add4, $city, $route, $state,
    $mobile, $pan, $email, $gstno, $cAmount, $active, $salesMan, $location,
    $orderDate, $deliveryDate, $cPerson, $costCenter, $franchisee, $salesRate,
    $subGroup, $secondName, $userName, $password, $customerType, $otp, $maxDiscount
  )) 
  AS source (
    Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state,
    Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location,
    OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate,
    SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount
  )
  ON target.Ledcode = source.Ledcode
  WHEN MATCHED THEN
    UPDATE SET
      LedName = source.LedName, lh_id = source.lh_id, add1 = source.add1,
      add2 = source.add2, add3 = source.add3, add4 = source.add4, city = source.city,
      route = source.route, state = source.state, Mobile = source.Mobile, pan = source.pan,
      Email = source.Email, gstno = source.gstno, CAmount = source.CAmount,
      Active = source.Active, SalesMan = source.SalesMan, Location = source.Location,
      OrderDate = source.OrderDate, DeliveryDate = source.DeliveryDate,
      CPerson = source.CPerson, CostCenter = source.CostCenter, Franchisee = source.Franchisee,
      SalesRate = source.SalesRate, SubGroup = source.SubGroup, SecondName = source.SecondName,
      UserName = source.UserName, Password = source.Password, CustomerType = source.CustomerType,
      OTP = source.OTP, maxDiscount = source.maxDiscount
  WHEN NOT MATCHED THEN
    INSERT (
      Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state,
      Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location,
      OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate,
      SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount
    )
    VALUES (
      source.Ledcode, source.LedName, source.lh_id, source.add1, source.add2, source.add3,
      source.add4, source.city, source.route, source.state, source.Mobile, source.pan,
      source.Email, source.gstno, source.CAmount, source.Active, source.SalesMan, source.Location,
      source.OrderDate, source.DeliveryDate, source.CPerson, source.CostCenter, source.Franchisee,
      source.SalesRate, source.SubGroup, source.SecondName, source.UserName, source.Password,
      source.CustomerType, source.OTP, source.maxDiscount
    );

  SET IDENTITY_INSERT LedgerNames OFF;
''';

    print('Executing SQL query: $query');
    final result = await MsSQLConnectionPlatform.instance!.writeData(query);
    if (result != null) {
      print('Query executed successfully: $result');
    } else {
      throw Exception('Query execution failed with null result');
    }
  } catch (e) {
    print('Error executing query: $e');
  }
}

Future<void> syncAccountTransactionsToMSSQL(Map<String, dynamic> transaction) async {
  try {
    var auto = transaction['Auto'];
    if (auto == null || auto.toString().trim().isEmpty) {
      throw Exception('Auto is required for updates.');
    }

    final autoValue = int.tryParse(auto.toString());
    if (autoValue == null) {
      throw Exception('Invalid Auto value: $auto. It must be numeric.');
    }

    String escapeString(String? value) {
      return value != null && value.isNotEmpty ? "'${value.replaceAll("'", "''")}'" : "NULL";
    }

    num? parseNumber(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) return null;
      return num.tryParse(value.toString());
    }
    final atDate = escapeString(transaction['atDate']);
    final atLedCode = escapeString(transaction['atLedCode']);
    final atType = escapeString(transaction['atType']);
    final atEntryno = transaction['atEntryno'] != null ? "'${transaction['atEntryno']}'" : "NULL";
    final atDebitAmount = parseNumber(transaction['atDebitAmount']) ?? 0;
    final atCreditAmount = parseNumber(transaction['atCreditAmount']) ?? 0;
    final atNarration = escapeString(transaction['atNarration']);
    final atOpposite = escapeString(transaction['atOpposite']);
    final atSalesEntryno = escapeString(transaction['atSalesEntryno']);
    final atSalesType = escapeString(transaction['atSalesType']);
    final atLocation = escapeString(transaction['atLocation']);
    final atChequeNo = escapeString(transaction['atChequeNo']);
    final atProject = escapeString(transaction['atProject']);
    final atBankEntry = escapeString(transaction['atBankEntry']);
    final atInvestor = escapeString(transaction['atInvestor']);
    final atFyID = escapeString(transaction['atFyID']);
    final atFxDebit = parseNumber(transaction['atFxDebit']) ?? 0;
    final atFxCredit = parseNumber(transaction['atFxCredit']) ?? 0;

    final query = '''
    SET IDENTITY_INSERT Account_Transactions ON;

    MERGE INTO Account_Transactions AS target
    USING (SELECT 
      $autoValue AS Auto, $atDate AS atDate, $atLedCode AS atLedCode, $atType AS atType,
      $atEntryno AS atEntryno, $atDebitAmount AS atDebitAmount, $atCreditAmount AS atCreditAmount,
      $atNarration AS atNarration, $atOpposite AS atOpposite, $atSalesEntryno AS atSalesEntryno,
      $atSalesType AS atSalesType, $atLocation AS atLocation, $atChequeNo AS atChequeNo,
      $atProject AS atProject, $atBankEntry AS atBankEntry, $atInvestor AS atInvestor,
      $atFyID AS atFyID, $atFxDebit AS atFxDebit, $atFxCredit AS atFxCredit
    ) AS source
    ON target.Auto = source.Auto
    WHEN MATCHED THEN
      UPDATE SET 
        atDate = source.atDate, atLedCode = source.atLedCode, atType = source.atType,
        atEntryno = source.atEntryno, atDebitAmount = source.atDebitAmount, 
        atCreditAmount = source.atCreditAmount, atNarration = source.atNarration, 
        atOpposite = source.atOpposite, atSalesEntryno = source.atSalesEntryno, 
        atSalesType = source.atSalesType, atLocation = source.atLocation, 
        atChequeNo = source.atChequeNo, atProject = source.atProject, 
        atBankEntry = source.atBankEntry, atInvestor = source.atInvestor, 
        atFyID = source.atFyID, atFxDebit = source.atFxDebit, atFxCredit = source.atFxCredit
    WHEN NOT MATCHED THEN
      INSERT (Auto, atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, 
              atNarration, atOpposite, atSalesEntryno, atSalesType, atLocation, 
              atChequeNo, atProject, atBankEntry, atInvestor, atFyID, 
              atFxDebit, atFxCredit)
      VALUES ($autoValue, $atDate, $atLedCode, $atType, $atEntryno, 
              $atDebitAmount, $atCreditAmount, $atNarration, $atOpposite, 
              $atSalesEntryno, $atSalesType, $atLocation, $atChequeNo, 
              $atProject, $atBankEntry, $atInvestor, $atFyID, 
              $atFxDebit, $atFxCredit);

    SET IDENTITY_INSERT Account_Transactions OFF;
    ''';

    print('Executing SQL query: $query');

    if (MsSQLConnectionPlatform.instance == null) {
      throw Exception('MsSQLConnectionPlatform is not initialized');
    }

    final result = await MsSQLConnectionPlatform.instance!.writeData(query);

    if (result != null) {
      print('Query executed successfully: $result');
    } else {
      throw Exception('Query execution failed with null result');
    }
  } catch (e) {
    print('Error executing query: $e');
  }
}




Future<void> fetchDataAndSyncToSQLite() async {
  try {
    final query =
        'SELECT Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state, Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location, OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate, SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount FROM LedgerNames';
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);
      if (decodedData is List) {
        final records = decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        final db = await getDatabase(); 
        for (var record in records) {
          await db.insert(
            'ledgernames',
            record,
            conflictAlgorithm: ConflictAlgorithm.replace, 
          );
        }
        print('Data synchronized to SQLite successfully.');
      } else {
        throw Exception('Unexpected JSON format for LedgerNames data: $decodedData');
      }
    } else {
      throw Exception('Unexpected data format for LedgerNames: $rawData');
    }
  } catch (e) {
    print('Error fetching and syncing data: $e');
    rethrow;
  }
}




Future<List<Map<String, dynamic>>> fetchLedgerDataFromSQLite() async {
  final db = await LedgerTransactionsDatabaseHelper.instance.database;
  return await db.query('LedgerNames');
}
String formatValue(dynamic value) {
  if (value == null) {
    return 'NULL';
  } else if (value is String) {
    return "'${value.replaceAll("'", "''")}'"; 
  } else {
    return value.toString();
  }
}

////////////////////////////////////////////////////////////////////

Future<List<Map<String, dynamic>>> fetchSimpleLedgerReport({
  required String ledname,  
  required String fromdate,
  required String todate,
}) async {
  final db = await database;

  try {
    var ledCodeResult = await db.rawQuery('''
      SELECT Ledcode 
      FROM LedgerNames 
      WHERE LedName = ?
    ''', [ledname]);

    if (ledCodeResult.isEmpty) {
      print("No ledger code found for the provided ledger name.");
      return [];
    }

    String ledcode = ledCodeResult[0]['Ledcode'] as String;
    var openingBalance = await db.rawQuery('''
      SELECT 
        '' AS Date, 
        'Opening Balance' AS Particulars, 
        '' AS Voucher, 
        NULL AS EntryNo, 
        CASE 
          WHEN SUM(atDebitAmount - atCreditAmount) > 0 THEN CAST(SUM(atDebitAmount - atCreditAmount) AS numeric(10, 3))
          ELSE 0 
        END AS Debit,
        CASE 
          WHEN SUM(atCreditAmount - atDebitAmount) > 0 THEN CAST(SUM(atCreditAmount - atDebitAmount) AS numeric(10, 3))
          ELSE 0 
        END AS Credit,
        '' AS Narration,
        1 AS RowNum
      FROM Account_Transactions
      WHERE atLedCode = ?
        AND atBankEntry = 0 
        AND atDate < ?
    ''',
     [ledcode, fromdate]);

    double openingBalDebit = openingBalance.isNotEmpty
        ? (openingBalance[0]['Debit'] as num?)?.toDouble() ?? 0.0
        : 0.0;
    double openingBalCredit = openingBalance.isNotEmpty
        ? (openingBalance[0]['Credit'] as num?)?.toDouble() ?? 0.0
        : 0.0;
    List<Map<String, dynamic>> result = [
      {
        'Date': '',
        'Particulars': 'Opening Balance',
        'Voucher': '',
        'EntryNo': '',
        'Debit': openingBalDebit > 0 ? openingBalDebit : 0.0,
        'Credit': openingBalCredit > 0 ? openingBalCredit : 0.0,
        'Balance': '',
        'Narration': '',
      }
    ];

    var transactions = await db.rawQuery('''
      SELECT
        strftime('%d-%m-%Y', atDate) AS Date,
        LedName AS Particulars,
        atType AS Voucher,
        atEntryno AS EntryNo,
        CAST(atDebitAmount AS NUMERIC(10, 3)) AS Debit,
        CAST(atCreditAmount AS NUMERIC(10, 3)) AS Credit,
        atNarration AS Narration
      FROM Account_Transactions a
      JOIN LedgerNames b ON a.atOpposite = b.Ledcode
      WHERE a.atLedCode = ? 
        AND a.atBankEntry = 0
        AND a.atDate BETWEEN ? AND ?
      ORDER BY a.atDate, a.atLedCode
    ''', [ledcode, fromdate, todate]);

    double runningBalance = openingBalDebit - openingBalCredit; 
    for (var transaction in transactions) {
      double debit = (transaction['Debit'] as num?)?.toDouble() ?? 0.0;
      double credit = (transaction['Credit'] as num?)?.toDouble() ?? 0.0;
      runningBalance += debit - credit;

      String balance = runningBalance > 0 ? "${runningBalance} Dr" : "${-runningBalance} Cr";

      result.add({
        'Date': transaction['Date'],
        'Particulars': transaction['Particulars'],
        'Voucher': transaction['Voucher'],
        'EntryNo': transaction['EntryNo'],
        'Debit': debit,
        'Credit': credit,
        'Balance': balance, 
        'Narration': transaction['Narration']
      });
    }
    double totalDebit = result.fold(0.0, (sum, item) => sum + (item['Debit'] ?? 0.0));
    double totalCredit = result.fold(0.0, (sum, item) => sum + (item['Credit'] ?? 0.0));
    result.add({
      'Date': '',
      'Particulars': 'Total',
      'Voucher': '',
      'EntryNo': '',
      'Debit': totalDebit,
      'Credit': totalCredit,
      'Balance': '',
      'Narration': ''
    });
    result.add({
      'Date': '',
      'Particulars': 'Closing Balance',
      'Voucher': '',
      'EntryNo': '',
      'Debit': totalDebit > totalCredit ? totalDebit - totalCredit : 0,
      'Credit': totalCredit > totalDebit ? totalCredit - totalDebit : 0,
      'Balance': '', 
      'Narration': ''
    });

    return result;
  } catch (e) {
    print('Error fetching simple ledger report: $e');
    return [];
  }
}

Future<Map<String, dynamic>> getLedgerBalance(String ledgerName) async {
  final db = await database;
  var ledgerCodeQuery = await db.rawQuery(''' 
    SELECT Ledcode FROM LedgerNames WHERE LedName = ? 
  ''', [ledgerName]);

  if (ledgerCodeQuery.isEmpty) {
    return {'error': 'Ledger not found'};
  }

  String ledgerCode = ledgerCodeQuery[0]['Ledcode'].toString();

  try {
    var result = await db.rawQuery('''
      SELECT 
        IFNULL(SUM(atDebitAmount), 0) AS totalDebit, 
        IFNULL(SUM(atCreditAmount), 0) AS totalCredit
      FROM Account_Transactions
      WHERE atLedCode = ?
        AND atBankEntry = 0
    ''', [ledgerCode]);

    double totalDebit = result.isNotEmpty ? result[0]['totalDebit'] as double : 0.0;
    double totalCredit = result.isNotEmpty ? result[0]['totalCredit'] as double : 0.0;
    double balance = totalDebit - totalCredit;
    String balanceType = balance >= 0 ? 'DR' : 'CR';

    return {
      'balance': balance,
      'balanceType': balanceType,
    };
  } catch (e) {
    print('Error fetching ledger balance: $e');
    return {'error': ''};
  }
}





}

Future<void> fetchDataAndStoreInXML() async {
  try {
    final query = '''
      SELECT DISTINCT Auto, atDate, atLedCode, atType, atEntryno, atDebitAmount, 
             atCreditAmount, atNarration, atOpposite, atSalesEntryno, atSalesType, 
             atLocation, atChequeNo, atProject, atBankEntry, atInvestor, atFyID, 
             atFxDebit, atFxCredit 
      FROM Account_Transactions
      WHERE Auto IS NOT NULL 
      ORDER BY Auto ASC
    ''';

    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);

      if (decodedData is List) {
        List<String> expectedColumns = [
          "Auto", "atDate", "atLedCode", "atType", "atEntryno", "atDebitAmount",
          "atCreditAmount", "atNarration", "atOpposite", "atSalesEntryno",
          "atSalesType", "atLocation", "atChequeNo", "atProject", "atBankEntry",
          "atInvestor", "atFyID", "atFxDebit", "atFxCredit"
        ];

        List<Map<String, dynamic>> validData = [];

        for (var row in decodedData) {
          if (row is Map<String, dynamic>) {
            bool isValid = expectedColumns.every((col) => row.containsKey(col));

            if (isValid) {
              String formattedDate = row["atDate"].toString();

              try {
                DateTime parsedDate = DateTime.parse(formattedDate);
                formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
              } catch (e) {
                print('Invalid date format for Auto ${row["Auto"]}: $formattedDate');
                formattedDate = ""; 
              }

              row["atDate"] = formattedDate;
              validData.add(Map<String, dynamic>.from(row));
            } else {
              print('Invalid row detected and ignored: $row');
            }
          }
        }

        final builder = xml.XmlBuilder();
        builder.processing('xml', 'version="1.0" encoding="UTF-8"');
        builder.element('Account_Transactions', nest: () {
          for (var row in validData) {
            builder.element('Transaction', nest: () {
              row.forEach((key, value) {
                builder.element(key, nest: value ?? ''); 
              });
            });
          }
        });

        final xmlString = builder.buildDocument().toXmlString(pretty: true);
        print('XML Data: $xmlString');  

        final dbHelper = LedgerTransactionsDatabaseHelper.instance;
        await dbHelper.insertXMLData(xmlString);

        print('XML data stored in SQLite successfully!');
      } else {
        throw Exception('Unexpected JSON format in MSSQL data: $decodedData');
      }
    } else {
      throw Exception('Unexpected data format received from MSSQL: $rawData');
    }
  } catch (e) {
    print('Error fetching data from Account_Transactions: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchDataFromMSSQLAccTransations() async {
  try {
    final query = '''
      SELECT DISTINCT Auto, atDate, atLedCode, atType, atEntryno, atDebitAmount, 
             atCreditAmount, atNarration, atOpposite, atSalesEntryno, atSalesType, 
             atLocation, atChequeNo, atProject, atBankEntry, atInvestor, atFyID, 
             atFxDebit, atFxCredit 
      FROM Account_Transactions
      WHERE Auto IS NOT NULL 
      ORDER BY Auto ASC
    ''';

    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);

      if (decodedData is List) {
        List<String> expectedColumns = [
          "Auto", "atDate", "atLedCode", "atType", "atEntryno", "atDebitAmount",
          "atCreditAmount", "atNarration", "atOpposite", "atSalesEntryno",
          "atSalesType", "atLocation", "atChequeNo", "atProject", "atBankEntry",
          "atInvestor", "atFyID", "atFxDebit", "atFxCredit"
        ];

        List<Map<String, dynamic>> validData = [];

        for (var row in decodedData) {
          if (row is Map<String, dynamic>) {
            bool isValid = expectedColumns.every((col) => row.containsKey(col));

            if (isValid) {
              String formattedDate = row["atDate"].toString();

              try {
                DateTime parsedDate = DateTime.parse(formattedDate);
                formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
              } catch (e) {
                print('Invalid date format for Auto ${row["Auto"]}: $formattedDate');
                formattedDate = ""; 
              }

              row["atDate"] = formattedDate;
              validData.add(Map<String, dynamic>.from(row));
            } else {
              print('Invalid row detected and ignored: $row');
            }
          }
        }
        Map<String, Map<String, dynamic>> uniqueDataMap = {
          for (var item in validData) item["Auto"].toString(): item
        };
        final uniqueData = uniqueDataMap.values.toList();

        print('Fetched ${uniqueData.length} unique rows from Account_Transactions.');
        return uniqueData;
      } else {
        throw Exception('Unexpected JSON format in MSSQL data: $decodedData');
      }
    } else {
      throw Exception('Unexpected data format received from MSSQL: $rawData');
    }
  } catch (e) {
    print('Error fetching data from Account_Transactions: $e');
    rethrow;
  }
}







Future<void> backupMSSQLToSQLite() async {
  final dbHelper = LedgerTransactionsDatabaseHelper.instance;
  await dbHelper.enableWALMode(); 
  try {
    final fetchedData = await fetchDataFromMSSQLAccTransations();

    if (fetchedData.isEmpty) {
      print('No data to backup. Exiting.');
      return;
    }

    print('Total rows fetched: ${fetchedData.length}');

    await dbHelper.insertData(fetchedData);

    final sqliteRowCount = await dbHelper.getRowCount();
    print('SQLite contains $sqliteRowCount rows after backup.');

    if (sqliteRowCount != fetchedData.length) {
      print('Warning: Mismatch in row count! Fetched: ${fetchedData.length}, Inserted: $sqliteRowCount');
    } else {
      print('Backup successful. All rows are backed up.');
    }
  } catch (e) {
    print('Error during backup: $e');
  }
}

