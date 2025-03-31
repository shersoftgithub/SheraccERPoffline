import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mssql_connection/mssql_connection.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sheraaccerpoff/previews/sales_preview.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/AccountReportDB.dart';
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
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/Ledgerreport.dart';
import 'package:sheraaccerpoff/views/more_home/backupdata.dart';
import 'package:sheraaccerpoff/views/more_home/cleardata.dart';
import 'package:sheraaccerpoff/views/more_home/company.dart';
import 'package:sheraaccerpoff/views/more_home/configServer.dart';
import 'package:sheraaccerpoff/views/more_home/export.dart';
import 'package:sheraaccerpoff/views/more_home/settings.dart';
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
    //"Company",
    "Configure",
    "Settings",
   // "Sync Data",
    "Import",
    "Export Backup",
    "Clear Data",
    "Export",
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





void _showAuthDialogsettings(BuildContext context) {
  TextEditingController passwordController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (context) {
      return AlertDialog(
        title: Text("Authentication Required",style: getFonts(16, Colors.black),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            TextField(
              controller: passwordController,
              obscureText: true, 
              decoration: InputDecoration(labelText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              String password = passwordController.text.trim();

              if (password == "1234") {
                Navigator.pop(context); 
                Navigator.push(context, MaterialPageRoute(builder: (_) => Settings())); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Invalid credentials!")),
                );
              }
            },
            child: Text("Enter"),
          ),
        ],
      );
    },
  );
}
void _showAuthDialog(BuildContext context) {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (context) {
      return AlertDialog(
        title: Text("Authentication Required",style: getFonts(16, Colors.black),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true, 
              decoration: InputDecoration(labelText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              String username = usernameController.text.trim();
              String password = passwordController.text.trim();

              if (username == "admin" && password == "1234") {
                Navigator.pop(context); 
                Navigator.push(context, MaterialPageRoute(builder: (_) => ServerConfig())); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Invalid credentials!")),
                );
              }
            },
            child: Text("Login"),
          ),
        ],
      );
    },
  );
}

