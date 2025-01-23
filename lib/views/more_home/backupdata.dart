import 'package:flutter/material.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LedgerAtransactionDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/accountTransactionDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/ledgerbackupDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'dart:convert';

class Backupdata extends StatefulWidget {
  const Backupdata({super.key});

  @override
  State<Backupdata> createState() => _BackupdataState();
}

class _BackupdataState extends State<Backupdata> {
  final connection = MssqlConnection.getInstance();

  // Fetch data from Stock table in MSSQL
  Future<List<Map<String, dynamic>>> fetchDataFromMSSQL() async {
    try {
      final query = 'SELECT * FROM Stock';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for Stock data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for Stock: $rawData');
    } catch (e) {
      print('Error fetching data from Stock: $e');
      rethrow;
    }
  }

Future<List<Map<String, dynamic>>> fetchProductDataFromMSSQL() async {
   try {
      final query = 'SELECT  itemcode,hsncode,itemname,Catagory_id,unit_id,taxgroup_id,tax,cgst,sgst,igst,cess,cessper,adcessper,mrp,retail,wsrate,sprate,branch,stockvaluation,typeofsupply,RegItemName,StockQty,TaxGroup_Name,IsWarranty,TotalWarrantyMonth,ReplaceWarrantyMonth,ProRataWarrantyMonth,prSupplier,isInventory,ItemGroup1,ItemGroup2,ItemGroup3,ItemGroup4,ItemGroup5,Series_Id,isMOP FROM Product_Registration';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for Product_Registration data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for Product_Registration: $rawData');
    } catch (e) {
      print('Error fetching data from Product_Registration: $e');
      rethrow;
    }
}

Future<List<Map<String, dynamic>>> fetchDataFromMSSQLCompany() async {
    try {
      final query = 'SELECT  Ledcode,LedName,lh_id,add1,add2,add3,add4,city,route,state,Mobile,pan,Email,gstno,CAmount,Active,SalesMan,Location,OrderDate,DeliveryDate,CPerson,CostCenter,Franchisee,SalesRate,SubGroup,SecondName,UserName,Password,CustomerType,OTP,maxDiscount FROM LedgerNames';
      final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    
      if (rawData is String) {
        final decodedData = jsonDecode(rawData);
        if (decodedData is List) {
          return decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        } else {
          throw Exception('Unexpected JSON format for LedgerNames data: $decodedData');
        }
      }
      throw Exception('Unexpected data format for LedgerNames: $rawData');
    } catch (e) {
      print('Error fetching data from LedgerNames: $e');
      rethrow;
    }
  }


// Future<List<Map<String, dynamic>>> fetchDataFromMSSQLAccTransations() async {
//   try {
//     final query =
//         'SELECT Auto,atDate,atLedCode,atType,atEntryno, atDebitAmount,atCreditAmount,atOpposite,atNarration,atSalesType FROM Account_Transactions';

//     final rawData = await MsSQLConnectionPlatform.instance.getData(query);

//     if (rawData is String) {
//       final decodedData = jsonDecode(rawData);

//       if (decodedData is List) {
//         final completeData =
//             decodedData.map((row) => Map<String, dynamic>.from(row)).toList();

//         if (completeData.isNotEmpty) {
//           final firstRow = completeData.first;
//           final lastRow = completeData.last;

//           print('First Row: $firstRow');
//           print('Last Row: $lastRow');

//           print('Total Number of Rows: ${completeData.length}');
//         } else {
//           print('No data found in Account_Transactions table.');
//         }

//         return completeData; // Return the full list of data
//       } else {
//         throw Exception('Unexpected JSON format for Account_Transactions data: $decodedData');
//       }
//     } else {
//       throw Exception('Unexpected data format for Account_Transactions: $rawData');
//     }
//   } catch (e) {
//     print('Error fetching data from Account_Transactions: $e');
//     rethrow;
//   }
// }



