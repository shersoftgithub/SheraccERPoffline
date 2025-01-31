import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/accountTransactionDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/databse_Export/checkdatabse.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/databse_Export/syncDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/reciept_databasehelper.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/Ledgerreport.dart';
import 'package:sheraaccerpoff/views/more_home/backupdata.dart';
import 'package:sheraaccerpoff/views/more_home/company.dart';
import 'package:sheraaccerpoff/views/more_home/configServer.dart';
import 'package:sheraaccerpoff/views/more_home/export.dart';
import 'package:sheraaccerpoff/views/more_home/sync.dart';
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
        backupAndSyncData();
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
