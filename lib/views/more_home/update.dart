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
    final localData = await RV_DatabaseHelper.instance.fetchRVInformation();

    for (var row in localData) {

      final realEntryNo = row['RealEntryNo'] ?? 0; 
      final ddate = row['DDATE'].toString();
      final amount = double.tryParse(row['AMOUNT'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final creditAccount = int.tryParse(row['DEBITACCOUNT'].toString()) ?? 0;

      final takeuser = row['takeuser'].toString().replaceAll("'", "''");
      final location = row['Location'] ?? 0;
      final project = row['Project'] ?? 0;
      final salesMan = row['SalesMan'] ?? 0;
      final monthDate = row['MonthDate'].toString();
      final app = row['app'] ?? 0;
      final transferStatus = row['Transfer_Status'] ?? 0;
      final fyID = row['FyID'] ?? 0;
      final entryNo = row['EntryNo'] ?? 0;
      final frmID = row['FrmID'] ?? 0;
      final pviCurrency = row['rviCurrency'] ?? 0;
      final pviCurrencyValue = row['rviCurrencyValue'] ?? 0;
      final pdate = row['pdate'].toString();
      final checkQuery = '''
        SELECT COUNT(*) AS count FROM RV_Information WHERE RealEntryNo = $realEntryNo
      ''';
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          final count = decodedCheck.first['count'] ?? 0;

          if (count > 0) {
            // **Update existing record**
            final updateQuery = '''
              UPDATE RV_Information 
              SET 
                DDATE = '$ddate',
                AMOUNT = $amount,
                Discount = $discount,
                Total = $total,
                DEBITACCOUNT = '$creditAccount',
                takeuser = '$takeuser',
                Location = $location,
                Project = $project,
                SalesMan = $salesMan,
                MonthDate = '$monthDate',
                app = $app,
                Transfer_Status = $transferStatus,
                FyID = $fyID,
                EntryNo = $entryNo,
                FrmID = $frmID,
                rviCurrency = $pviCurrency,
                rviCurrencyValue = $pviCurrencyValue,
                pdate = '$pdate'
              WHERE RealEntryNo = $realEntryNo
            ''';
            await MsSQLConnectionPlatform.instance.writeData(updateQuery);
            print("Updated RV_Information for RealEntryNo: $realEntryNo");
          } else {
           final insertQuery = '''
  SET IDENTITY_INSERT RV_Information ON;

  INSERT INTO RV_Information (
    RealEntryNo, DDATE, AMOUNT, Discount, Total, DEBITACCOUNT, takeuser, Location, 
    Project, SalesMan, MonthDate, app, Transfer_Status, FyID, EntryNo, FrmID, 
    rviCurrency, rviCurrencyValue, pdate
  ) VALUES (
    $realEntryNo, '$ddate', $amount, $discount, $total, '$creditAccount', '$takeuser', 
    $location, $project, $salesMan, '$monthDate', $app, $transferStatus, $fyID, 
    $entryNo, $frmID, $pviCurrency, $pviCurrencyValue, '$pdate'
  );

  SET IDENTITY_INSERT RV_Information OFF;
''';

            await MsSQLConnectionPlatform.instance.writeData(insertQuery);
            print("Inserted new record in RV_Information (RealEntryNo: $realEntryNo)");
          }
        }
      }
    }
  } catch (e) {
    print("Error syncing RV_Information to MSSQL: $e");
  }
}
Future<void> syncRVParticularsToMSSQL() async {
  try {
    final localData = await RV_DatabaseHelper.instance.fetchPVParticulars();

    final lastRowQuery = '''
      SELECT TOP 1 auto, ddate FROM RV_Particulars ORDER BY ddate DESC, auto DESC
    ''';
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastAuto = 0;
    String lastDdate = "";

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastAuto = (decodedLastRow.first['auto'] ?? 0) as int;
        lastDdate = decodedLastRow.first['ddate']?.toString() ?? "";
      }
    }

    for (var row in localData) {
      final auto = int.tryParse(row['auto'].toString()) ?? 0;
      final entryNo = double.tryParse(row['EntryNo'].toString()) ?? 0.0;
      final name = int.tryParse(row['Name'].toString()) ?? 0;
      final amount = double.tryParse(row['Amount'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final narration = row['Narration'].toString().replaceAll("'", "''");
      final ddate = row['ddate'].toString();
      final fyid = row['FyID'].toString();
      final fmid = row['FrmID'].toString();

      final checkQuery = "SELECT COUNT(*) AS count FROM RV_Particulars WHERE auto = $auto";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          final count = decodedCheck.first['count'] ?? 0;

          if (count > 0) {
            // Step 3: Update existing record
            final updateQuery = '''
              UPDATE RV_Particulars 
              SET 
                EntryNo = $entryNo, 
                Name = $name, 
                Amount = $amount, 
                Discount = $discount, 
                Total = $total, 
                Narration = '$narration', 
                ddate = '$ddate',
                FyID = '$fyid',
                FrmID = '$fmid'
              WHERE auto = $auto
            ''';
            await MsSQLConnectionPlatform.instance.writeData(updateQuery);
            print("Updated record: $auto");
          } else {
            // Step 4: Insert new record with auto incremented
            lastAuto += 1;

            final insertQuery = '''
SET IDENTITY_INSERT RV_Particulars ON;
              INSERT INTO RV_Particulars (auto, EntryNo, Name, Amount, Discount, Total, Narration, ddate, FyID, FrmID)
              VALUES (
                $lastAuto, 
                $entryNo,
                $name, 
                $amount, 
                $discount, 
                $total, 
                '$narration', 
                '$ddate',
                '$fyid' ,
                '$fmid' 
              );
              SET IDENTITY_INSERT RV_Particulars OFF;
            ''';
            await MsSQLConnectionPlatform.instance.writeData(insertQuery);
            print("Inserted new record with auto: $lastAuto");
          }
        }
      }
    }
  } catch (e) {
    print("Error syncing RV_Particulars to MSSQL: $e");
  }
}


