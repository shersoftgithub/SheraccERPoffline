import 'dart:convert';

import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/reciept_databasehelper.dart';

final class Update{

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

    for (var row in localData) {
      final auto = int.tryParse(row['auto'].toString()) ?? 0;
      final entryNo = double.tryParse(row['EntryNo'].toString()) ?? 0.0;
      final name = int.tryParse(row['Name'].toString()) ?? 0;
      final amount = double.tryParse(row['Amount'].toString()) ?? 0.0;
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final narration = row['Narration'].toString().replaceAll("'", "''");
      final ddate = row['ddate'].toString();

      final checkQuery = "SELECT COUNT(*) AS count FROM RV_Particulars WHERE auto = $auto";
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          final count = decodedCheck.first['count'] ?? 0;

          if (count > 0) {
            final updateQuery = '''
              UPDATE RV_Particulars 
              SET 
                EntryNo = $entryNo, 
                Name = $name, 
                Amount = $amount, 
                Discount = $discount, 
                Total = $total, 
                Narration = '$narration', 
                ddate = '$ddate' 
              WHERE auto = $auto
            ''';
            await MsSQLConnectionPlatform.instance.writeData(updateQuery);
            print("Updated record: $auto");
          } else {
            // **Insert without 'auto' column (SQL Server will auto-generate it)**
            final insertQuery = '''
              INSERT INTO RV_Particulars (Name, Amount, Discount, Total, Narration, ddate)
              VALUES ( 
                $name, 
                $amount, 
                $discount, 
                $total, 
                '$narration', 
                '$ddate'
              )
            ''';
            await MsSQLConnectionPlatform.instance.writeData(insertQuery);
            print("Inserted new record (auto-generated ID & EntryNo)");
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

    for (var row in localData) {
      // Convert necessary fields to the correct type
      final name = int.tryParse(row['Name'].toString()) ?? 0; 
      final amount = double.tryParse(row['Amount'].toString()) ?? 0.0; 
      final discount = double.tryParse(row['Discount'].toString()) ?? 0.0; 
      final total = double.tryParse(row['Total'].toString()) ?? 0.0; 
      final narration = row['Narration'].toString().replaceAll("'", "''"); 
      final ddate = row['ddate'].toString();

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
                Narration = '$narration'
              WHERE Name = $name AND ddate = '$ddate'
            ''';
            await MsSQLConnectionPlatform.instance.writeData(updateQuery);
            print("Updated record for Name: $name and ddate: $ddate");
          } else {
            // **Insert without 'auto' and 'EntryNo' (SQL Server will auto-generate them)**
            final insertQuery = '''
              INSERT INTO PV_Particulars (Name, Amount, Discount, Total, Narration, ddate)
              VALUES (
                $name, 
                $amount, 
                $discount, 
                $total, 
                '$narration', 
                '$ddate'
              )
            ''';
            await MsSQLConnectionPlatform.instance.writeData(insertQuery);
            print("Inserted new record (auto-generated ID)");
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
            // **Update existing record**
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


}