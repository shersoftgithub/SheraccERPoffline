import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/reciept_databasehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_info2.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_information.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';

final class Update{

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

Future<void> syncRVInformationToMSSQL() async {
 try {
    final lastRowQuery = "SELECT TOP 1 RealEntryNo FROM RV_Information ORDER BY RealEntryNo DESC";
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastMssqlAuto = 0;

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastMssqlAuto = (decodedLastRow.first['RealEntryNo'] ?? 0) as int;
      }
    }

    final localData = await RV_DatabaseHelper.instance.fetchNewRVInformation(lastMssqlAuto);
    if (localData.isEmpty) {
      print(" No new records to sync.");
      return;
    }

    for (var row in localData) {
      final realEntryNo = int.tryParse(row['RealEntryNo'].toString()) ?? 0;

      final checkQuery = "SELECT COUNT(*) AS count FROM RV_Information WHERE RealEntryNo = $realEntryNo";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      int existingCount = 0;
      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          existingCount = decodedCheck.first['count'] ?? 0;
        }
      }

      if (existingCount > 0) {
        print("Skipping duplicate record: Auto $realEntryNo already exists in MSSQL.");
        continue;
      }
      final ddate = row['DDATE'].toString();
      final amount = double.tryParse(row['AMOUNT'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final creditAccount = row['DEBITACCOUNT'].toString().replaceAll("'", "''");
      final takeuser = row['takeuser'].toString().replaceAll("'", "''");
      final location = int.tryParse(row['Location'].toString()) ?? 0;
      final project = int.tryParse(row['Project'].toString()) ?? 0;
      final salesMan = int.tryParse(row['SalesMan'].toString()) ?? 0;
      final monthDate = row['MonthDate'].toString();
      final app = int.tryParse(row['app'].toString()) ?? 0;
      final transferStatus = int.tryParse(row['Transfer_Status'].toString()) ?? 0;
      final fyID = int.tryParse(row['FyID'].toString()) ?? 0;
      final entryNo = int.tryParse(row['EntryNo'].toString()) ?? 0;
      final frmID = int.tryParse(row['FrmID'].toString()) ?? 0;
      final pviCurrency = int.tryParse(row['rviCurrency'].toString()) ?? 0;
      final pviCurrencyValue = double.tryParse(row['rviCurrencyValue'].toString()) ?? 0.0;
      final pdate = row['pdate'].toString();

      final insertQuery = '''
  SET IDENTITY_INSERT RV_Information ON;
          INSERT INTO RV_Information (RealEntryNo, DDATE, AMOUNT, Discount, Total, DEBITACCOUNT, takeuser, Location, 
          Project, SalesMan, MonthDate, app, Transfer_Status, FyID, EntryNo, FrmID, 
          rviCurrency, rviCurrencyValue, pdate)
  VALUES (
    $realEntryNo, '$ddate', $amount, $discount, $total, '$creditAccount', '$takeuser', 
          $location, $project, $salesMan, '$monthDate', $app, $transferStatus, $fyID, 
          $entryNo, $frmID, $pviCurrency, $pviCurrencyValue, '$pdate'
  );
  SET IDENTITY_INSERT RV_Information OFF;
''';
      await MsSQLConnectionPlatform.instance.writeData(insertQuery);
      print(" Inserted new record: Auto $realEntryNo, Date $ddate");
    }

    print(" Sync completed successfully!");

  } catch (e) {
    print(" Error syncing RV_Information to MSSQL: $e");
  }
}


Future<void> syncRVParticularsToMSSQL() async {
 try {
    final lastRowQuery = "SELECT TOP 1 auto FROM RV_Particulars ORDER BY auto DESC";
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastMssqlAuto = 0;

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastMssqlAuto = (decodedLastRow.first['auto'] ?? 0) as int;
      }
    }

    final localData = await RV_DatabaseHelper.instance.fetchNewRVParticulars(lastMssqlAuto);
    if (localData.isEmpty) {
      print("✅ No new records to sync.");
      return;
    }

    for (var row in localData) {
      final auto = int.tryParse(row['auto'].toString()) ?? 0;

      final checkQuery = "SELECT COUNT(*) AS count FROM RV_Particulars WHERE auto = $auto";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      int existingCount = 0;
      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          existingCount = decodedCheck.first['count'] ?? 0;
        }
      }

      if (existingCount > 0) {
        print("⚠️ Skipping duplicate record: Auto $auto already exists in MSSQL.");
        continue;
      }

      // 4️⃣ Insert new record
      final entryNo = int.tryParse(row['EntryNo'].toString()) ?? 0;
      final name = int.tryParse(row['Name'].toString()) ?? 0;
      final amount = double.tryParse(row['Amount'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final narration = row['Narration'].toString().replaceAll("'", "''");
      final ddate = row['ddate'].toString();
      final fyid = row['FyID'].toString();
      final fmid = row['FrmID'].toString();

      final insertQuery = '''
  SET IDENTITY_INSERT RV_Particulars ON;
  INSERT INTO RV_Particulars (auto, EntryNo, Name, Amount, Discount, Total, Narration, ddate, FyID, FrmID)
  VALUES (
    $auto,
    $entryNo,
    $name, 
    $amount, 
    $discount, 
    $total, 
    '$narration', 
    '$ddate',
    '$fyid',
    '$fmid'
  );
  SET IDENTITY_INSERT RV_Particulars OFF;
''';
      await MsSQLConnectionPlatform.instance.writeData(insertQuery);
      print("✅ Inserted new record: Auto $auto, Name $name, Date $ddate");
    }

    print("✅ Sync completed successfully!");

  } catch (e) {
    print("❌ Error syncing RV_Particulars to MSSQL: $e");
  }
}


