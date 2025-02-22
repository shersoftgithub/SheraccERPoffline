import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:sheraaccerpoff/pdf_report/recieptpdf.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/accountTransactionDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/reciept_databasehelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/salesDBHelper.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:pdf/widgets.dart' as pw;

class ShowRecieptReport extends StatefulWidget {
 final DateTime? fromDate;
  final DateTime? toDate;
  final String? ledgerName;

  const ShowRecieptReport({super.key, this.fromDate, this.toDate, this.ledgerName});

  @override
  State<ShowRecieptReport> createState() => _ShowRecieptReportState();
}

class _ShowRecieptReportState extends State<ShowRecieptReport> {

 List<Map<String, dynamic>> recieptdata = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
   // _fetchLedgerData();
    _fetchFilteredData();
   // _fetchLedgerData2();
  }
List<Map<String, dynamic>> Data=[];
  Future<void> _fetchFilteredData() async {
  String? fromDateStr = widget.fromDate != null ? DateFormat('yyyy-MM-dd').format(widget.fromDate!) : null;
  String? toDateStr = widget.toDate != null ? DateFormat('yyyy-MM-dd').format(widget.toDate!) : null;
  List<Map<String, dynamic>> ledgerData = await LedgerTransactionsDatabaseHelper.instance.fetchLedgerCodesAndNames();

  Map<String, String> ledgerNameToCodeMap = {
    for (var ledger in ledgerData) ledger['LedName'].toString(): ledger['Ledcode'].toString()
  };

 
  String? selectedLedgerCode = widget.ledgerName != null && widget.ledgerName!.isNotEmpty
      ? ledgerNameToCodeMap[widget.ledgerName!]
      : null;
  List<Map<String, dynamic>> data = await RV_DatabaseHelper.instance.queryFilteredRowsPay(
    fromDate: widget.fromDate!,
    toDate: widget.toDate!,
    ledgerName: selectedLedgerCode ?? '',  
  );
  Map<String, String> ledgerCodeToNameMap = {
    for (var ledger in ledgerData) ledger['Ledcode'].toString(): ledger['LedName'].toString()
  };
  setState(() {
    Data = data.map((ledger) {
      String? ledCode = ledger['Name']?.toString();
      String? ledName = ledgerCodeToNameMap[ledCode] ?? 'N/A';
 String formattedDate = 'N/A';
      if (ledger['ddate'] != null && ledger['ddate'].toString().isNotEmpty) {
        try {
          DateTime parsedDate = DateTime.parse(ledger['ddate'].toString());
          formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
        } catch (e) {
          print("Error parsing date: $e");
        }
      }
      return {
        ...ledger,
        'Name': ledName,
        'ddate': formattedDate, 
      };
    }).toList();
  });
}



// Future<void> _fetchLedgerData2() async {
//   try {
//     List<Map<String, dynamic>> data = await LedgerTransactionsDatabaseHelper.instance.getFilteredAccTrans("RECEIPT");
//     print('Fetched stock data: $data'); 
//     setState(() {
//       Data = data;
//     });
//   } catch (e) {
//     print('Error fetching stock data: $e');
//   }
// }


Future<File> generatePdf(List<Map<String, dynamic>> Data) async {
  final pdf = pw.Document();

  // Calculate total debit and credit
  double totalDebit = 0;
  double totalCredit = 0;

  for (var report in Data) {
    totalDebit += double.tryParse(report['Amount']?.toString() ?? '0') ?? 0;
    totalCredit += double.tryParse(report['Total']?.toString() ?? '0') ?? 0;
  }

  double closingBalance = totalDebit - totalCredit;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Reciept Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['No', 'Date', 'Debit', 'Credit', 'Name', 'Discount', 'Narration'],
              data: [
                ...Data.map((report) {
                  return [
                    report['auto'].toString(),
                    report['ddate'] ?? '',
                    report['Amount']?.toString() ?? 'N/A',
                    report['Total']?.toString() ?? 'N/A',
                    report['Name'] ?? 'N/A',
                    report['Discount']?.toString() ?? 'N/A',
                    report['Narration'] ?? 'N/A',
                  ];
                }).toList(),
                ['', '', 'Closing Balance', closingBalance.toStringAsFixed(2), '', '', ''],
              ],
            ),
          ],
        );
      },
    ),
  );

  final output = await getExternalStorageDirectory();
  final file = File("${output!.path}/payment_report.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}


void _generateAndViewPDF() async {
  File pdfFile = await generatePdf(Data);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReciPDFscreen(pdfFile),
    ),
  );
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
              "Receipt Report",  
              style: appbarFonts(screenHeight * 0.02, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight * 0.02),
            child: GestureDetector(
              onTap: () {
              _generateAndViewPDF();
              },
              child: SizedBox(
                width: 20,
                height: 20,
                child: Icon(Icons.download,color: Colors.white,),
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
                1: FixedColumnWidth(120),
                2: FixedColumnWidth(150),
                3: FixedColumnWidth(150),
                4: FixedColumnWidth(150),
                5: FixedColumnWidth(150),
                6: FixedColumnWidth(150),
              },
              children: [
                // Table header row
                TableRow(
                  children: [
                    _buildHeaderCell('No'),
                      _buildHeaderCell('Date'),
                      _buildHeaderCell('Debit'),
                      _buildHeaderCell('Credit'),
                      
                       _buildHeaderCell('Name'),
                       _buildHeaderCell('Discount'),
                      _buildHeaderCell('Narration'),
                  ],
                ),
                // Table data rows
                ...Data.map((data) {
                  return TableRow(
                    children: [
                  _buildDataCell(data['auto'].toString()), 
                     _buildDataCell(data['ddate'].toString()), 
                     _buildDataCell(data['Amount'] != null ? data['Amount'].toString() : 'N/A'), 
                    _buildDataCell(data['Total'] != null ? data['Total'].toString() : 'N/A'), 
                      _buildDataCell(data['Name'] ?? 'N/A'), 
                      _buildDataCell(data['Discount'] != null ? data['Discount'].toString() : 'N/A'), 
                       _buildDataCell(data['Narration'] ?? 'N/A'),
                      // _buildDataCell(data[ReceiptDatabaseHelper.columnId].toString()),
                      // _buildDataCell(data[ReceiptDatabaseHelper.columnDate].toString()),
                      // _buildDataCell(data[ReceiptDatabaseHelper.columnLedgerName].toString()),
                      // _buildDataCell(data[ReceiptDatabaseHelper.columnDiscount].toString()),
                      // _buildDataCell(data[ReceiptDatabaseHelper.columnTotal].toString()),
                      // _buildDataCell(data[ReceiptDatabaseHelper.columnNarration].toString()),
                    ],
                  );
                }).toList(),
                      TableRow(
      children: [
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell2('Closing Balance'),
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell(''),
      ],
    ),
                // TableRow(
                //   children: [
                //     _buildDataCell(''),
                //     _buildDataCell(''),
                //     _buildDataCell2(widget.ledgerName != null && widget.ledgerName!.isNotEmpty ? 'Closing Balance' : 'Closing Balance'),
                //   _buildDataCell2(widget.ledgerName != null && widget.ledgerName!.isNotEmpty ? totalAmount.toStringAsFixed(2) : totalAmount.toStringAsFixed(2)),
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
      color: Colors.white,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,  
        softWrap: false,  
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