  // Backup both Stock and Product_Registration to local SQLite database
  Future<void> backupToLocalDatabase() async {
    try {
      final stockData = await fetchDataFromMSSQL();

      if (stockData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL Stock')),
        );
        return;
      }

      final dbHelper = StockDatabaseHelper.instance;
      for (var row in stockData) {
        Map<String, dynamic> rowData = {
          'ItemId': row['ItemId']?.toString(),
          'serialno': row['serialno']?.toString(),
          'supplier': row['supplier']?.toString(),
          'Qty': (row['Qty'] is num) ? row['Qty'].toDouble() : 0.0,
          'Disc': (row['Disc'] is num) ? row['Disc'].toDouble() : 0.0,
          'Free': (row['Free'] is num) ? row['Free'].toDouble() : 0.0,
          'Prate': (row['Prate'] is num) ? row['Prate'].toDouble() : 0.0,
          'Amount': (row['Amount'] is num) ? row['Amount'].toDouble() : 0.0,
          'TaxType': row['TaxType']?.toString(),
          'Category': row['Category']?.toString().isNotEmpty == true
              ? row['Category']?.toString()
              : 'Uncategorized',
          'SRate': (row['SRate'] is num) ? row['SRate'].toDouble() : 0.0,
          'Mrp': (row['Mrp'] is num) ? row['Mrp'].toDouble() : 0.0,
          'Retail': (row['Retail'] is num) ? row['Retail'].toDouble() : 0.0,
          'SpRetail': (row['SpRetail'] is num) ? row['SpRetail'].toDouble() : 0.0,
          'WsRate': (row['WsRate'] is num) ? row['WsRate'].toDouble() : 0.0,
          'Branch': row['Branch']?.toString(),
          'RealPrate': (row['RealPrate'] is num) ? row['RealPrate'].toDouble() : 0.0,
          'Location': row['Location']?.toString(),
          'EstUnique': row['EstUnique']?.toString() ?? 'DefaultEstUnique',
          'Locked': row['Locked']?.toString(),
          'expDate': row['expDate']?.toString(),
          'Brand': row['Brand']?.toString(),
          'Company': row['Company']?.toString(),
          'Size': row['Size']?.toString(),
          'Color': row['Color']?.toString(),
          'obarcode': row['obarcode']?.toString(),
          'todevice': row['todevice']?.toString(),
          'Pdate': row['Pdate']?.toString(),
          'Cbarcode': row['Cbarcode']?.toString() ?? 'Default',
          'SktSales': (row['SktSales'] is int) ? row['SktSales'] : 0,
        };
        await dbHelper.insertData(rowData);
      }

      // Fetch Product_Registration data from MSSQL
      final productData = await fetchProductDataFromMSSQL();

      if (productData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL Product_Registration')),
        );
        return;
      }