Future<void> syncPVParticularsToMSSQL() async {
  try {
    final lastRowQuery = "SELECT TOP 1 auto FROM PV_Particulars ORDER BY auto DESC";
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastMssqlAuto = 0;

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastMssqlAuto = (decodedLastRow.first['auto'] ?? 0) as int;
      }
    }

    final localData = await PV_DatabaseHelper.instance.fetchNewPVParticulars(lastMssqlAuto);
    if (localData.isEmpty) {
      print(" No new records to sync.");
      return;
    }

    for (var row in localData) {
      final auto = int.tryParse(row['auto'].toString()) ?? 0;

      final checkQuery = "SELECT COUNT(*) AS count FROM PV_Particulars WHERE auto = $auto";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      int existingCount = 0;
      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          existingCount = decodedCheck.first['count'] ?? 0;
        }
      }

      if (existingCount > 0) {
        print(" Skipping duplicate record: Auto $auto already exists in MSSQL.");
        continue;
      }
      final entryNo = int.tryParse(row['EntryNo'].toString()) ?? 0;
      final name = int.tryParse(row['Name'].toString()) ?? 0;
      final amount = double.tryParse(row['Amount'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final narration = row['Narration'].toString().replaceAll("'", "''");
      final ddate = row['ddate'].toString();
      final fyid = row['FyID'].toString();
      final fmid = row['FrmID'].toString();

      final insertQuery = '''
  SET IDENTITY_INSERT PV_Particulars ON;
  INSERT INTO PV_Particulars (auto, EntryNo, Name, Amount, Discount, Total, Narration, ddate, FyID, FrmID)
  VALUES (
    $auto,
    $entryNo,
    $name, 
    $amount, 
    $discount, 
    $total, 
    '$narration', 
    '$ddate',
    '$fyid',
    '$fmid'
  );
  SET IDENTITY_INSERT PV_Particulars OFF;
''';
      await MsSQLConnectionPlatform.instance.writeData(insertQuery);
      print(" Inserted new record: Auto $auto, Name $name, Date $ddate");
    }

    print(" Sync completed successfully!");

  } catch (e) {
    print(" Error syncing PV_Particulars to MSSQL: $e");
  }
}




Future<void> syncPVInformationToMSSQL() async {
  try {
    final lastRowQuery = "SELECT TOP 1 RealEntryNo FROM PV_Information ORDER BY RealEntryNo DESC";
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastMssqlAuto = 0;

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastMssqlAuto = (decodedLastRow.first['RealEntryNo'] ?? 0) as int;
      }
    }

    final localData = await PV_DatabaseHelper.instance.fetchNewPVInformation(lastMssqlAuto);
    if (localData.isEmpty) {
      print(" No new records to sync.");
      return;
    }

    for (var row in localData) {
      final realEntryNo = int.tryParse(row['RealEntryNo'].toString()) ?? 0;

      final checkQuery = "SELECT COUNT(*) AS count FROM PV_Information WHERE RealEntryNo = $realEntryNo";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      int existingCount = 0;
      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          existingCount = decodedCheck.first['count'] ?? 0;
        }
      }

      if (existingCount > 0) {
        print("Skipping duplicate record: Auto $realEntryNo already exists in MSSQL.");
        continue;
      }
      final ddate = row['DDATE'].toString();
      final amount = double.tryParse(row['AMOUNT'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final creditAccount = row['CreditAccount'].toString().replaceAll("'", "''");
      final takeuser = row['takeuser'].toString().replaceAll("'", "''");
      final location = int.tryParse(row['Location'].toString()) ?? 0;
      final project = int.tryParse(row['Project'].toString()) ?? 0;
      final salesMan = int.tryParse(row['SalesMan'].toString()) ?? 0;
      final monthDate = row['MonthDate'].toString();
      final app = int.tryParse(row['app'].toString()) ?? 0;
      final transferStatus = int.tryParse(row['Transfer_Status'].toString()) ?? 0;
      final fyID = int.tryParse(row['FyID'].toString()) ?? 0;
      final entryNo = int.tryParse(row['EntryNo'].toString()) ?? 0;
      final frmID = int.tryParse(row['FrmID'].toString()) ?? 0;
      final pviCurrency = int.tryParse(row['pviCurrency'].toString()) ?? 0;
      final pviCurrencyValue = double.tryParse(row['pviCurrencyValue'].toString()) ?? 0.0;
      final pdate = row['pdate'].toString();

      final insertQuery = '''
  SET IDENTITY_INSERT PV_Information ON;
  INSERT INTO PV_Information (RealEntryNo, DDATE, AMOUNT, Discount, Total, CreditAccount, takeuser, Location, 
          Project, SalesMan, MonthDate, app, Transfer_Status, FyID, EntryNo, FrmID, 
          pviCurrency, pviCurrencyValue, pdate)
  VALUES (
    $realEntryNo, '$ddate', $amount, $discount, $total, '$creditAccount', '$takeuser', 
          $location, $project, $salesMan, '$monthDate', $app, $transferStatus, $fyID, 
          $entryNo, $frmID, $pviCurrency, $pviCurrencyValue, '$pdate'
  );
  SET IDENTITY_INSERT PV_Information OFF;
''';
      await MsSQLConnectionPlatform.instance.writeData(insertQuery);
      print(" Inserted new record: Auto $realEntryNo, Date $ddate");
    }

    print(" Sync completed successfully!");

  } catch (e) {
    print(" Error syncing PV_Information to MSSQL: $e");
  }
}




