import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_information.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/salesDBHelper.dart'; // Adjust with your actual import
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowSalesReport extends StatefulWidget {
  final String? customerName;
  final String? itemName;
  final String? itemcode;
  final DateTime? fromDate;
  final DateTime? toDate;
  
  const ShowSalesReport({
    super.key,
    this.customerName,
    this.itemcode,
    this.itemName,
    this.fromDate,
    this.toDate,
  });

  @override
  State<ShowSalesReport> createState() => _ShowSalesReportState();
}

class _ShowSalesReportState extends State<ShowSalesReport> {
  List<Map<String, dynamic>> paymentData = [];
double totalAmount = 0.0;
  @override
  void initState() {
    super.initState();
    // _fetchFilteredData();
    // _fetchFilteredSalesData(); 
    _fetchStockData2();
  }
 Future<void> _fetchStockData2() async {
    try {
   //   List<Map<String, dynamic>> data = await LedgerTransactionsDatabaseHelper.instance.getAllTransactions();
            List<Map<String, dynamic>> data = await SalesInformationDatabaseHelper.instance.getSalesData();

      print('Fetched stock data: $data');
      setState(() {
      paymentData   = data;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }
 Future<void> _fetchFilteredData() async {
  // Ensure the filters are passed correctly into the queryFilteredRows method
  String? fromDateStr = widget.fromDate != null ? DateFormat('yyyy-MM-dd').format(widget.fromDate!) : null;
  String? toDateStr = widget.toDate != null ? DateFormat('yyyy-MM-dd').format(widget.toDate!) : null;

  List<Map<String, dynamic>> data = await SaleDatabaseHelper.instance.queryFilteredRows(
    fromDate: widget.fromDate,  // Pass the DateTime directly
    toDate: widget.toDate,  
    itemName: widget.itemName, 
    customer: widget.customerName ?? '', // Pass the customer name
  );

  setState(() {
    paymentData = data.map((ledger) {
      String? dateString = ledger['date'];
      DateTime? ledgerDate;

      if (dateString != null && dateString.isNotEmpty) {
        try {
          ledgerDate = DateFormat('yyyy-MM-dd').parse(dateString);
        } catch (e) {
          print("Error parsing date: $e");
          ledgerDate = DateTime.now();
        }
      } else {
        ledgerDate = DateTime.now();
      }

      return {...ledger, 'date': ledgerDate};
    }).toList();

    totalAmount = paymentData.fold(0.0, (sum, item) {
      double amount = double.tryParse(item[SaleDatabaseHelper.columnTotalAmt]?.toString() ?? '0') ?? 0.0;
      return sum + amount;
    });
  });
}



List<Map<String, dynamic>> salesData = [];
  double openingBalance = 0.0;
  double paidAmount = 0.0;
  double receivedAmount = 0.0;
Future<void> _fetchFilteredSalesData() async {
  // Ensure the filters are passed correctly into the queryFilteredRows method
  String? fromDateStr = widget.fromDate != null ? DateFormat('yyyy-MM-dd').format(widget.fromDate!) : null;
  String? toDateStr = widget.toDate != null ? DateFormat('yyyy-MM-dd').format(widget.toDate!) : null;

  List<Map<String, dynamic>> data = await SaleDatabaseHelper.instance.queryFilteredRows(
    fromDate: widget.fromDate,  // Pass the DateTime directly
    toDate: widget.toDate,      // Pass the DateTime directly
    customer: widget.customerName ?? '',  // Pass the customer name
  );

  setState(() {
    salesData = data;

    totalAmount = salesData.fold(0.0, (sum, item) {
      double amount = double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0;
      return sum + amount;
    });

    // Fetch the ledger data for the customer (optional, depending on the use case)
    //_fetchLedgerDataForCustomer(widget.customerName ?? '');
  });
}


// Future<void> _fetchLedgerDataForCustomer(String customerName) async {
//   List<Map<String, dynamic>> ledgerData = await DatabaseHelper.instance.queryFilteredRows(
//      widget.fromDate,
//      widget.toDate,
//    customerName,
//   );

//   ledgerData.forEach((item) {
//     if (item['ledger_name'] == customerName) {  
//       openingBalance = (double.tryParse(item[DatabaseHelper.columnOpeningBalance]?.toString() ?? '0') ?? 0.0);
//       paidAmount = (double.tryParse(item[DatabaseHelper.columnPayAmount]?.toString() ?? '0') ?? 0.0);
//       receivedAmount = (double.tryParse(item[DatabaseHelper.columnReceivedBalance]?.toString() ?? '0') ?? 0.0);
//     }
//   });
//   setState(() {});
// }


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
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              "Sales Report",
              style: appbarFonts(screenHeight * 0.02, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight * 0.02),
            child: GestureDetector(
              onTap: () {},
              child: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset("assets/images/setting (2).png"),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Table(
              border: TableBorder.all(
                color: Colors.black,
                width: 1.0,
              ),
              columnWidths: {
                0: FixedColumnWidth(100),
                1: FixedColumnWidth(100),
                2: FixedColumnWidth(100),
                3: FixedColumnWidth(100),
                4: FixedColumnWidth(100),
                5: FixedColumnWidth(100),
                // 6: FixedColumnWidth(100),
                // 7: FixedColumnWidth(100),
                // 8: FixedColumnWidth(100),
                // 9: FixedColumnWidth(100),
                // 10: FixedColumnWidth(100),
              },
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell('Invoice No'),
                    _buildHeaderCell('Date'),
                    _buildHeaderCell('Sale Rate'),
                    _buildHeaderCell('Customer'),
                    _buildHeaderCell('Phone No'),
                    _buildHeaderCell('Item Name'),
                    // _buildHeaderCell('Quantity'),
                    // _buildHeaderCell('Unit'),
                    // _buildHeaderCell('Rate'),
                    // _buildHeaderCell('Tax'),
                    // _buildHeaderCell('Total Amt'),
                  ],
                ),
                // Table data rows
                ...paymentData.map((data) {
                  return TableRow(
                    children: [
                       
                      _buildDataCell(data['RealEntryNo'].toString()),
                  _buildDataCell(data['InvoiceNo'].toString()),
                  _buildDataCell(data['DDate'].toString()),
                  _buildDataCell(data['Customer'].toString()),
                  _buildDataCell(data['Toname'].toString()),
                  _buildDataCell(data['Total'].toString()),
                      // _buildDataCell(data[SaleDatabaseHelper.columnId].toString()), // Invoice No
                      // _buildDataCell(DateFormat('dd-MM-yyyy').format(data[SaleDatabaseHelper.columnDate])),

                      // _buildDataCell(data[SaleDatabaseHelper.columnSaleRate].toString()), // Sale Rate
                      // _buildDataCell(data[SaleDatabaseHelper.columnCustomer]), // Customer
                      // _buildDataCell(data[SaleDatabaseHelper.columnPhoneNo]), // Phone No
                      // _buildDataCell(data[SaleDatabaseHelper.columnItemName]), // Item Name
                      // _buildDataCell(data[SaleDatabaseHelper.columnQTY].toString()), // Quantity
                      // _buildDataCell(data[SaleDatabaseHelper.columnUnit]), // Unit
                      // _buildDataCell(data[SaleDatabaseHelper.columnRate].toString()), // Rate
                      // _buildDataCell(data[SaleDatabaseHelper.columnTax].toString()), // Tax
                      // _buildDataCell(data[SaleDatabaseHelper.columnTotalAmt].toString()), // Total Amount
                    ],
                  );
                }).toList(),
              //   TableRow(
              //   children: [
              //     _buildDataCell(''),
              //     _buildDataCell(''),
              //     _buildDataCell(''),
              //     _buildDataCell(''),
              //     _buildDataCell2('Closing Balance'),
              //     _buildDataCell(''),
              //     _buildDataCell2(openingBalance.toStringAsFixed(2)), 
              //     _buildDataCell(''),
              //     _buildDataCell(''),
              //     _buildDataCell(''),
              //     _buildDataCell(''),
              //   ],
              // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: getFonts(13, Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: getFonts(12, Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget _buildDataCell2(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: getFonts(12, Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }
}