      // Insert Product_Registration data into SQLite
      for (var row in productData) {
        Map<String, dynamic> productRowData = {
          'itemcode': row['itemcode']?.toString(),
          'hsncode': row['hsncode']?.toString(),
          'itemname': row['itemname']?.toString(),
          'Catagory_id': row['Catagory_id']?.toString(),
         // 'Mfr_id': row['Mfr_id']?.toString(),
          //'subcatagory_id': row['subcatagory_id']?.toString(),
          'unit_id': row['unit_id']?.toString(),
          //'rack_id': row['rack_id']?.toString(),
         // 'packing': row['packing']?.toString(),
          //'reorder': (row['reorder'] is int) ? row['reorder'] : 0,
          //'maxorder': (row['maxorder'] is int) ? row['maxorder'] : 0,
          'taxgroup_id': row['taxgroup_id']?.toString(),
          'tax': (row['tax'] is num) ? row['tax'].toDouble() : 0.0,
          'cgst': (row['cgst'] is num) ? row['cgst'].toDouble() : 0.0,
          'sgst': (row['sgst'] is num) ? row['sgst'].toDouble() : 0.0,
          'igst': (row['igst'] is num) ? row['igst'].toDouble() : 0.0,
          'cess': (row['cess'] is num) ? row['cess'].toDouble() : 0.0,
          'cessper': (row['cessper'] is num) ? row['cessper'].toDouble() : 0.0,
          'adcessper': (row['adcessper'] is num) ? row['adcessper'].toDouble() : 0.0,
          'mrp': (row['mrp'] is num) ? row['mrp'].toDouble() : 0.0,
          'retail': (row['retail'] is num) ? row['retail'].toDouble() : 0.0,
          'wsrate': (row['wsrate'] is num) ? row['wsrate'].toDouble() : 0.0,
          'sprate': (row['sprate'] is num) ? row['sprate'].toDouble() : 0.0,
          'branch': row['branch']?.toString(),
          'stockvaluation': row['stockvaluation']?.toString(),
          'typeofsupply': row['typeofsupply']?.toString(),
           //'check_neg': (row['check_neg'] is int) ? row['check_neg'] : 0,
          //'active': (row['active'] is int) ? row['active'] : 1,
         // 'Internationalbarcode': row['Internationalbarcode']?.toString(),
        // 'serialno': row['serialno']?.toString(),
       //  'bom': row['bom']?.toString(),
      //'photo': row['photo']?.toString(),
          'RegItemName': row['RegItemName']?.toString(),
          'StockQty': (row['StockQty'] is num) ? row['StockQty'].toDouble() : 0.0,
          'TaxGroup_Name': row['TaxGroup_Name']?.toString(),
          //'PluNo': row['PluNo']?.toString(),
         // 'MachineItem': row['MachineItem']?.toString(),
        //'PackingItem': row['PackingItem']?.toString(),
       //'SpeedBill': row['SpeedBill']?.toString(),
      // 'Expiry': row['Expiry']?.toString(),
     // 'Brand': row['Brand']?.toString(),
    // 'PcsBox': (row['PcsBox'] is int) ? row['PcsBox'] : 0,
   // 'SqftBox': (row['SqftBox'] is num) ? row['SqftBox'].toDouble() : 0.0,
  // 'LC': row['LC']?.toString(),
          'IsWarranty': (row['IsWarranty'] is int) ? row['IsWarranty'] : 0,
          'TotalWarrantyMonth': (row['TotalWarrantyMonth'] is int) ? row['TotalWarrantyMonth'] : 0,
          'ReplaceWarrantyMonth': (row['ReplaceWarrantyMonth'] is int) ? row['ReplaceWarrantyMonth'] : 0,
          'ProRataWarrantyMonth': (row['ProRataWarrantyMonth'] is int) ? row['ProRataWarrantyMonth'] : 0,
          'prSupplier': row['prSupplier']?.toString()??"",
          'isInventory': (row['isInventory'] is int) ? row['isInventory'] : 1,
          'ItemGroup1': row['ItemGroup1']?.toString(),
          'ItemGroup2': row['ItemGroup2']?.toString(),
          'ItemGroup3': row['ItemGroup3']?.toString(),
          'ItemGroup4': row['ItemGroup4']?.toString(),
          'ItemGroup5': row['ItemGroup5']?.toString(),
           'Series_Id': (row['Series_Id'] is num) ? row['Series_Id'].toDouble() : 0.0,
           'isMOP': (row['isMOP'] is num) ? row['isMOP'].toDouble() : 0.0,


        };
        await dbHelper.insertProductRegistrationData(productRowData);
      }

      final CompanyLedgerData = await fetchDataFromMSSQLCompany();
 if (productData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data fetched from MSSQL Product_Registration')),
        );
        return;
      }
      final DbHelper = LedgerTransactionsDatabaseHelper.instance;