Future<void> syncSalesParticularsToMSSQL() async {
   try {
    final lastRowQuery = "SELECT TOP 1 Auto FROM Sales_Particulars ORDER BY Auto DESC";
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastMssqlAuto = 0;

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastMssqlAuto = (decodedLastRow.first['Auto'] ?? 0) as int;
      }
    }

    final localData = await SalesInformationDatabaseHelper2.instance.fetchNewSaleParticulars(lastMssqlAuto);
    if (localData.isEmpty) {
      print(" No new records to sync.");
      return;
    }

    for (var row in localData) {
      final auto = int.tryParse(row['Auto'].toString()) ?? 0;

      final checkQuery = "SELECT COUNT(*) AS count FROM Sales_Particulars WHERE Auto = $auto";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      int existingCount = 0;
      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          existingCount = decodedCheck.first['count'] ?? 0;
        }
      }
      if (existingCount > 0) {
        print("Skipping duplicate record: Auto $auto already exists in MSSQL.");
        continue;
      }
      final ddate = row['DDate'].toString();
      final entryNo = int.tryParse(row['EntryNo'].toString()) ?? 0;
      final uniqueCode = row['UniqueCode'] ?? 0;
      final itemID = row['ItemID'] ?? 0;
      final serialNo = row['serialno']?.toString().replaceAll("'", "''") ?? '';
      final rate = double.tryParse(row['Rate'].toString()) ?? 0.0;
      final realRate = double.tryParse(row['RealRate'].toString()) ?? 0.0;
      final qty = double.tryParse(row['Qty'].toString()) ?? 0.0;
      final freeQty = double.tryParse(row['freeQty'].toString()) ?? 0.0;
      final grossValue = double.tryParse(row['GrossValue'].toString()) ?? 0.0;
      final discPercent = double.tryParse(row['DiscPersent'].toString()) ?? 0.0;
      final disc = double.tryParse(row['Disc'].toString()) ?? 0.0;
      final rDisc = double.tryParse(row['RDisc'].toString()) ?? 0.0;
      final net = double.tryParse(row['Net'].toString()) ?? 0.0;
      final vat = double.tryParse(row['Vat'].toString()) ?? 0.0;
      final freeVat = double.tryParse(row['freeVat'].toString()) ?? 0.0;
      final cess = double.tryParse(row['cess'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final profit = double.tryParse(row['Profit'].toString()) ?? 0.0;
      final auto2 = double.tryParse(row['Auto'].toString()) ?? 0.0;
      final unit = row['Unit'] ?? 0;
      final unitValue = double.tryParse(row['UnitValue'].toString()) ?? 0.0;
      final funit = row['Funit'] ?? 0;
      final fValue = row['FValue'] ?? 0;
      final commission = double.tryParse(row['commision'].toString()) ?? 0.0;
      final gridID = row['GridID'] ?? 0;
      final takePrintStatus = row['takeprintstatus']?.toString().replaceAll("'", "''") ?? '';
      final qtyDiscPercent = double.tryParse(row['QtyDiscPercent'].toString()) ?? 0.0;
      final qtyDiscount = double.tryParse(row['QtyDiscount'].toString()) ?? 0.0;
      final scheemDiscPercent = double.tryParse(row['ScheemDiscPercent'].toString()) ?? 0.0;
      final scheemDiscount = double.tryParse(row['ScheemDiscount'].toString()) ?? 0.0;
      final cgst = double.tryParse(row['CGST'].toString()) ?? 0.0;
      final sgst = double.tryParse(row['SGST'].toString()) ?? 0.0;
      final igst = double.tryParse(row['IGST'].toString()) ?? 0.0;
      final adcess = double.tryParse(row['adcess'].toString()) ?? 0.0;
      final netdisc = double.tryParse(row['netdisc'].toString()) ?? 0.0;
      final taxrate = row['taxrate'] ?? 0;
      final salesmanId = row['SalesmanId']?.toString().replaceAll("'", "''") ?? '';
      final fcess = double.tryParse(row['Fcess'].toString()) ?? 0.0;
      final prate = double.tryParse(row['Prate'].toString()) ?? 0.0;
      final rprate = double.tryParse(row['Rprate'].toString()) ?? 0.0;
      final location = row['location'] ?? 0;
      final stype = row['Stype'] ?? 0;
      final lc = double.tryParse(row['LC'].toString()) ?? 0.0;
      final scanBarcode = row['ScanBarcode']?.toString().replaceAll("'", "''") ?? '';
      final remark = row['Remark']?.toString().replaceAll("'", "''") ?? '';
      final fyID = row['FyID'] ?? 0;
      final supplier = row['Supplier']?.toString().replaceAll("'", "''") ?? '';
      final retail = double.tryParse(row['Retail'].toString()) ?? 0.0;
      final spretail = double.tryParse(row['spretail'].toString()) ?? 0.0;
      final wsrate = double.tryParse(row['wsrate'].toString()) ?? 0.0;

 final insertQuery = '''
  INSERT INTO Sales_Particulars (
    DDate,EntryNo ,UniqueCode ,ItemID , serialno, Rate, RealRate, Qty, freeQty, GrossValue, DiscPersent, Disc, RDisc, Net, 
    Vat, freeVat, cess, Total, Profit, UnitValue, FValue, commision, 
    QtyDiscPercent, QtyDiscount, ScheemDiscPercent, ScheemDiscount, CGST, 
    SGST, IGST, adcess, netdisc, taxrate,Fcess, Prate, Rprate,location, Stype,LC,FyID, Retail, spretail, wsrate
  ) VALUES (
    ${formatDate(ddate)},
   ${parseDouble(entryNo)},
   ${parseDouble(uniqueCode)},
   ${parseDouble(itemID)}, 
   ${parseDouble(serialNo)},
    ${parseDouble(rate)}, 
    ${parseDouble(realRate)}, 
    ${parseDouble(qty)}, 
    ${parseDouble(freeQty)}, 
    ${parseDouble(grossValue)}, 
    ${parseDouble(discPercent)}, 
    ${parseDouble(disc)}, 
    ${parseDouble(rDisc)}, 
    ${parseDouble(net)}, 
    ${parseDouble(vat)}, 
    ${parseDouble(freeVat)}, 
    ${parseDouble(cess)}, 
    ${parseDouble(total)}, 
    ${parseDouble(profit)}, 
    ${parseDouble(unitValue)}, 
    ${parseDouble(fValue)}, 
    ${parseDouble(commission)}, 
    ${parseDouble(qtyDiscPercent)}, 
    ${parseDouble(qtyDiscount)}, 
    ${parseDouble(scheemDiscPercent)}, 
    ${parseDouble(scheemDiscount)}, 
    ${parseDouble(cgst)}, 
    ${parseDouble(sgst)}, 
    ${parseDouble(igst)}, 
    ${parseDouble(adcess)}, 
    ${parseDouble(netdisc)}, 
    ${parseDouble(taxrate)},
    ${parseDouble(fcess)}, 
    ${parseDouble(prate)}, 
    ${parseDouble(rprate)}, 
    ${parseDouble(location)},
    ${parseDouble(stype)},
    ${parseDouble(lc)}, 
    ${parseDouble(fyID)},
    ${parseDouble(retail)}, 
    ${parseDouble(spretail)}, 
    ${parseDouble(wsrate)}
  );
''';



      await MsSQLConnectionPlatform.instance.writeData(insertQuery);
      print(" Inserted new record: Auto $auto");
    }

    print(" Sync completed successfully!");

  } catch (e) {
    print(" Error syncing Sales_Particulars to MSSQL: $e");
  }
}