Future<void> fetchAndStoreLedgerData() async {
  try {
    final query = "select CONVERT(char(10),getdate(),126) as DDate,atLedCode Name,'OPENING BALANCE' Type,0 Opposite,0 EntryNo,(CASE WHEN sum(atDebitAmount-atCreditAmount)>0 Then sum(atDebitAmount-atCreditAmount) else 0 end) DebitAmount,(CASE WHEN sum(atDebitAmount-atCreditAmount)>0 Then 0 else sum(atCreditAmount-atDebitAmount) end) CreditAmount,'1' Firm,0 Auto,'' Narration,0 Project from Account_Transactions where atLedCode In (select Ledcode from LedgerNames l inner join LedgerHeads lh on l.lh_id = lh.lh_id where l.Active=1) group by atLedCode\n";
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);

    if (rawData is String) {
      final decodedData = jsonDecode(rawData);
      if (decodedData is List) {
        final List<Map<String, dynamic>> ledgerData =
            decodedData.map((row) => Map<String, dynamic>.from(row)).toList();
        final db = await openDatabase('ledger.db');
        for (var ledger in ledgerData) {
          await db.insert(
            'ledger',
            {
              'ledgerId': ledger['auto'],
              'entryNo': ledger['EntryNo'],
              'name': ledger['Name'],
              'amount': ledger['Amount'],
              'discount': ledger['Discount'],
              'total': ledger['Total'],
              'narration': ledger['Narration'],
              'ddate': ledger['ddate'],
              'fyID': ledger['FyID'],
              'frmID': ledger['FrmID'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        print("Ledger data synced successfully!");
      } else {
        throw Exception("Unexpected JSON format: $decodedData");
      }
    } else {
      throw Exception("Unexpected data format from MS SQL: $rawData");
    }
  } catch (e) {
    print("Error fetching or storing ledger data: $e");
  }
}


Future<void> fetchAndStoreAllLedgerReports() async {
  final mssqlDb = MsSQLConnectionPlatform.instance; 
  
  try {
    final ledgerCodesQuery = "SELECT Ledcode, LedName FROM LedgerNames";
    final ledgerCodesRawData = await mssqlDb.getData(ledgerCodesQuery);
    
    if (ledgerCodesRawData is String) {
      final decodedData = jsonDecode(ledgerCodesRawData);
      if (decodedData is List) {
        for (var ledger in decodedData) {
           String ledCode = (ledger['Ledcode']?.toString() ?? ''); 
          String ledName = ledger['LedName'];

          final transactionsQuery = '''
            SELECT 
              atDate AS date,
              b.LedName AS particulars,
              atType AS voucher,
              atEntryno AS entryNo,
              atDebitAmount AS debit,
              atCreditAmount AS credit,
              atNarration AS narration
            FROM Account_Transactions a
            JOIN LedgerNames b ON a.atOpposite = b.Ledcode
            WHERE a.atLedCode = '$ledCode'
            ORDER BY atDate
          ''';
          
          final transactionsRawData = await mssqlDb.getData(transactionsQuery); 

          if (transactionsRawData is String) {
            final decodedTransactions = jsonDecode(transactionsRawData);
            if (decodedTransactions is List) {
              double runningBalance = 0.0;
              List<Map<String, dynamic>> ledgerData = [];

              ledgerData.add({
                'ledCode': ledCode,
                'ledName': ledName,
                'date': '',
                'particulars': 'Opening Balance',
                'voucher': '',
                'entryNo': null,
                'debit': runningBalance > 0 ? runningBalance : 0.0,
                'credit': runningBalance < 0 ? -runningBalance : 0.0,
                'balance': runningBalance > 0
                    ? '${runningBalance.toStringAsFixed(2)} Dr'
                    : '${(-runningBalance).toStringAsFixed(2)} Cr',
                'narration': ''
              });

              for (var row in decodedTransactions) {
                double debit = double.tryParse(row['debit']?.toString() ?? '0.0') ?? 0.0;
                double credit = double.tryParse(row['credit']?.toString() ?? '0.0') ?? 0.0;

                runningBalance += (debit - credit);

                ledgerData.add({
                  'ledCode': ledCode,
                  'ledName': ledName,
                  'date': row['date'],
                  'particulars': row['particulars'],
                  'voucher': row['voucher'],
                  'entryNo': row['entryNo'],
                  'debit': debit,
                  'credit': credit,
                  'balance': runningBalance > 0
                      ? '${runningBalance.toStringAsFixed(2)} Dr'
                      : '${(-runningBalance).toStringAsFixed(2)} Cr',
                  'narration': row['narration']
                });
              }
              double totalDebit = ledgerData.fold(0.0, (sum, row) => sum + (row['debit'] ?? 0.0));
              double totalCredit = ledgerData.fold(0.0, (sum, row) => sum + (row['credit'] ?? 0.0));

              ledgerData.add({
                'ledCode': ledCode,
                'ledName': ledName,
                'date': '',
                'particulars': 'Total',
                'voucher': '',
                'entryNo': null,
                'debit': totalDebit,
                'credit': totalCredit,
                'balance': '',
                'narration': ''
              });

              ledgerData.add({
                'ledCode': ledCode,
                'ledName': ledName,
                'date': '',
                'particulars': 'Closing Balance',
                'voucher': '',
                'entryNo': null,
                'debit': totalDebit > totalCredit ? totalDebit - totalCredit : 0.0,
                'credit': totalCredit > totalDebit ? totalCredit - totalDebit : 0.0,
                'balance': '',
                'narration': ''
              });

              await LedgerReportDatabaseHelper.instance.insertLedgerReport(ledgerData);
            } else {
              throw Exception('Unexpected data format for transactions: $decodedTransactions');
            }
          } else {
            throw Exception('Unexpected data format for transactions: $transactionsRawData');
          }
        }
        print("All ledger reports stored successfully!");
      } else {
        throw Exception('Unexpected data format for ledger codes: $decodedData');
      }
    } else {
      throw Exception('Unexpected data format for ledger codes: $ledgerCodesRawData');
    }
  } catch (e) {
    print('Error fetching and storing all ledger reports: $e');
    rethrow;
  }
}






  void navigateToPage(BuildContext context, String item) {
    switch (item) {
      // case "Company":
      // Navigator.push(
      //                   context, MaterialPageRoute(builder: (_) => Company()));
      //   break;
      case "Configure":
      _showAuthDialog(context);
        break;
      case "Settings":
      _showAuthDialogsettings(context);
        break;
      // case "Sync Data":
      //  fetchAndStoreLedgerData();

      //  //fetchAndStoreAllLedgerReports();
     
      //   print("Syncing data...");
      //   break;
      case "Import":
      Navigator.push(
                        context, MaterialPageRoute(builder: (_) => Backupdata()));
        print("Import...");
        break;
      case "Export Backup":
      _showClearDataDialog2();
        print("Exporting backup...");
        break;
      case "Clear Data":
        _showClearDataClearDialog2();
        break;
        case "Export":
        Navigator.push(
        context, MaterialPageRoute(builder: (_) => Import()));
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
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            onPressed: () {
              //Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: Colors.white,
              size: 20,
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
 Future<bool?> _showClearDataClearDialog2() async {
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
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ClearDatabase()));
            }, child:  Text(
                'Ok',
                style: getFonts(14, Appcolors().maincolor),
              ),)
          ],
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
            '                  Are you sure \n   you want to Export data?',
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
