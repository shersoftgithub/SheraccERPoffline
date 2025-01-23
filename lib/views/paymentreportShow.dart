import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LedgerAtransactionDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/accountTransactionDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/ledgerbackupDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/reciept_databasehelper.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowPaymentReport extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? ledgerName;

  const ShowPaymentReport({super.key, this.fromDate, this.toDate, this.ledgerName});

  @override
  State<ShowPaymentReport> createState() => _ShowPaymentReportState();
}

class _ShowPaymentReportState extends State<ShowPaymentReport> {
  List<Map<String, dynamic>> paymentData = [];
  List<Map<String, dynamic>> Data = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
  //_fetchFilteredData();
   _fetchStockData2();
  }

  Future<void> _fetchStockData2() async {
    try {
      List<Map<String, dynamic>> data = await LedgerTransactionsDatabaseHelper.instance.getAllTransactions();
      print('Fetched stock data: $data');
      setState(() {
      paymentData   = data;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }
Future<void> _fetchFilteredData() async {
  try {
    // Format dates for filtering
    String? fromDateStr = widget.fromDate != null
        ? DateFormat('dd-MM-yyyy').format(widget.fromDate!)
        : null;
    String? toDateStr = widget.toDate != null
        ? DateFormat('dd-MM-yyyy').format(widget.toDate!)
        : null;

    // Query filtered data from the database
    List<Map<String, dynamic>> data = await LedgerTransactionsDatabaseHelper.instance.queryFilteredRowsPay(
      fromDate: widget.fromDate,
      toDate: widget.toDate,
      ledgerName: widget.ledgerName ?? '',
    );

    // Update paymentData with the filtered data
    setState(() {
      paymentData = data;
    });
  } catch (e) {
    print('Error fetching filtered data: $e');
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
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              "Payment Report",
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
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(
                color: Colors.black,
                width: 1.0,
              ),
              columnWidths: {
                0: FixedColumnWidth(50),
                1: FixedColumnWidth(60),
                2: FixedColumnWidth(100),
                3: FixedColumnWidth(150),
                4: FixedColumnWidth(100),
                5: FixedColumnWidth(100),
                6: FixedColumnWidth(100),
                7: FixedColumnWidth(100),
              },
              children: [
                // Table header row
                TableRow(
                  children: [
                    _buildHeaderCell('No'),
                      _buildHeaderCell('Date'),
                      _buildHeaderCell('Debit'),
                      _buildHeaderCell('Credit'),
                      // _buildHeaderCell('Debit'),
                      // _buildHeaderCell('Credit'),
                       _buildHeaderCell('Name'),
                       _buildHeaderCell('Discount'),
                      _buildHeaderCell('atType'),
                  ],
                ),
                // Table data rows
                ...paymentData.asMap().entries.map((entry) {
                  int index = entry.key + 1; // Generate SiNo
                  Map<String, dynamic> data = entry.value;
                  return TableRow(
                    children: [
                      _buildDataCell(data['atLedCode'].toString()),
                  _buildDataCell(data['atDate'] ?? 'N/A'),
                  _buildDataCell(data['atDebitAmount'] != null 
            ? data['atDebitAmount'].toStringAsFixed(2) 
            : 'N/A'),  // Format to string with 2 decimal places
                  _buildDataCell(data['atCreditAmount'] != null 
            ? data['atCreditAmount'].toStringAsFixed(2) 
            : '0.00'),  // Format to string with 2 decimal places
                  _buildDataCell(data['atLedName'].toString()),
                  _buildDataCell(data['atDiscount'].toString()),
                  _buildDataCell(data['atType'].toString()),
                      // _buildDataCell(index.toString()),
                      // _buildDataCell(data['atLedCode'].toString()),
                      // _buildDataCell(data['atEntryno'] ?? 'N/A'),
                      // _buildDataCell(data['atDebitAmount'] != null
                      //     ? double.parse(data['atDebitAmount'].toString()).toStringAsFixed(2)
                      //     : 'N/A'),
                      // _buildDataCell(data['atCreditAmount'] != null
                      //     ? double.parse(data['atCreditAmount'].toString()).toStringAsFixed(2)
                      //     : '0.00'),
                      // _buildDataCell(data['atOpposite'].toString()),
                      // _buildDataCell(data['atSalesType'].toString()),
                      // _buildDataCell(data['atType'].toString()),
                    ],
                  );
                }).toList(),
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
      color: Colors.white,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: getFonts(13, Colors.black),
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
}