String parseString(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) {
    return "''";  
  }
  return "'${value.toString().replaceAll("'", "''")}'";  
}
String formatDate(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return "NULL";  
  try {
    String dateString = value.toString().trim();
    RegExp regex = RegExp(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})');
    Match? match = regex.firstMatch(dateString);

    if (match != null) {
      dateString = match.group(1)!; 
    }

    DateTime date = DateTime.parse(dateString);
    return "'${date.toIso8601String().split('T').join(' ')}'";
  } catch (e) {
    print("Error parsing date: $value - $e");
    return "NULL";
  }
}
double parseDouble(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) {
    return 0.0; 
  }
  return double.tryParse(value.toString()) ?? 0.0;
}

Future<void> syncSalesInformationToMSSQL2() async {
  try {
    final lastRowQuery = "SELECT TOP 1 RealEntryNo FROM Sales_Information ORDER BY RealEntryNo DESC";
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastMssqlAuto = 0;

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastMssqlAuto = (decodedLastRow.first['RealEntryNo'] ?? 0) as int;
      }
    }

    final localData = await SalesInformationDatabaseHelper2.instance.fetchNewSaleInformation(lastMssqlAuto);
    if (localData.isEmpty) {
      print(" No new records to sync.");
      return;
    }

    for (var row in localData) {
      final auto = int.tryParse(row['RealEntryNo'].toString()) ?? 0;

      final checkQuery = "SELECT COUNT(*) AS count FROM Sales_Information WHERE RealEntryNo = $auto";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      int existingCount = 0;
      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          existingCount = decodedCheck.first['count'] ?? 0;
        }
      }
      if (existingCount > 0) {
        print("Skipping duplicate record: RealEntryNo $auto already exists in MSSQL.");
        continue;
      }
      final realEntryNo = row['RealEntryNo'].toString();
      final entryNo = int.tryParse(row['EntryNo'].toString()) ?? 0;
      final invoiceNo = row['InvoiceNo'] ?? 0;
      final ddate = row['DDate'] ?? 0;
      final btime = row['BTime']?.toString().replaceAll("'", "''") ?? '';
      final  Customer= double.tryParse(row['Customer'].toString()) ?? 0.0;
      final add1 = double.tryParse(row['Add1'].toString()) ?? 0.0;
      final add2 = double.tryParse(row['Add2'].toString()) ?? 0.0;
      final toname = double.tryParse(row['Toname'].toString()) ?? 0.0;
      final taxtype = double.tryParse(row['TaxType'].toString()) ?? 0.0;
      final grossValue = double.tryParse(row['GrossValue'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final netamt = double.tryParse(row['NetAmount'].toString()) ?? 0.0;
      final cess = double.tryParse(row['cess'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final  loadingcharge= double.tryParse(row['loadingcharge'].toString()) ?? 0.0;
      final otherCharges = double.tryParse(row['OtherCharges'].toString()) ?? 0.0;
      final otherDiscount = double.tryParse(row['OtherDiscount'].toString()) ?? 0.0;
      final roundoff = double.tryParse(row['Roundoff'].toString()) ?? 0.0;
      final grandTotal = double.tryParse(row['GrandTotal'].toString()) ?? 0.0;
      final salesAccount = row['SalesAccount'] ?? 0;
      final salesMan = double.tryParse(row['SalesMan'].toString()) ?? 0.0;
      final location = row['Location'] ?? 0;
      final narration = row['Narration'] ?? 0;
      final profit = double.tryParse(row['Profit'].toString()) ?? 0.0;
      final cashReceived = row['CashReceived'] ?? 0;
      final balanceAmount = row['BalanceAmount']?.toString().replaceAll("'", "''") ?? '';
      final ecommision = double.tryParse(row['Ecommision'].toString()) ?? 0.0;
      final labourCharge = double.tryParse(row['labourCharge'].toString()) ?? 0.0;
      final otherAmount = double.tryParse(row['OtherAmount'].toString()) ?? 0.0;
      final type = double.tryParse(row['Type'].toString()) ?? 0.0;
      final printStatus = double.tryParse(row['PrintStatus'].toString()) ?? 0.0;
      final cno = double.tryParse(row['CNo'].toString()) ?? 0.0;
      final creditPeriod = double.tryParse(row['CreditPeriod'].toString()) ?? 0.0;
      final discPercent = double.tryParse(row['DiscPercent'].toString()) ?? 0.0;
      final sType = double.tryParse(row['SType'].toString()) ?? 0.0;
      final vatEntryNo = row['VatEntryNo'] ?? 0;
      final cardno = row['cardno']?.toString().replaceAll("'", "''") ?? '';
      final takeuser = double.tryParse(row['takeuser'].toString()) ?? 0.0;
      final purchaseOrderNo = double.tryParse(row['PurchaseOrderNo'].toString()) ?? 0.0;
      final ddate1 = double.tryParse(row['ddate1'].toString()) ?? 0.0;
      final despatchdate = row['despatchdate'] ?? 0;
      final add3 = row['Add3'] ?? 0;
      final add4 = double.tryParse(row['Add4'].toString()) ?? 0.0;
      final cgst = row['CGST']?.toString().replaceAll("'", "''") ?? '';
      final sgst = row['SGST']?.toString().replaceAll("'", "''") ?? '';
      final igst = row['IGST'] ?? 0;
      final receiptDate = row['receiptDate']?.toString().replaceAll("'", "''") ?? '';
      final totalQty = double.tryParse(row['TotalQty'].toString()) ?? 0.0;
      final fyID = double.tryParse(row['FyID'].toString()) ?? 0.0;
      final m_invoiceno = double.tryParse(row['m_invoiceno'].toString()) ?? 0.0;

 final insertQuery = '''
  INSERT INTO Sales_Information (
    EntryNo ,InvoiceNo ,DDate ,BTime, Customer, Add1, Add2, Toname, TaxType, GrossValue, Discount, NetAmount, cess, 
    Total, loadingcharge, OtherCharges, OtherDiscount, Roundoff,GrandTotal, SalesAccount, SalesMan, Location,Narration, Profit,
    CashReceived, BalanceAmount, Ecommision, labourCharge, OtherAmount,Type,PrintStatus,CNo,CreditPeriod,DiscPercent,SType,VatEntryNo, 
     cardno, takeuser, PurchaseOrderNo,ddate1,despatchdate, Add3,Add4,CGST, SGST, IGST, receiptDate,
    TotalQty,FyID,m_invoiceno
  ) VALUES (     
    ${parseDouble(entryNo)},
    ${parseDouble(invoiceNo)},
    ${formatDate(ddate)}, 
    ${formatDate(btime)},
    ${parseDouble(Customer)}, 
    ${parseString(add1)}, 
    ${parseString(add2)}, 
    ${parseString(toname)},
    ${parseString(taxtype)}, 
    ${parseDouble(grossValue)}, 
    ${parseDouble(discount)}, 
    ${parseDouble(netamt)}, 
    ${parseDouble(cess)}, 
    ${parseDouble(total)}, 
    ${parseDouble(loadingcharge)}, 
    ${parseDouble(otherCharges)}, 
    ${parseDouble(otherDiscount)}, 
    ${parseDouble(roundoff)}, 
    ${parseDouble(grandTotal)},
    ${parseDouble(salesAccount)}, 
    ${parseDouble(salesMan)}, 
    ${parseDouble(location)}, 
    ${parseString(narration)}, 
    ${parseDouble(profit)}, 
    ${parseDouble(cashReceived)}, 
    ${parseDouble(balanceAmount)}, 
    ${parseDouble(ecommision)}, 
    ${parseDouble(labourCharge)}, 
    ${parseDouble(otherAmount)}, 
    ${parseDouble(type)}, 
    ${parseDouble(printStatus)}, 
    ${parseDouble(cno)},
    ${parseDouble(creditPeriod)}, 
    ${parseDouble(discPercent)}, 
    ${parseDouble(sType)}, 
    ${parseDouble(vatEntryNo)},
    ${parseDouble(cardno)},
    ${parseDouble(takeuser)}, 
    ${parseDouble(purchaseOrderNo)},
    ${parseDouble(ddate1)}, 
    ${parseDouble(despatchdate)}, 
    ${parseString(add3)},
    ${parseString(add4)}, 
    ${parseDouble(cgst)}, 
    ${parseDouble(sgst)}, 
    ${parseDouble(igst)}, 
    ${parseDouble(receiptDate)}, 
    ${parseDouble(totalQty)},
    ${parseDouble(fyID)}, 
    ${parseDouble(m_invoiceno)} 
    
  );
''';



      await MsSQLConnectionPlatform.instance.writeData(insertQuery);
      print(" Inserted new record: RealEntryNo $auto");
    }

    print(" Sync completed successfully!");

  } catch (e) {
    print(" Error syncing Sales_Information to MSSQL: $e");
  }
}
Future<void> syncledgerToMSSQL(Map<String, dynamic> transaction) async {
 try {
    final lastRowQuery = "SELECT TOP 1 RealEntryNo FROM Sales_Information ORDER BY RealEntryNo DESC";
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastMssqlAuto = 0;

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastMssqlAuto = (decodedLastRow.first['RealEntryNo'] ?? 0) as int;
      }
    }

    final localData = await SalesInformationDatabaseHelper2.instance.fetchNewSaleInformation(lastMssqlAuto);
    if (localData.isEmpty) {
      print(" No new records to sync.");
      return;
    }

    for (var row in localData) {
      final auto = int.tryParse(row['RealEntryNo'].toString()) ?? 0;

      final checkQuery = "SELECT COUNT(*) AS count FROM Sales_Information WHERE RealEntryNo = $auto";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      int existingCount = 0;
      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          existingCount = decodedCheck.first['count'] ?? 0;
        }
      }
      if (existingCount > 0) {
        print("Skipping duplicate record: RealEntryNo $auto already exists in MSSQL.");
        continue;
      }
      final Ledcode = row['Ledcode'].toString();
      final LedName = int.tryParse(row['LedName'].toString()) ?? 0;
      final ih_id = row['lh_id'] ?? 0;
      final add1 = row['add1'] ?? 0;
      final add2 = row['add2']?.toString().replaceAll("'", "''") ?? '';
      final  add3= double.tryParse(row['add3'].toString()) ?? 0.0;
      final add4 = double.tryParse(row['add4'].toString()) ?? 0.0;
      final city = double.tryParse(row['city'].toString()) ?? 0.0;
      final route = double.tryParse(row['route'].toString()) ?? 0.0;
      final state = double.tryParse(row['state'].toString()) ?? 0.0;
      final mobile = double.tryParse(row['Mobile'].toString()) ?? 0.0;
      final pan = double.tryParse(row['pan'].toString()) ?? 0.0;
      final email = double.tryParse(row['Email'].toString()) ?? 0.0;
      final gstno = double.tryParse(row['gstno'].toString()) ?? 0.0;
      final cAmount = double.tryParse(row['CAmount'].toString()) ?? 0.0;
      final  active= double.tryParse(row['Active'].toString()) ?? 0.0;
      final salesMan = double.tryParse(row['SalesMan'].toString()) ?? 0.0;
      final location = double.tryParse(row['Location'].toString()) ?? 0.0;
      final orderDate = double.tryParse(row['OrderDate'].toString()) ?? 0.0;
      final deliveryDate = double.tryParse(row['DeliveryDate'].toString()) ?? 0.0;
      final cPerson = row['CPerson'] ?? 0;
      final costCenter = double.tryParse(row['CostCenter'].toString()) ?? 0.0;
      final franchisee = row['Franchisee'] ?? 0;
      final salesRate = row['SalesRate'] ?? 0;
      final subGroup = double.tryParse(row['SubGroup'].toString()) ?? 0.0;
      final secondName = row['SecondName'] ?? 0;
      final userName = row['UserName']?.toString().replaceAll("'", "''") ?? '';
      final password = double.tryParse(row['Password'].toString()) ?? 0.0;
      final customerType = double.tryParse(row['CustomerType'].toString()) ?? 0.0;
      final oTP = double.tryParse(row['OTP'].toString()) ?? 0.0;
      final maxDiscount = double.tryParse(row['maxDiscount'].toString()) ?? 0.0;
      
 final insertQuery = '''
  INSERT INTO Sales_Information (
    Ledcode, LedName, lh_id, add1, add2, add3, add4, city, route, state,
    Mobile, pan, Email, gstno, CAmount, Active, SalesMan, Location,
    OrderDate, DeliveryDate, CPerson, CostCenter, Franchisee, SalesRate,
    SubGroup, SecondName, UserName, Password, CustomerType, OTP, maxDiscount
  ) VALUES (     
    ${parseDouble(Ledcode)},
    ${parseDouble(LedName)},
    ${formatDate(ih_id)}, 
    ${formatDate(add1)},
    ${parseDouble(add2)}, 
    ${parseString(add3)}, 
    ${parseString(add4)}, 
    ${parseString(city)},
    ${parseString(route)}, 
    ${parseDouble(state)}, 
    ${parseDouble(mobile)}, 
    ${parseDouble(pan)}, 
    ${parseDouble(email)}, 
    ${parseDouble(gstno)}, 
    ${parseDouble(cAmount)}, 
    ${parseDouble(active)}, 
    ${parseDouble(salesMan)}, 
    ${parseDouble(location)}, 
    ${parseDouble(orderDate)},
    ${parseDouble(deliveryDate)}, 
    ${parseDouble(cPerson)}, 
    ${parseDouble(costCenter)}, 
    ${parseString(franchisee)}, 
    ${parseDouble(salesRate)}, 
    ${parseDouble(subGroup)}, 
    ${parseDouble(secondName)}, 
    ${parseDouble(userName)}, 
    ${parseDouble(password)}, 
    ${parseDouble(customerType)}, 
    ${parseDouble(oTP)}, 
    ${parseDouble(maxDiscount)}, 
   
  );
''';



      await MsSQLConnectionPlatform.instance.writeData(insertQuery);
      print(" Inserted new record: RealEntryNo $auto");
    }

    print(" Sync completed successfully!");

  } catch (e) {
    print(" Error syncing Sales_Information to MSSQL: $e");
  }
}


