import 'dart:convert';

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
      EntryNo REAL,
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

  // // **Insert Data**
  // Future<int> insertSale(Map<String, dynamic> sale) async {
  //   final db = await instance.database;
  //   return await db.insert('Sales_Information', sale);
  // }
Future<void> insertSale(Map<String, dynamic> payData) async {
  final db = await database;

  try {
    print('Inserting saleData: $payData');

    final result = await db.insert(
      'Sales_Information',
      payData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('Insertion successful. Row inserted with ID: $result');
    } else {
      print('Insertion failed. No row inserted.');
    }

    // Check if the data exists
    final checkResult = await db.query(
      'Sales_Information',
      where: 'RealEntryNo = ?',
      whereArgs: [payData['RealEntryNo']],
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
  // **Fetch Data**
  Future<List<Map<String, dynamic>>> getSalesData() async {
    final db = await instance.database;
    return await db.query('Sales_Information');
  }

  // **Delete All Data (Optional)**
  Future<void> clearSalesTable() async {
    final db = await instance.database;
    await db.delete('Sales_Information');
  }

  Future<void> insertParticular(Map<String, dynamic> particularData) async {
  final db = await database;

  try {
    print('Inserting Particular Data: $particularData');

    final result = await db.insert(
      'Sales_Particulars',
      particularData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (result > 0) {
      print('Insertion successful. Row inserted with ID: $result');
    } else {
      print('Insertion failed. No row inserted.');
    }

    // Verify the inserted record
    final checkResult = await db.query(
      'Sales_Particulars',
      where: 'ParticularID = ?',
      whereArgs: [result],
    );

    if (checkResult.isNotEmpty) {
      print('Data successfully inserted: ${checkResult.first}');
    } else {
      print('Data insertion was unsuccessful.');
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
}
