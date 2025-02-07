import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/accountTransactionDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/databse_Export/checkdatabse.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/databse_Export/syncDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/reciept_databasehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_info2.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_information.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/Ledgerreport.dart';
import 'package:sheraaccerpoff/views/more_home/backupdata.dart';
import 'package:sheraaccerpoff/views/more_home/company.dart';
import 'package:sheraaccerpoff/views/more_home/configServer.dart';
import 'package:sheraaccerpoff/views/more_home/export.dart';
import 'package:sheraaccerpoff/views/more_home/sync.dart';
import 'package:sheraaccerpoff/views/more_home/update.dart';
import 'package:sheraaccerpoff/views/newLedger.dart';
import 'package:sheraaccerpoff/views/payment.dart';
import 'package:sheraaccerpoff/views/paymentReport.dart';
import 'package:sheraaccerpoff/views/purcahsereport.dart';
import 'package:sheraaccerpoff/views/reciept.dart';
import 'package:sheraaccerpoff/views/recieptreport.dart';
import 'package:sheraaccerpoff/views/sales.dart';
import 'package:sheraaccerpoff/views/salesReport.dart';
import 'package:sheraaccerpoff/views/stockreport.dart';
import 'package:sqflite/sqflite.dart';

class HomePageERP extends StatefulWidget {
  const HomePageERP({super.key});

  @override
  State<HomePageERP> createState() => _HomePageERPState();
}

