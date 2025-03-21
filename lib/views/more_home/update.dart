import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
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
        print("⚠️ Skipping duplicate record: Auto $auto already exists in MSSQL.");
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
    DDate, EntryNo, UniqueCode, ItemID, serialno, Rate, RealRate, Qty, freeQty, 
    GrossValue, DiscPersent, Disc, RDisc, Net, Vat, freeVat, cess, Total, Profit, 
    Unit, UnitValue, Funit, FValue, commision, GridID, takeprintstatus, 
    QtyDiscPercent, QtyDiscount, ScheemDiscPercent, ScheemDiscount, CGST, SGST, 
    IGST, adcess, netdisc, taxrate, SalesmanId, Fcess, Prate, Rprate, location, 
    Stype, LC, ScanBarcode, Remark, FyID, Supplier, Retail, spretail, wsrate
  ) VALUES (
    '$ddate', 
    ${int.tryParse(entryNo.toString()) ?? 0}, 
    '$uniqueCode', 
    ${int.tryParse(itemID.toString()) ?? 0}, 
    '$serialNo', 
    ${double.tryParse(rate.toString()) ?? 0.0}, 
    ${double.tryParse(realRate.toString()) ?? 0.0}, 
    ${double.tryParse(qty.toString()) ?? 0.0}, 
    ${double.tryParse(freeQty.toString()) ?? 0.0}, 
    ${double.tryParse(grossValue.toString()) ?? 0.0}, 
    ${double.tryParse(discPercent.toString()) ?? 0.0}, 
    ${double.tryParse(disc.toString()) ?? 0.0}, 
    ${double.tryParse(rDisc.toString()) ?? 0.0}, 
    ${double.tryParse(net.toString()) ?? 0.0}, 
    ${double.tryParse(vat.toString()) ?? 0.0}, 
    ${double.tryParse(freeVat.toString()) ?? 0.0}, 
    ${double.tryParse(cess.toString()) ?? 0.0}, 
    ${double.tryParse(total.toString()) ?? 0.0}, 
    ${double.tryParse(profit.toString()) ?? 0.0}, 
    '$unit', 
    ${double.tryParse(unitValue.toString()) ?? 0.0}, 
    '$funit', 
    ${double.tryParse(fValue.toString()) ?? 0.0}, 
    ${double.tryParse(commission.toString()) ?? 0.0}, 
    ${int.tryParse(gridID.toString()) ?? 0}, 
    '$takePrintStatus', 
    ${double.tryParse(qtyDiscPercent.toString()) ?? 0.0}, 
    ${double.tryParse(qtyDiscount.toString()) ?? 0.0}, 
    ${double.tryParse(scheemDiscPercent.toString()) ?? 0.0}, 
    ${double.tryParse(scheemDiscount.toString()) ?? 0.0}, 
    ${double.tryParse(cgst.toString()) ?? 0.0}, 
    ${double.tryParse(sgst.toString()) ?? 0.0}, 
    ${double.tryParse(igst.toString()) ?? 0.0}, 
    ${double.tryParse(adcess.toString()) ?? 0.0}, 
    ${double.tryParse(netdisc.toString()) ?? 0.0}, 
    ${int.tryParse(taxrate.toString()) ?? 0}, 
    '$salesmanId', 
    ${double.tryParse(fcess.toString()) ?? 0.0}, 
    ${double.tryParse(prate.toString()) ?? 0.0}, 
    ${double.tryParse(rprate.toString()) ?? 0.0}, 
    ${int.tryParse(location.toString()) ?? 0}, 
    '$stype', 
    ${double.tryParse(lc.toString()) ?? 0.0}, 
    '$scanBarcode', 
    '$remark', 
    ${int.tryParse(fyID.toString()) ?? 0}, 
    '$supplier', 
    ${double.tryParse(retail.toString()) ?? 0.0}, 
    ${double.tryParse(spretail.toString()) ?? 0.0}, 
    ${double.tryParse(wsrate.toString()) ?? 0.0}
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

Future<void> syncSalesInformationToMSSQL2() async {
   try {
    final lastRowQuery = "SELECT TOP 1 auto FROM PV_Particulars ORDER BY RealEntryNo DESC";
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastMssqlAuto = 0;

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastMssqlAuto = (decodedLastRow.first['RealEntryNo'] ?? 0) as int;
      }
    }

    final localData = await PV_DatabaseHelper.instance.fetchNewPVParticulars(lastMssqlAuto);
    if (localData.isEmpty) {
      print(" No new records to sync.");
      return;
    }

    for (var row in localData) {
      final auto = int.tryParse(row['RealEntryNo'].toString()) ?? 0;

      final checkQuery = "SELECT COUNT(*) AS count FROM PV_Particulars WHERE RealEntryNo = $auto";
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
bool _isDateString(String value) {
  final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$|^\d{4}-\d{2}-\d{2}$'); // Matches dd/MM/yyyy OR yyyy-MM-dd
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
    print("⚠️ Date conversion error: $e for input: $inputDate");
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
      print("❌ Failed to fetch stock data from MSSQL.");
      return;
    }

    final decodedFetch = jsonDecode(fetchResult);
    if (decodedFetch is! List) {
      print("❌ Invalid MSSQL stock data format.");
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
        print("🔄 Updating Qty for ItemId: $itemId | Uniquecode: $uniqueCode from $mssqlQty to $localQty");
        await MsSQLConnectionPlatform.instance.writeData(updateQuery);
      } else {
        print("✅ No change for ItemId: $itemId (Qty remains $mssqlQty)");
      }
    }
    
  } catch (e) {
    print("❌ Error syncing Stock Qty to MSSQL: $e");
  }
}





}