Future<void> syncAccount_transactionToMSSQL() async {
 try {
    final lastRowQuery = "SELECT TOP 1 Auto FROM Account_Transactions ORDER BY Auto DESC";
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);
    int lastMssqlAuto = 0;
    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastMssqlAuto = (decodedLastRow.first['Auto'] ?? 0) as int;
      }
    }

    final localData = await LedgerTransactionsDatabaseHelper.instance.fetchNewAccount_Transactions(lastMssqlAuto);
    if (localData.isEmpty) {
      print(" No new records to sync.");
      return;
    }

    for (var row in localData) {
      final auto = int.tryParse(row['Auto'].toString()) ?? 0;

      final checkQuery = "SELECT COUNT(*) AS count FROM Account_Transactions WHERE Auto = $auto";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      int existingCount = 0;
      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          existingCount = decodedCheck.first['count'] ?? 0;
        }
      }
      if (existingCount > 0) {
        print("Skipping duplicate record: Auto $auto already exists in MSSQL.");
        continue;
      }
      final atDate = row['atDate'].toString();
      final atLedCode = int.tryParse(row['atLedCode'].toString()) ?? 0;
      final atType = row['atType'] ?? 0;
      final atEntryno = row['atEntryno'] ?? 0;
      final atDebitAmount = row['atDebitAmount']?.toString().replaceAll("'", "''") ?? '';
      final  atCreditAmount= double.tryParse(row['atCreditAmount'].toString()) ?? 0.0;
      final atNarration = double.tryParse(row['atNarration'].toString()) ?? 0.0;
      final atOpposite = double.tryParse(row['atOpposite'].toString()) ?? 0.0;
      final atSalesEntryno = double.tryParse(row['atSalesEntryno'].toString()) ?? 0.0;
      final atSalesType = double.tryParse(row['atSalesType'].toString()) ?? 0.0;
      final atLocation = double.tryParse(row['atLocation'].toString()) ?? 0.0;
      final atChequeNo = double.tryParse(row['atChequeNo'].toString()) ?? 0.0;
      final atProject = double.tryParse(row['atProject'].toString()) ?? 0.0;
      final atBankEntry = double.tryParse(row['atBankEntry'].toString()) ?? 0.0;
      final atInvestor = double.tryParse(row['atInvestor'].toString()) ?? 0.0;
      final  atFyID= double.tryParse(row['atFyID'].toString()) ?? 0.0;
      final atFxDebit = double.tryParse(row['atFxDebit'].toString()) ?? 0.0;
      final atFxCredit = double.tryParse(row['atFxCredit'].toString()) ?? 0.0;
     
    final insertQuery = '''
    INSERT INTO Account_Transactions (
    atDate, atLedCode, atType, atEntryno, atDebitAmount, atCreditAmount, atNarration, atOpposite, 
    atSalesEntryno, atSalesType, atLocation, atChequeNo, atProject, atBankEntry, atInvestor, atFyID,
    atFxDebit, atFxCredit
  ) VALUES ( 
   
    ${formatDate(atDate)},
    ${parseDouble(atLedCode)},
    ${parseString(atType)}, 
    ${formatDate(atEntryno)},
    ${parseDouble(atDebitAmount)}, 
    ${parseDouble(atCreditAmount)}, 
    ${parseString(atNarration)}, 
    ${parseDouble(atOpposite)},
    ${parseDouble(atSalesEntryno)}, 
    ${parseString(atSalesType)}, 
    ${parseDouble(atLocation)}, 
    ${parseDouble(atChequeNo)}, 
    ${parseDouble(atProject)}, 
    ${parseDouble(atBankEntry)}, 
    ${parseDouble(atInvestor)}, 
    ${parseDouble(atFyID)}, 
    ${parseDouble(atFxDebit)}, 
    ${parseDouble(atFxCredit)}, 
   
  );
''';
      await MsSQLConnectionPlatform.instance.writeData(insertQuery);
      print(" Inserted new record: Auto $auto");
    }

    print(" Sync completed successfully!");

  } catch (e) {
    print(" Error syncing Account_Transactions to MSSQL: $e");
  }
}