class _HomePageERPState extends State<HomePageERP> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  final List<String> menuItems = [
    "Company",
    "Configure",
    "Settings",
    "Sync Data",
    "Backup",
    "Export Backup",
    "Clear Data",
     "Update",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

Future<void> syncSalesInformationToMSSQL() async {
  try {
    final localData = await SalesInformationDatabaseHelper.instance.getSalesData();

    final latestEntryQuery = "SELECT MAX(RealEntryNo) AS lastEntry FROM Sales_Information";
    final latestEntryResult = await MsSQLConnectionPlatform.instance.getData(latestEntryQuery);
    int nextRealEntryNo = 1;

    if (latestEntryResult is String) {
      final decodedLatest = jsonDecode(latestEntryResult);
      if (decodedLatest is List && decodedLatest.isNotEmpty) {
        nextRealEntryNo = (decodedLatest.first['lastEntry'] ?? 0) + 1;
      }
    }

    for (var row in localData) {
      final rentryNo = row['RealEntryNo']?.toString() ?? '';  
      final invoiceNo = row['InvoiceNo']?.toString() ?? '';  
      final dDate = row['DDate']?.toString() ?? ''; 
      final customer = row['Customer']?.toString() ?? '0'; 
      final toName = row['Toname']?.toString()?.replaceAll("'", "''") ?? ''; 
      final discount = double.tryParse(row['Discount']?.toString() ?? '0') ?? 0.0;
      final netAmount = double.tryParse(row['NetAmount']?.toString() ?? '0') ?? 0.0;
      final total = double.tryParse(row['Total'].toString()) ?? 0.0;
      final totalQty = int.tryParse(row['TotalQty'].toString()) ?? 0;

      // ✅ Skip invalid records
      if (invoiceNo.isEmpty || customer == '0' || totalQty == 0) {
        print("⚠️ Skipping invalid record: InvoiceNo = $invoiceNo, Customer = $customer, TotalQty = $totalQty");
        continue;
      }

      // 🔍 Check if record already exists in MSSQL
      final checkQuery = '''
        SELECT RealEntryNo FROM Sales_Information 
        WHERE InvoiceNo = '$invoiceNo'
      ''';
      final checkResult = await MsSQLConnectionPlatform.instance.getData(checkQuery);

      bool recordExists = false;
      int existingRealEntryNo = 0;

      if (checkResult is String) {
        final decodedCheck = jsonDecode(checkResult);
        if (decodedCheck is List && decodedCheck.isNotEmpty) {
          recordExists = true;
          existingRealEntryNo = decodedCheck.first['RealEntryNo'] ?? 0;
        }
      }

      if (recordExists) {
        final updateQuery = '''
          UPDATE Sales_Information 
          SET 
            DDate = '$dDate', 
            Customer = '$customer', 
            Toname = '$toName', 
            Discount = $discount, 
            NetAmount = $netAmount, 
            Total = $total, 
            TotalQty = $totalQty
          WHERE RealEntryNo = $existingRealEntryNo
        ''';
        await MsSQLConnectionPlatform.instance.writeData(updateQuery);
        print("✅ Updated record: RealEntryNo = $existingRealEntryNo, InvoiceNo = $invoiceNo");
      } else {
        // ✅ Insert new record with correct RealEntryNo
        final insertQuery = '''
          INSERT INTO Sales_Information (RealEntryNo, InvoiceNo, DDate, Customer, Toname, Discount, NetAmount, Total, TotalQty)
          VALUES (
            $nextRealEntryNo,
            '$invoiceNo', 
            '$dDate', 
            '$customer', 
            '$toName', 
            $discount, 
            $netAmount, 
            $total, 
            $totalQty
          )
          
  SET IDENTITY_INSERT Sales_Information OFF;
        ''';
        try {
          await MsSQLConnectionPlatform.instance.writeData(insertQuery);
          print("✅ Inserted new record with RealEntryNo: $nextRealEntryNo (InvoiceNo = $invoiceNo)");

          // Increment for next insert
          nextRealEntryNo++;
        } catch (e) {
          print("❌ Error inserting record for InvoiceNo = $invoiceNo: $e");
        }
      }
    }

  } catch (e) {
    print("❌ Error syncing Sales_Information to MSSQL: $e");
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

        if (value is num) return value.toString(); // Keep numbers as-is

        if (value is String) {
          if (_isDateString(value)) {
            return _convertToSQLDate(value); // Ensure correct date format
          }
          return "'${value.trim().replaceAll("'", "''")}'"; // Escape single quotes & trim spaces
        }

        return 'NULL'; // Handle NULL values correctly
      }).toList();

      // **Check if the record already exists**
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
              return "${filteredColumns[i]} = ${filteredValues[i]}";
            }).where((element) => element != null).join(", ");

            if (updateSet.isNotEmpty) { // Only update if there are valid fields
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
              VALUES ($realEntryNo, ${filteredValues.join(", ")});
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

// **Helper function to detect date strings**
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
      return 'NULL'; // Return NULL for invalid formats
    }

    // Convert to MSSQL expected format: 'yyyy-MM-dd HH:mm:ss'
    return "'${DateFormat("yyyy-MM-dd HH:mm:ss").format(parsedDate)}'";
  } catch (e) {
    print("⚠️ Date conversion error: $e for input: $inputDate");
    return 'NULL'; // Handle invalid date values safely
  }
}





  void navigateToPage(BuildContext context, String item) {
    switch (item) {
      case "Company":
      Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Company()));
        break;
      case "Configure":
      Navigator.push(
                        context, MaterialPageRoute(builder: (_) => ServerConfig()));
        break;
      case "Settings":
      Navigator.push(
                        context, MaterialPageRoute(builder: (_) => CheckDatabaseScreen()));
        break;
      case "Sync Data":
      LedgerTransactionsDatabaseHelper.instance.updateOpeningBalances();
      //  Navigator.push(
      //                   context, MaterialPageRoute(builder: (_) => SyncButtonPage()));
        print("Syncing data...");
        break;
      case "Backup":
      Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Backupdata()));
        print("Backup...");
        break;
      case "Export Backup":
      _showClearDataDialog2();
        print("Exporting backup...");
        break;
      case "Clear Data":
        _showClearDataDialog();
        break;
        case "Update":
        //backupAndSyncData();
        
        //syncSalesInformationToMSSQL();
        //syncSalesParticularsToMSSQL();
        
        Update update = Update();
        //update.syncRVInformationToMSSQL();
        // update.syncRVParticularsToMSSQL();
        // update.syncPVInformationToMSSQL();
         update.syncPVParticularsToMSSQL();
        //syncSalesInformationToMSSQL2();
        break;
      default:
        print("Unknown option selected: $item");
    }
  }

  Future<void> _clearAllData() async {
    try {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been cleared')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing data: $e')),
      );
    }
  }

   bool isExporting = false;

  Future<void> exportData() async {
    setState(() {
      isExporting = true;
    });

    // Show progress dialog
    showProgressDialog(context);

    // Get ledger data from the database
    //List<Map<String, dynamic>> ledgerData = await getLedgerData();

    // Create CSV file
    //String filePath = await createCsvFile(ledgerData);

    // Here you can transfer the file to USB if needed (implement USB transfer logic).

    // Close the progress dialog and show a completion message
    Navigator.pop(context); // Close progress dialog
    setState(() {
      isExporting = false;
    });

    // Optionally, show a snackbar or another dialog to notify the user.
   // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export Complete! File saved at $filePath')));
  }

  // Fetch all ledger data
