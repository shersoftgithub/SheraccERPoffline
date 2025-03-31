import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SalesInformationDatabaseHelper2 {
  static final SalesInformationDatabaseHelper2 instance = SalesInformationDatabaseHelper2._init();
  static Database? _database;

  SalesInformationDatabaseHelper2._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sales_information2.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS Sales_Information (
      RealEntryNo INTEGER PRIMARY KEY,
      EntryNo INTEGER,
      InvoiceNo TEXT,
      DDate TEXT,
      BTime TEXT,
      Customer TEXT,
      Add1 TEXT,
      Add2 TEXT,
      Toname TEXT,
      TaxType TEXT,
      GrossValue REAL,
      Discount REAL,
      NetAmount REAL,
      cess REAL,
      Total REAL,
      loadingcharge REAL,
      OtherCharges REAL,
      OtherDiscount REAL,
      Roundoff REAL,
      GrandTotal REAL,
      SalesAccount TEXT,
      SalesMan TEXT,
      Location TEXT,
      Narration TEXT,
      Profit REAL,
      CashReceived REAL,
      BalanceAmount REAL,
      Ecommision REAL,
      labourCharge REAL,
      OtherAmount REAL,
      Type TEXT,
      PrintStatus TEXT,
      CNo TEXT,
      CreditPeriod TEXT,
      DiscPercent REAL,
      SType TEXT,
      VatEntryNo TEXT,
      tcommision REAL,
      commisiontype TEXT,
      cardno TEXT,
      takeuser TEXT,
      PurchaseOrderNo TEXT,
      ddate1 TEXT,
      deliverNoteNo TEXT,
      despatchno TEXT,
      despatchdate TEXT,
      Transport TEXT,
      Destination TEXT,
      Transfer_Status TEXT,
      TenderCash REAL,
      TenderBalance REAL,
      returnno TEXT,
      returnamt REAL,
      vatentryname TEXT,
      otherdisc1 REAL,
      salesorderno TEXT,
      systemno TEXT,
      deliverydate TEXT,
      QtyDiscount REAL,
      ScheemDiscount REAL,
      Add3 TEXT,
      Add4 TEXT,
      BankName TEXT,
      CCardNo TEXT,
      SMInvoice TEXT,
      Bankcharges REAL,
      CGST REAL,
      SGST REAL,
      IGST REAL,
      mrptotal REAL,
      adcess REAL,
      BillType TEXT,
      discuntamount REAL,
      unitprice REAL,
      lrno TEXT,
      evehicleno TEXT,
      ewaybillno TEXT,
      RDisc REAL,
      subsidy REAL,
      kms REAL,
      todevice TEXT,
      Fcess REAL,
      spercent REAL,
      bankamount REAL,
      FcessType TEXT,
      receiptAmount REAL,
      receiptDate TEXT,
      JobCardno TEXT,
      WareHouse TEXT,
      CostCenter TEXT,
      CounterClose TEXT,
      CashAccountID TEXT,
      ShippingName TEXT,
      ShippingAdd1 TEXT,
      ShippingAdd2 TEXT,
      ShippingAdd3 TEXT,
      ShippingGstNo TEXT,
      ShippingState TEXT,
      ShippingStateCode TEXT,
      RateType TEXT,
      EmiAc TEXT,
      EmiAmount REAL,
      EmiRefNo TEXT,
      RedeemPoint REAL,
      IRNNo TEXT,
      signedinvno TEXT,
      signedQrCode TEXT,
      Salesman1 TEXT,
      TCSPer REAL,
      TCS REAL,
      app TEXT,
      TotalQty REAL,
      InvoiceLetter TEXT,
      AckDate TEXT,
      AckNo TEXT,
      Project TEXT,
      PlaceofSupply TEXT,
      tenderRefNo TEXT,
      IsCancel INTEGER,
      FyID INTEGER,
      m_invoiceno TEXT,
      PaymentTerms TEXT,
      WarrentyTerms TEXT,
      QuotationEntryNo TEXT,
      CreditNoteNo TEXT,
      CreditNoteAmount REAL,
      Careoff TEXT,
      CareoffAmount REAL,
      DeliveryStatus TEXT,
      SOrderBilled TEXT,
      isCashCounter TEXT,
      Discountbarcode TEXT,
      ExcEntryNo TEXT,
      ExcEntryAmt REAL,
      FxCurrency TEXT,
      FxValue REAL,
      CntryofOrgin TEXT,
      ContryFinalDest TEXT,
      PrecarriageBy TEXT,
      PlacePrecarrier TEXT,
      PortofLoading TEXT,
      Portofdischarge TEXT,
      FinalDestination TEXT,
      CtnNo TEXT,
      Totalctn INTEGER,
      Netwt REAL,
      grosswt REAL,
      Blno TEXT
    );
  ''');
      await db.execute('''
    CREATE TABLE Sales_Particulars (
      ParticularID INTEGER PRIMARY KEY AUTOINCREMENT,
      DDate TEXT NOT NULL,
      EntryNo INTEGER,
      UniqueCode REAL,
      ItemID INTEGER,
      serialno TEXT,
      Rate REAL,
      RealRate REAL,
      Qty REAL,
      freeQty REAL,
      GrossValue REAL,
      DiscPersent REAL,
      Disc REAL,
      RDisc REAL,
      Net REAL,
      Vat REAL,
      freeVat REAL,
      cess REAL,
      Total REAL,
      Profit REAL,
      Auto INTEGER,
      Unit INTEGER,
      UnitValue REAL,
      Funit INTEGER,
      FValue REAL,
      commision REAL,
      GridID INTEGER,
      takeprintstatus TEXT,
      QtyDiscPercent REAL,
      QtyDiscount REAL,
      ScheemDiscPercent REAL,
      ScheemDiscount REAL,
      CGST REAL,
      SGST REAL,
      IGST REAL,
      adcess REAL,
      netdisc REAL,
      taxrate INTEGER,
      SalesmanId TEXT,
      Fcess REAL,
      Prate REAL,
      Rprate REAL,
      location INTEGER,
      Stype INTEGER,
      LC REAL,
      ScanBarcode TEXT,
      Remark TEXT,
      FyID INTEGER,
      Supplier TEXT,
      Retail REAL,
      spretail REAL,
      wsrate REAL
    )
  ''');
  }

  // Future<int> insertSale(Map<String, dynamic> sale) async {
  //   final db = await instance.database;
  //   return await db.insert('Sales_Information', sale);
  // }

  Future<void> clearSaleinfo() async {
    final db = await instance.database;
    await db.delete('Sales_Information');
  }
  Future<void> clearSaleperti() async {
    final db = await instance.database;
    await db.delete('Sales_Particulars');
  }

  Future<void> insertSale2(Map<String, dynamic> data) async {
  final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

 String formatDate(String? date) {
      if (date != null && date.isNotEmpty) {
        try {
          final DateTime parsedDate = DateTime.parse(date);
          return DateFormat('yyyy-MM-dd').format(parsedDate); 
        } catch (e) {
          print('Error formatting date: $e');
        }
      }
      return ''; 
    }

    String formattedDDate = formatDate(data['DDate']);
    String formattedDDate1 = formatDate(data['ddate1']);
    String formattedDeliveryDate = formatDate(data['deliverydate']);
    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO Sales_Information (
          RealEntryNo, EntryNo, InvoiceNo, DDate, Customer, Add1, Add2, Toname, TaxType,
          GrossValue, Discount, NetAmount, cess, Total, Roundoff, GrandTotal, SalesAccount, 
          SalesMan, Narration, Profit, CashReceived, BalanceAmount, DiscPercent, SType,
          PurchaseOrderNo, ddate1, salesorderno, deliverydate, QtyDiscount, Add3, Add4, 
          BankName, CGST, SGST, IGST, mrptotal, adcess, BillType, discuntamount, unitprice, 
          RDisc, bankamount, Salesman1, TotalQty, Project, FyID, CreditNoteNo, CreditNoteAmount, 
          Netwt, grosswt, Blno
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?)
      ''', [
        data['RealEntryNo']?.toString() ?? '',
        data['EntryNo']?.toString() ?? '',
        data['InvoiceNo']?.toString() ?? '',
        formattedDDate,
        data['Customer']?.toString() ?? '',
        data['Add1']?.toString() ?? '',
        data['Add2']?.toString() ?? '',
        data['Toname']?.toString() ?? '',
        data['TaxType']?.toString() ?? '',
        data['GrossValue']?.toString() ?? '',
        data['Discount']?.toString() ?? '',
        data['NetAmount']?.toString() ?? '',
        data['cess']?.toString() ?? '',
        data['Total']?.toString() ?? '',
        data['Roundoff']?.toString() ?? '',
        data['GrandTotal']?.toString() ?? '',
        data['SalesAccount']?.toString() ?? '',
        data['SalesMan']?.toString() ?? '',
        data['Narration']?.toString() ?? '',
        data['Profit']?.toString() ?? '',
        data['CashReceived']?.toString() ?? '',
        data['BalanceAmount']?.toString() ?? '',
        data['DiscPercent']?.toString() ?? '',
        data['SType']?.toString() ?? '',
        data['PurchaseOrderNo']?.toString() ?? '',
        formattedDDate1,
        data['salesorderno']?.toString() ?? '',
        data['deliverydate']?.toString() ?? '',
        data['QtyDiscount']?.toString() ?? '',
        data['Add3']?.toString() ?? '',
        data['Add4']?.toString() ?? '',
        data['BankName']?.toString() ?? '',
        data['CGST']?.toString() ?? '',
        data['SGST']?.toString() ?? '',
        data['IGST']?.toString() ?? '',
        data['mrptotal']?.toString() ?? '',
        data['adcess']?.toString() ?? '',
        data['BillType']?.toString() ?? '',
        data['discuntamount']?.toString() ?? '',
        data['unitprice']?.toString() ?? '',
        data['RDisc']?.toString() ?? '',
        data['bankamount']?.toString() ?? '',
        data['Salesman1']?.toString() ?? '',
        data['TotalQty']?.toString() ?? '',
        data['Project']?.toString() ?? '',
        data['FyID']?.toString() ?? '',
        data['CreditNoteNo']?.toString() ?? '',
        data['CreditNoteAmount']?.toString() ?? '',
        data['Netwt']?.toString() ?? '',
        data['grosswt']?.toString() ?? '',
        data['Blno']?.toString() ?? ''
      ]);
    });

    print(' Sales_Information Inserted Successfully');
  } catch (e) {
    print(' Error inserting Sales_Information data: $e');
  }
}