bool _isDateString(String value) {
  final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$|^\d{4}-\d{2}-\d{2}$');
  return datePattern.hasMatch(value);
}

String _convertToSQLDate(String inputDate) {
  try {
    DateTime parsedDate;

    if (inputDate.contains("/")) {
      parsedDate = DateFormat("dd/MM/yyyy").parse(inputDate);
    } else if (inputDate.contains("-")) {
      parsedDate = DateFormat("yyyy-MM-dd").parse(inputDate);
    } else {
      return 'NULL'; 
    }

    return "'${DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDate)}'";
  } catch (e) {
    print("Date conversion error: $e for input: $inputDate");
    return 'NULL'; 
  }
}

bool _isDateColumn(String columnName) {
  List<String> dateColumns = ["DDate","BTime","ddate1", "despatchdate", "receiptDate"]; // Add your date column names here
  return dateColumns.contains(columnName);
}

Future<void> syncStockQtyToMSSQL() async {
  try {
    final localData = await StockDatabaseHelper.instance.getAllProducts();
    
    final fetchQuery = "SELECT Uniquecode, ItemId, Qty FROM stock";
    final fetchResult = await MsSQLConnectionPlatform.instance.getData(fetchQuery);

    if (fetchResult is! String) {
      print("Failed to fetch stock data from MSSQL.");
      return;
    }

    final decodedFetch = jsonDecode(fetchResult);
    if (decodedFetch is! List) {
      print(" Invalid MSSQL stock data format.");
      return;
    }

    final Map<String, Map<String, dynamic>> mssqlStockMap = {
      for (var row in decodedFetch)
        "${row['Uniquecode']}_${row['ItemId']}": {
          "Qty": double.tryParse(row['Qty'].toString()) ?? 0.0
        }
    };

    for (var row in localData) {
      final itemId = row['ItemId'].toString();
      final uniqueCode = row['id'].toString(); 
      final localQty = double.tryParse(row['Qty'].toString()) ?? 0.0;
      final lookupKey = "${uniqueCode}_$itemId";

      final mssqlQty = mssqlStockMap[lookupKey]?['Qty'] ?? 0.0;

      if (localQty != mssqlQty) { 
        final updateQuery = '''
          UPDATE stock 
          SET Qty = $localQty
          WHERE Uniquecode = '$uniqueCode' AND ItemId = '$itemId'
        ''';
        print("Updating Qty for ItemId: $itemId | Uniquecode: $uniqueCode from $mssqlQty to $localQty");
        await MsSQLConnectionPlatform.instance.writeData(updateQuery);
      } else {
        print(" No change for ItemId: $itemId (Qty remains $mssqlQty)");
      }
    }
    
  } catch (e) {
    print("Error syncing Stock Qty to MSSQL: $e");
  }
}





}