// Future<List<Map<String, dynamic>>> getLedgerData() async {
//   Database db = await DatabaseHelper.instance.database;
//   return await db.query(DatabaseHelper.table); // Assuming you want all rows from the ledger_table
// }
Future<void> backupAndSyncData() async {
  
  //await LedgerTransactionsDatabaseHelper.instance.fetchAndInsertIntoSQLite();
  await LedgerTransactionsDatabaseHelper.instance.syncLedgerNamesToMSSQL();
}


  Widget _buildTabContent(List<String> names, List<String> images) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final gridItemWidth = screenWidth * 0.4;
    final gridItemHeight = screenHeight * 0.2;

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01,horizontal: screenHeight*0.02),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: screenHeight * 0.02,
          crossAxisSpacing: screenWidth * 0.03,
          crossAxisCount: 2,
          childAspectRatio: gridItemWidth / gridItemHeight,
        ),
        itemCount: names.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              if (names[index] == "Exit") {
                exit();
              } else {
                switch (names[index]) {
                  case "Ledger":
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Newledger()));
                    break;
                  case "Payment":
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => PaymentForm()));
                    break;
                  case "Receipt":
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Reciept()));
                    break;
                  case "Sales":
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => SalesOrder()));
                    break;
                  case "Ledger Report":
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => LedgerReport()));
                    break;
                  case "Payment Report":
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Paymentreport()));
                    break;
                  case "Receipt Report":
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Recieptreport()));
                    break;
                  case "Sales Report":
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => SalesReport()));
                    break;
                  case "Stock Report":
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => StockReport()));
                    break;
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                  vertical: screenHeight * 0.01),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: Appcolors().searchTextcolor,
                      blurRadius: 2.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0.0, 0.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        height: gridItemHeight * 0.5,
                        width: gridItemWidth * 0.5,
                        child: Image.asset(
                          images[index],
                          scale: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      names[index],
                      style: getFonts(screenWidth * 0.04, Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab1Names = ["Ledger", "Exit"];
    final tab1Images = [
      "assets/images/ledger.png",
      "assets/images/logout.png",
    ];

    final tab2Names = ["Payment", "Receipt", "Sales", "Exit"];
    final tab2Images = [
      "assets/images/cash-payment.png",
      "assets/images/receipt-payment.png",
      "assets/images/sales.png",
      "assets/images/logout.png",
    ];

    final tab3Names = [
      "Ledger Report",
      "Payment Report",
      "Receipt Report",
      "Sales Report",
      "Stock Report",
      "Exit"
    ];

    final tab3Images = [
      "assets/images/ledger (2).png",
      "assets/images/payment report.png",
      "assets/images/reciept report.png",
      "assets/images/sales report.png",
      "assets/images/stock report.png",
      "assets/images/logout.png",
    ];

    return Scaffold(
      backgroundColor: Appcolors().scafoldcolor,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        backgroundColor: Appcolors().maincolor,
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
            child: Text(
              "Sheracc ERP Offline",
              style: appbarFonts(MediaQuery.of(context).size.width * 0.04, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 10),
            child: PopupMenuButton<String>(
              onSelected: (String selectedItem) {
                navigateToPage(context, selectedItem);
              },
              itemBuilder: (BuildContext context) {
                return menuItems.map((String item) {
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              },
              child: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Appcolors().maincolor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Appcolors().maincolor,
            tabs: const [
              Tab(text: "Master"),
              Tab(text: "Entry"),
              Tab(text: "Reports"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(tab1Names, tab1Images),
                _buildTabContent(tab2Names, tab2Images),
                _buildTabContent(tab3Names, tab3Images),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void exit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Appcolors().scafoldcolor,
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Are you confirm To Exit App?',
              style: getFonts(14, Colors.black),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: getFonts(15, Appcolors().maincolor),
              ),
            ),
            TextButton(
              onPressed: () async {
                SystemNavigator.pop();
              },
              child: Text(
                'Yes',
                style: getFonts(15, Appcolors().maincolor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showClearDataDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            '                  Are you sure \n   you want to clear all data?',
            style: getFonts(13, Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: getFonts(14, Appcolors().maincolor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Confirm',
                style: getFonts(14, Appcolors().maincolor),
              ),
            ),
          ],
        );
      },
    );
  }

  void showProgressDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Exporting Data"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Export in Progress..."),
          ],
        ),
      );
    },
  );
}

 Future<bool?> _showClearDataDialog2() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            '                  Are you sure \n   you want to clear all data?',
            style: getFonts(13, Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: getFonts(14, Appcolors().maincolor),
              ),
            ),
            TextButton(
                onPressed: isExporting ? null : exportData, // Disable button while exporting
      child: isExporting ? CircularProgressIndicator() : Text('Export Data'),
              
            ),
          ],
        );
      },
    );
  }
}