Future<void> insertSale(Map<String, dynamic> payData) async {
  final db = await database;

  try {
    print('Checking for existing RealEntryNo: ${payData['RealEntryNo']}');
    final existingEntry = await db.query(
      'Sales_Information',
      where: 'RealEntryNo = ?',
      whereArgs: [payData['RealEntryNo']],
    );

    if (existingEntry.isNotEmpty) {
      print('Duplicate RealEntryNo found: ${payData['RealEntryNo']}. Insertion aborted.');
      return; 
    }

    print('Inserting saleData: $payData');

    final result = await db.insert(
      'Sales_Information',
      payData,
      conflictAlgorithm: ConflictAlgorithm.ignore, 
    );

    if (result > 0) {
      print('Insertion successful. Row inserted with ID: $result');
    } else {
      print('Insertion failed. No row inserted.');
    }
  } catch (e) {
    print('Error inserting sale data: $e');
  }
}
  Future<List<Map<String, dynamic>>> getSalesData() async {
    final db = await instance.database;
    return await db.query('Sales_Information');
  }

  Future<void> clearSalesTable() async {
    final db = await instance.database;
    await db.delete('Sales_Information');
  }
 Future<void> insertParticular2(Map<String, dynamic> data) async {
  final db = await database;

  try {
    await db.rawQuery("PRAGMA synchronous = OFF");
    await db.rawQuery("PRAGMA journal_mode = WAL");
    await db.rawQuery("PRAGMA temp_store = MEMORY");

    String formatDate(String? date) {
      if (date != null && date.isNotEmpty) {
        try {
          final DateTime parsedDate = DateTime.parse(date);
          return DateFormat('yyyy-MM-dd').format(parsedDate); 
        } catch (e) {
          print('Error formatting date: $e');
        }
      }
      return ''; 
    }

    String formattedDDate = formatDate(data['DDate']);

    await db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR REPLACE INTO Sales_Particulars (
        DDate ,
      EntryNo,
      UniqueCode,
      ItemID ,
      serialno,
      Rate ,
      RealRate,
      Qty,
      freeQty ,
      GrossValue ,
      DiscPersent ,
      Disc ,
      Net,
      Total ,
      Profit,
      Auto,
      Unit ,
      UnitValue,
      Funit ,
      FValue,
      commision,
      QtyDiscPercent,
      QtyDiscount,
      CGST,
      SGST,
      IGST ,
      taxrate ,
      Prate ,
      Rprate,
      Stype,
      FyID ,
      Retail ,
      spretail,
      wsrate 
         ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,? ,? , ? ,? , ?, ?, ? ,? ,?,?,?,?,?,?)
      ''', [
        formattedDDate,
        data['EntryNo']?.toString() ?? '',
        data['UniqueCode']?.toString() ?? '',
        data['ItemID']?.toString() ?? '',
        data['serialno']?.toString() ?? '',
        data['Rate']?.toString() ?? '',
        data['RealRate']?.toString() ?? '',
        data['Qty']?.toString() ?? '',
        data['freeQty']?.toString() ?? '',
        data['GrossValue']?.toString() ?? '',
        data['DiscPersent']?.toString() ?? '',
        data['Disc']?.toString() ?? '',
        data['Net']?.toString() ?? '',
        data['Total']?.toString() ?? '',
        data['Profit']?.toString() ?? '',
        data['Auto']?.toString() ?? '',
        data['Unit']?.toString() ?? '',
        data['UnitValue']?.toString() ?? '',
        data['Funit']?.toString() ?? '',
        data['FValue']?.toString() ?? '',
        data['commision']?.toString() ?? '',
        data['QtyDiscPercent']?.toString() ?? '',
        data['QtyDiscount']?.toString() ?? '',
        data['CGST']?.toString() ?? '',
        data['SGST']?.toString() ?? '',
        data['IGST']?.toString() ?? '',
        data['taxrate']?.toString() ?? '',
        data['Prate']?.toString() ?? '',
        data['Rprate']?.toString() ?? '',
        data['Stype']?.toString() ?? '',
        data['FyID']?.toString() ?? '',
        data['Retail']?.toString() ?? '',
        data['spretail']?.toString() ?? '',
        data['wsrate']?.toString() ?? '',
      ]);
    });

    print('Sales_Particulars Inserted Successfully');
  } catch (e) {
    print('Error inserting Sales_Particulars data: $e');
  }
}

Future<void> insertParticular(Map<String, dynamic> particularData) async {
  final db = await database;

  try {
    print('Checking for existing data: ${particularData['UniqueCode']}, ${particularData['EntryNo']}');

    final existingData = await db.rawQuery(
      'SELECT * FROM Sales_Particulars WHERE UniqueCode = ? AND EntryNo = ?',
      [particularData['UniqueCode'], particularData['EntryNo']],
    );

    if (existingData.isNotEmpty) {
      print('Duplicate entry found. Skipping insertion for UniqueCode: ${particularData['UniqueCode']}, EntryNo: ${particularData['EntryNo']}');
      return; // Exit function if duplicate exists
    }

    print('Inserting Particular Data: $particularData');

    final result = await db.insert(
      'Sales_Particulars',
      particularData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('Insertion successful. Row inserted with ID: $result');

      final lastEntry = await db.rawQuery(
        'SELECT EntryNo FROM Sales_Particulars ORDER BY EntryNo DESC LIMIT 1',
      );

      if (lastEntry.isNotEmpty) {
        print('Last inserted EntryNo: ${lastEntry.first['EntryNo']}');
      } else {
        print('No EntryNo found after insertion.');
      }
    } else {
      print('Insertion failed. No row inserted.');
    }
  } catch (e) {
    print('Error inserting particular data: $e');
  }
}



Future<List<Map<String, dynamic>>> getSalesDataperticular() async {
    final db = await instance.database;
    return await db.query('Sales_Particulars');
  }

  Future<List<Map<String, dynamic>>> fetch_sale_informationDataFromMSSQL() async {
   try {
      final query = 'SELECT  RealEntryNo,InvoiceNo,DDate,Customer,Toname,Discount,NetAmount,Total,TotalQty FROM Sales_Information';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for Sales_Information data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for Sales_Information: $rawData');
    } catch (e) {
      print('Error fetching data from Sales_Information: $e');
      rethrow;
    }
}


Future<List<Map<String, dynamic>>> queryFilteredRowsPay({
  DateTime? fromDate, 
  DateTime? toDate, 
  String? ledgerName,
  String? itemname,
  String? itemcode,
}) async {
  Database db = await instance.database;

  List<String> whereClauses = [];
  List<dynamic> whereArgs = [];

  if (fromDate != null && toDate != null) {
    String fromDateString = DateFormat('yyyy-MM-dd').format(fromDate);
    String toDateString = DateFormat('yyyy-MM-dd').format(toDate);
    whereClauses.add("DATE(Sales_Information.DDate) BETWEEN DATE(?) AND DATE(?)");
    whereArgs.addAll([fromDateString, toDateString]);
  }

  if (ledgerName != null && ledgerName.isNotEmpty) {
    whereClauses.add("Sales_Information.Toname LIKE ?");
    whereArgs.add("%$ledgerName%");
  }
  if (itemname != null && itemname.isNotEmpty) {
    whereClauses.add("Sales_Particulars.ItemID IN (SELECT ItemID FROM Item WHERE ItemName LIKE ?)");
    whereArgs.add("%$itemname%");
  }

  if (itemcode != null && itemcode.isNotEmpty) {
    whereClauses.add("Sales_Particulars.ItemID LIKE ?");
    whereArgs.add("%$itemcode%");
  }

  String whereClause = whereClauses.isNotEmpty ? "WHERE ${whereClauses.join(' AND ')}" : '';

  try {
    String query = '''
      SELECT 
        Sales_Information.RealEntryNo,
        Sales_Information.InvoiceNo,
        Sales_Information.DDate AS InfoDDate,
        Sales_Information.EntryNo,
        Sales_Information.Toname,
        Sales_Information.TotalQty,
        Sales_Information.Discount,
        Sales_Information.GrandTotal,
        Sales_Information.Stype,
        Sales_Particulars.DDate AS PartDDate,  
        CAST(Sales_Particulars.EntryNo AS INTEGER) AS PartEntryNo,  -- Convert EntryNo to INTEGER
        Sales_Particulars.Rate,  
        Sales_Particulars.ItemID  
      FROM Sales_Information
      LEFT JOIN Sales_Particulars
        ON Sales_Information.EntryNo = CAST(Sales_Particulars.EntryNo AS INTEGER)  
      $whereClause;
    ''';

    final result = await db.rawQuery(query, whereArgs);

    return result;
  } catch (e) {
    print("Error fetching filtered data: $e");
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> fetchNewSaleParticulars(int lastMssqlAuto) async {
  final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
    'Sales_Particulars',
    where: 'Auto > ?',
    whereArgs: [lastMssqlAuto],
    orderBy: 'Auto ASC',
  );

  return result;
}
Future<List<Map<String, dynamic>>> fetchNewSaleInformation(int lastMssqlAuto) async {
  final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
    'Sales_Information',
    where: 'RealEntryNo > ?',
    whereArgs: [lastMssqlAuto],
    orderBy: 'RealEntryNo ASC',
  );

  return result;
}


}