Future<void> syncPVParticularsToMSSQL() async {
  try {
    final localData = await PV_DatabaseHelper.instance.fetchPVParticulars();
    final lastRowQuery = '''
      SELECT TOP 1 auto, EntryNo FROM PV_Particulars ORDER BY auto DESC
    ''';
    final lastRowResult = await MsSQLConnectionPlatform.instance.getData(lastRowQuery);

    int lastAuto = 0;
    int lastEntryNo = 0;

    if (lastRowResult is String) {
      final decodedLastRow = jsonDecode(lastRowResult);
      if (decodedLastRow is List && decodedLastRow.isNotEmpty) {
        lastAuto = (decodedLastRow.first['auto'] ?? 0) as int;
        lastEntryNo = ((decodedLastRow.first['EntryNo'] ?? 0) as num).toInt(); // ✅ Fixed conversion
      }
    }

    for (var row in localData) {
      final name = int.tryParse(row['Name'].toString()) ?? 0;
      final amount = double.tryParse(row['Amount'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final narration = row['Narration'].toString().replaceAll("'", "''");
      final ddate = row['ddate'].toString();
      final fyid = row['FyID'].toString();
      final fmid = row['FrmID'].toString();
      final checkQuery = "SELECT COUNT(*) AS count FROM PV_Particulars WHERE Name = $name AND ddate = '$ddate'";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          final count = decodedCheck.first['count'] ?? 0;

          if (count > 0) {
            final updateQuery = '''
              UPDATE PV_Particulars 
              SET 
                Amount = $amount, 
                Discount = $discount, 
                Total = $total, 
                Narration = '$narration',
                FyID = '$fyid',
                FrmID = '$fmid'
              WHERE Name = $name AND ddate = '$ddate'
            ''';
            await MsSQLConnectionPlatform.instance.writeData(updateQuery);
            print("Updated record for Name: $name and ddate: $ddate");
          } else {
            lastAuto += 1;
            lastEntryNo += 1;

            final insertQuery = '''
              SET IDENTITY_INSERT PV_Particulars ON;
              INSERT INTO PV_Particulars (auto, EntryNo, Name, Amount, Discount, Total, Narration, ddate, FyID, FrmID)
              VALUES (
                $lastAuto,
                $lastEntryNo,
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
            print("Inserted new record with auto: $lastAuto, EntryNo: $lastEntryNo");
          }
        }
      }
    }
  } catch (e) {
    print("Error syncing PV_Particulars to MSSQL: $e");
  }
}


Future<void> syncPVInformationToMSSQL() async {
  try {
    final localData = await PV_DatabaseHelper.instance.fetchPVInformation();

    for (var row in localData) {

      final realEntryNo = row['RealEntryNo'] ?? 0; 
      final ddate = row['DDATE'].toString();
      final amount = double.tryParse(row['AMOUNT'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final creditAccount = row['CreditAccount'].toString().replaceAll("'", "''");
      final takeuser = row['takeuser'].toString().replaceAll("'", "''");
      final location = row['Location'] ?? 0;
      final project = row['Project'] ?? 0;
      final salesMan = row['SalesMan'] ?? 0;
      final monthDate = row['MonthDate'].toString();
      final app = row['app'] ?? 0;
      final transferStatus = row['Transfer_Status'] ?? 0;
      final fyID = row['FyID'] ?? 0;
      final entryNo = row['EntryNo'] ?? 0;
      final frmID = row['FrmID'] ?? 0;
      final pviCurrency = row['pviCurrency'] ?? 0;
      final pviCurrencyValue = row['pviCurrencyValue'] ?? 0;
      final pdate = row['pdate'].toString();
      final checkQuery = '''
        SELECT COUNT(*) AS count FROM PV_Information WHERE RealEntryNo = $realEntryNo
      ''';
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          final count = decodedCheck.first['count'] ?? 0;

          if (count > 0) {
            final updateQuery = '''
              UPDATE PV_Information 
              SET 
                DDATE = '$ddate',
                AMOUNT = $amount,
                Discount = $discount,
                Total = $total,
                CreditAccount = '$creditAccount',
                takeuser = '$takeuser',
                Location = $location,
                Project = $project,
                SalesMan = $salesMan,
                MonthDate = '$monthDate',
                app = $app,
                Transfer_Status = $transferStatus,
                FyID = $fyID,
                EntryNo = $entryNo,
                FrmID = $frmID,
                pviCurrency = $pviCurrency,
                pviCurrencyValue = $pviCurrencyValue,
                pdate = '$pdate'
              WHERE RealEntryNo = $realEntryNo
            ''';
            await MsSQLConnectionPlatform.instance.writeData(updateQuery);
            print("Updated PV_Information for RealEntryNo: $realEntryNo");
          } else {
           final insertQuery = '''
  SET IDENTITY_INSERT PV_Information ON;

  INSERT INTO PV_Information (
    RealEntryNo, DDATE, AMOUNT, Discount, Total, CreditAccount, takeuser, Location, 
    Project, SalesMan, MonthDate, app, Transfer_Status, FyID, EntryNo, FrmID, 
    pviCurrency, pviCurrencyValue, pdate
  ) VALUES (
    $realEntryNo, '$ddate', $amount, $discount, $total, '$creditAccount', '$takeuser', 
    $location, $project, $salesMan, '$monthDate', $app, $transferStatus, $fyID, 
    $entryNo, $frmID, $pviCurrency, $pviCurrencyValue, '$pdate'
  );

  SET IDENTITY_INSERT PV_Information OFF;
''';

            await MsSQLConnectionPlatform.instance.writeData(insertQuery);
            print("Inserted new record in PV_Information (RealEntryNo: $realEntryNo)");
          }
        }
      }
    }
  } catch (e) {
    print("Error syncing PV_Information to MSSQL: $e");
  }
}



Future<void> syncSalesParticularsToMSSQL() async {
  try {
    final localData = await SalesInformationDatabaseHelper.instance.getSalesDataperticular();

    for (var row in localData) {
      final ddate = row['DDate'].toString();
      final entryNo = row['EntryNo'] ?? 0;
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
      final auto = row['Auto'] ?? 0;
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

      final checkQuery = '''
        SELECT COUNT(*) AS count FROM Sales_Particulars WHERE Auto = $auto
      ''';
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          final count = decodedCheck.first['count'] ?? 0;

          if (count > 0) {
            final updateQuery = '''
              UPDATE Sales_Particulars 
              SET 
                DDate = '$ddate', EntryNo = '$entryNo', UniqueCode = $uniqueCode, ItemID = $itemID, 
                serialno = '$serialNo', Rate = $rate, RealRate = $realRate, Qty = $qty, 
                freeQty = $freeQty, GrossValue = $grossValue, DiscPersent = $discPercent, 
                Disc = $disc, RDisc = $rDisc, Net = $net, Vat = $vat, freeVat = $freeVat, 
                cess = $cess, Total = $total, Profit = $profit, Unit = $unit, 
                UnitValue = $unitValue, Funit = $funit, FValue = $fValue, commision = $commission, 
                GridID = $gridID, takeprintstatus = '$takePrintStatus', QtyDiscPercent = $qtyDiscPercent, 
                QtyDiscount = $qtyDiscount, ScheemDiscPercent = $scheemDiscPercent, 
                ScheemDiscount = $scheemDiscount, CGST = $cgst, SGST = $sgst, IGST = $igst, 
                adcess = $adcess, netdisc = $netdisc, taxrate = $taxrate, SalesmanId = '$salesmanId', 
                Fcess = $fcess, Prate = $prate, Rprate = $rprate, location = $location, 
                Stype = $stype, LC = $lc, ScanBarcode = '$scanBarcode', Remark = '$remark', 
                FyID = $fyID, Supplier = '$supplier', Retail = $retail, spretail = $spretail, 
                wsrate = $wsrate
              WHERE Auto = $auto
            ''';
            await MsSQLConnectionPlatform.instance.writeData(updateQuery);
            print("Updated Sales_Particulars for Auto: $auto");
          } else {
            final insertQuery = '''
              INSERT INTO Sales_Particulars (
                DDate, EntryNo, UniqueCode, ItemID, serialno, Rate, RealRate, Qty, freeQty, 
                GrossValue, DiscPersent, Disc, RDisc, Net, Vat, freeVat, cess, Total, Profit, 
                Unit, UnitValue, Funit, FValue, commision, GridID, takeprintstatus, 
                QtyDiscPercent, QtyDiscount, ScheemDiscPercent, ScheemDiscount, CGST, SGST, 
                IGST, adcess, netdisc, taxrate, SalesmanId, Fcess, Prate, Rprate, location, 
                Stype, LC, ScanBarcode, Remark, FyID, Supplier, Retail, spretail, wsrate
              ) VALUES (
                '$ddate', $entryNo, $uniqueCode, $itemID, '$serialNo', $rate, $realRate, $qty, 
                $freeQty, $grossValue, $discPercent, $disc, $rDisc, $net, $vat, $freeVat, 
                $cess, $total, $profit, $unit, $unitValue, $funit, $fValue, $commission, 
                $gridID, '$takePrintStatus', $qtyDiscPercent, $qtyDiscount, $scheemDiscPercent, 
                $scheemDiscount, $cgst, $sgst, $igst, $adcess, $netdisc, $taxrate, '$salesmanId', 
                $fcess, $prate, $rprate, $location, $stype, $lc, '$scanBarcode', '$remark', 
                $fyID, '$supplier', $retail, $spretail, $wsrate
              );
              SET IDENTITY_INSERT Sales_Particulars OFF;
            ''';
            await MsSQLConnectionPlatform.instance.writeData(insertQuery);
            print("Inserted new record in Sales_Particulars (Auto: $auto)");
          }
        }
      }
    }
  } catch (e) {
    print("Error syncing Sales_Particulars to MSSQL: $e");
  }
}

Future<void> syncSalesInformationToMSSQL2() async {
  try {
    final localData = await SalesInformationDatabaseHelper2.instance.getSalesData();

    for (var row in localData) {
      final realEntryNo = row['RealEntryNo'] ?? 0; 

      // **Filter columns excluding `RealEntryNo` & handle `NULL` values**
      final filteredColumns = row.keys.where((col) => col != 'RealEntryNo' && row[col] != null).toList();
      final filteredValues = filteredColumns.map((col) {
        var value = row[col];

        if (value is num) return value.toString();

        if (value is String) {
          if (_isDateString(value)) {
            return _convertToSQLDate(value); 
          }
          return "'${value.trim().replaceAll("'", "''")}'"; 
        }

        return 'NULL';
      }).toList();

      final checkQuery = "SELECT COUNT(*) AS count FROM Sales_Information WHERE RealEntryNo = $realEntryNo";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          final count = decodedCheck.first['count'] ?? 0;

          if (count > 0) {
            // **Update existing record (EXCLUDING RealEntryNo)**
            final updateSet = List.generate(filteredColumns.length, (i) {
              if (filteredValues[i] == 'NULL') return null; // Skip NULL values
              if (_isDateColumn(filteredColumns[i])) {
                return "${filteredColumns[i]} = CAST(${filteredValues[i]} AS DATETIME)";
              }
              return "${filteredColumns[i]} = ${filteredValues[i]}";
            }).where((element) => element != null).join(", ");

            if (updateSet.isNotEmpty) { 
              final updateQuery = '''
                UPDATE Sales_Information SET $updateSet WHERE RealEntryNo = $realEntryNo
              ''';
              await MsSQLConnectionPlatform.instance.writeData(updateQuery);
              print("✅ Updated Sales_Information for RealEntryNo: $realEntryNo");
            } else {
              print("⚠️ Skipped update for RealEntryNo: $realEntryNo (No valid values)");
            }
          } else {
            // **Insert new record (INCLUDING RealEntryNo)**
            final insertQuery = '''
              SET IDENTITY_INSERT Sales_Information ON;
              INSERT INTO Sales_Information (RealEntryNo, ${filteredColumns.join(", ")}) 
              VALUES ($realEntryNo, ${filteredValues.map((v) => _isDateColumn(v) ? "CAST($v AS DATETIME)" : v).join(", ")});
              SET IDENTITY_INSERT Sales_Information OFF;
            ''';
            await MsSQLConnectionPlatform.instance.writeData(insertQuery);
            print("🆕 Inserted new record in Sales_Information for RealEntryNo: $realEntryNo");
          }
        }
      }
    }
  } catch (e) {
    print("❌ Error syncing Sales_Information: $e");
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