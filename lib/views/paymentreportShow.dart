import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchLedgerData2();
  }

  Future<void> _fetchLedgerData2() async {
    String? fromDateStr = widget.fromDate != null ? DateFormat('dd-MM-yyyy').format(widget.fromDate!) : null;
    String? toDateStr = widget.toDate != null ? DateFormat('dd-MM-yyyy').format(widget.toDate!) : null;

    List<Map<String, dynamic>> data = await PaymentDatabaseHelper.instance.queryFilteredRows(
      fromDateStr,  
      toDateStr,    
      widget.ledgerName ?? "",  
    );

    setState(() {
      paymentData = data;
      totalAmount = paymentData.fold(0.0, (sum, item) {
        double amount = double.tryParse(item[PaymentDatabaseHelper.columnTotal]?.toString() ?? '0') ?? 0.0;
        return sum + amount;  
      });
    });
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
                0: FixedColumnWidth(60),
                1: FixedColumnWidth(100),
                2: FixedColumnWidth(150),
                3: FixedColumnWidth(100),
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
                    _buildHeaderCell('Name'),
                    _buildHeaderCell('amount'),
                    // _buildHeaderCell('Debit'),
                    // _buildHeaderCell('Credit'),
                     _buildHeaderCell('Discount'),
                     _buildHeaderCell('Total'),
                    _buildHeaderCell('Narration'),
                   
                  ],
                ),
                // Table data rows
                ...paymentData.map((data) {
                  return TableRow(
                     children: [
                      _buildDataCell(data[PaymentDatabaseHelper.columnId]?.toString() ?? 'N/A'),
                      _buildDataCell(data[PaymentDatabaseHelper.columnDate]?.toString() ?? 'N/A'),
                      _buildDataCell(data[PaymentDatabaseHelper.columnLedgerName]?.toString() ?? 'N/A'),
                      //_buildDataCell(""),
                       _buildDataCell(data[PaymentDatabaseHelper.columnAmount]?.toString() ?? 'N/A'),
                        _buildDataCell(data[PaymentDatabaseHelper.columnDiscount]?.toString() ?? 'N/A'),
                         _buildDataCell(data[PaymentDatabaseHelper.columnTotal]?.toString() ?? 'N/A'),
                      _buildDataCell(data[PaymentDatabaseHelper.columnNarration]?.toString() ?? 'N/A'),
                     
                    ],
                  );
                }).toList(),
                // Closing balance row
                // TableRow(
                //   children: [
                //     _buildDataCell(''),
                //     _buildDataCell(''),
                //     _buildDataCell(''),
                //     _buildDataCell2('Closing Balance'),
                //     _buildDataCell(''),
                //     _buildDataCell2(totalAmount.toStringAsFixed(2)), 
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

  // Format the date as needed
  String _formatDate(String? dateString) {
    if (dateString != null && dateString.isNotEmpty) {
      try {
        DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dateString);
        return DateFormat('dd-MM-yyyy').format(parsedDate);
      } catch (e) {
        return "Invalid Date";
      }
    }
    return "N/A";
  }

  // Format the amount with two decimal places
  String _formatAmount(dynamic amount) {
    if (amount != null) {
      double parsedAmount = double.tryParse(amount.toString()) ?? 0.0;
      return parsedAmount.toStringAsFixed(2);
    }
    return "0.00";
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