for (var row in CompanyLedgerData) {
  Map<String, dynamic> rowData = {
    'Ledcode': row['Ledcode']?.toString() ?? '', // Default empty string for null values
    'LedName': row['LedName']?.toString() ?? 'Unknown',
    'lh_id': row['lh_id']?.toString() ?? '',
    'add1': row['add1']?.toString() ?? 'Default Address',
    'add2': row['add2']?.toString() ?? 'Default Address',
    'add3': row['add3']?.toString() ?? 'Default Address',
    'add4': row['add4']?.toString() ?? 'Default Address',
    'city': row['city']?.toString() ?? 'Default City',
    'route': row['route']?.toString() ?? 'Default Route',
    'state': row['state']?.toString() ?? 'Default State',
    'Mobile': row['Mobile']?.toString() ?? '',
    'pan': row['pan']?.toString() ?? '',
    'Email': row['Email']?.toString() ?? '',
    'gstno': row['gstno']?.toString() ?? '',
    'CAmount': row['CAmount'] != null ? row['CAmount'].toString() : '0.0',
    'Active': row['Active'] != null ? row['Active'].toString() : '1',
    'SalesMan': row['SalesMan']?.toString() ?? 'Unknown',
    'Location': row['Location']?.toString() ?? '',
    'OrderDate': row['OrderDate']?.toString() ?? '',
    'DeliveryDate': row['DeliveryDate']?.toString() ?? '',
    'CPerson': row['CPerson']?.toString() ?? 'Unknown',
    'CostCenter': row['CostCenter']?.toString() ?? 'Default Center',
    'Franchisee': row['Franchisee']?.toString() ?? 'Unknown',
    'SalesRate': row['SalesRate']?.toString() ?? '',
    'SubGroup': row['SubGroup']?.toString() ?? 'Unknown SubGroup',
    'SecondName': row['SecondName']?.toString() ?? 'Unknown',
    'UserName': row['UserName']?.toString() ?? 'Unknown',
    'Password': row['Password']?.toString() ?? 'Unknown',
    'CustomerType': row['CustomerType']?.toString() ?? 'Regular',
    'OTP': row['OTP']?.toString() ?? '',
    'maxDiscount': row['maxDiscount'] != null ? row['maxDiscount'].toString() : '0.0',
  };

  await DbHelper.insertLedgerData(rowData);
}

//       final AccTransLedgerData = await fetchDataFromMSSQLAccTransations();
//  if (productData.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('No data fetched from MSSQL Product_Registration')),
//         );
//         return;
//       }
//       final DHelper = AccountTransactionsDatabaseHelper.instance;
// for (var row in AccTransLedgerData) {
//   Map<String, dynamic> rowData = {
//     'atLedCode': row['atLedCode']?.toString() ?? '', 
//     'atEntryno': row['atEntryno']?.toString() ?? '', 
//     'atDebitAmount': row['atDebitAmount'] != null ? row['atDebitAmount'] : 0.0, 
//     'atCreditAmount': row['atCreditAmount'] != null ? row['atCreditAmount'] : 0.0, 
//     'atOpposite': row['atOpposite']?.toString() ?? '', 
//     'atSalesType': row['atSalesType']?.toString() ?? 'Default SalesType',
//     'atDate': row['atDate']?.toString() ?? '',
//     'atType': row['atType']?.toString() ?? '',
//   };

//   // Inserting the rowData into the NewTable
//   await DHelper.insertTransaction(rowData);
// }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup completed successfully!')),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during backup: $e')),
      );
    }
  }

// void sync() async {
//   final dbHelper = LedgerDatabaseHelper.instance;

//    try {
//     // Fetch all Ledcode values from LedgerNames table
//     final ledgers = await dbHelper.getLedgerData();
    
//     // Iterate over each ledger and update opening balances
//     for (var ledger in ledgers) {
//       final atLedCode = ledger['Ledcode'] as String;
//       await dbHelper.updateOpeningBalances();
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Sync completed successfully!')),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error during sync: $e')),
//     );
//   }
// }

Future<void> performBackup() async {
    try {
      await backupMSSQLToSQLite(); // Call the backup function
      print("Backup completed successfully.");
    } catch (e) {
      print("Error during backup: $e");
    }
  }

 
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.1,
        backgroundColor: Appcolors().maincolor,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
              right: screenHeight * 0.01,
            ),
            child: Text(
              "BackUp",
              style: appbarFonts(screenWidth * 0.04, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.02,
              right: screenHeight * 0.02,
            ),
            child: GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            backupToLocalDatabase(); 
          //sync();
         performBackup();
          //updateOpeningBalances();
          },
          child: Container(
            height: screenHeight * 0.04,
            width: screenWidth * 0.2,
            decoration: BoxDecoration(
              color: Appcolors().maincolor,
            ),
            child: Center(
              child: Text(
                "BackUp Data",
                style: getFonts(14, Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
