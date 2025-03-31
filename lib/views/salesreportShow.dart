import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/pdf_report/sale_pdf.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_info2.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_refer.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ShowSalesReport extends StatefulWidget {
  final String? customerName;
  final String? itemName;
  final String? itemcode;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<String>? stype;
  const ShowSalesReport({
    super.key,
    this.customerName,
    this.itemcode,
    this.itemName,
    this.fromDate,
    this.toDate,
    this.stype
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
     fetchSalesParticulars();
    _fetchFilteredData();
    fetchSaleStock();
    _fetchSType();
  }

List<Map<String, dynamic>> salesParticulars = [];
Future<void> fetchSalesParticulars() async {
  List<Map<String, dynamic>> data = await SalesInformationDatabaseHelper2.instance.getSalesDataperticular();

  setState(() {
    salesParticulars = data;
  });
}

List<Map<String, dynamic>> stocklist = [];
Future<void> fetchSaleStock() async {
  List<Map<String, dynamic>> data = await StockDatabaseHelper.instance.getItemDetails();

  setState(() {
    salesParticulars = data;
  });
}
 
String selectedStype = 'Sales Order'; 
String selectedID = '0'; 
List stypelist = [];

Future<void> _fetchSType() async {
  try {
    List<Map<String, dynamic>> data = await SaleReferenceDatabaseHelper.instance.getAllStype();
    print('Fetched stock data: $data');

    setState(() {
      stypelist = data;

      var selectedItems = stypelist.where((item) => item['isChecked'] == 1).toList();

      if (selectedItems.isNotEmpty) {
        selectedStype = selectedItems.first['Type'] ?? 'Sales Order';
        selectedID = selectedItems.first['iD'] ?? '0';
      } else {
        selectedStype = 'Sales Order'; 
        selectedID = '0';
      }
    });
  } catch (e) {
    print('Error fetching stock data: $e');
  }
}


  Future<void> _fetchFilteredData() async {
  String? fromDateStr = widget.fromDate != null ? DateFormat('yyyy-MM-dd').format(widget.fromDate!) : null;
  String? toDateStr = widget.toDate != null ? DateFormat('yyyy-MM-dd').format(widget.toDate!) : null;
         
  List<Map<String, dynamic>> ledgerData = await LedgerTransactionsDatabaseHelper.instance.fetchLedgerCodesAndNames();
  Map<String, String> ledgerCodeToNameMap = {
    for (var ledger in ledgerData) ledger['Ledcode'].toString(): ledger['LedName'].toString()
  };

  List<Map<String, dynamic>> data = await SalesInformationDatabaseHelper2.instance.queryFilteredRowsPay(
    fromDate: widget.fromDate!,
    toDate: widget.toDate!,
    ledgerName: widget.customerName,
    itemcode: widget.itemcode,
    itemname: null, 
  );

  List<Map<String, dynamic>> stockData = await StockDatabaseHelper.instance.getItemDetails();
  Map<String, String> itemIdToNameMap = {
    for (var stock in stockData) stock['productItemId'].toString(): stock['itemname'].toString()
  };

  List<Map<String, dynamic>> filteredData = data.where((ledger) {
    String? itemID = ledger['ItemID']?.toString();
    String itemName = itemIdToNameMap[itemID] ?? 'N/A';
    return itemName.contains(widget.itemName ?? '');
  }).toList();

  setState(() {
    paymentData = filteredData.map((ledger) {
      String? ledCode = ledger['Customer']?.toString();
      String? ledName = ledgerCodeToNameMap[ledCode] ?? 'N/A';

      String? itemID = ledger['ItemID']?.toString();
      String itemName = itemIdToNameMap[itemID] ?? 'N/A';

      String formattedDate = 'N/A';
      if (ledger['InfoDDate'] != null && ledger['InfoDDate'].toString().isNotEmpty) {
        try {
          DateTime parsedDate = DateTime.parse(ledger['InfoDDate'].toString());
          formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
        } catch (e) {
          print("Error parsing date: $e");
        }
      }


String stype = ledger['SType']?.toString() ?? 'N/A';
if (stype == '0') {
  stype = 'Sales Order'; 
} else {
  var matchingType = stypelist.firstWhere(
    (item) => item['iD'] == stype, 
    orElse: () => {'Type': 'Unknown'}
  );
  
  stype = matchingType['Type'] ?? 'Other Status';  
}

      return {
        ...ledger,
        'Name': ledName,
        'ddate': formattedDate,
        'Rate': ledger['Rate']?.toString() ?? 'N/A',
        'ItemID': itemID ?? 'N/A',
        'itemname': itemName,
        'SType': stype,
      };
    }).toList();
  });
}

Future<File> generatePdf(List<Map<String, dynamic>> data) async {
  final pdf = pw.Document();
  double totalDebit = 0;
  double totalCredit = 0;

  for (var report in data) {
    totalDebit += double.tryParse(report['Amount']?.toString() ?? '0') ?? 0;
    totalCredit += double.tryParse(report['Total']?.toString() ?? '0') ?? 0;
  }

  double closingBalance = totalDebit - totalCredit;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a3,
      margin: pw.EdgeInsets.all(20),
      header: (context) => pw.Text(
        'Sale Report',
        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
      ),
      build: (pw.Context context) {
        return [
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(1), 
                1: pw.FlexColumnWidth(2), 
                2: pw.FlexColumnWidth(3), 
                3: pw.FlexColumnWidth(1), 
                4: pw.FlexColumnWidth(2), 
                5: pw.FlexColumnWidth(1), 
                6: pw.FlexColumnWidth(2), 
                7: pw.FlexColumnWidth(2), 
                8: pw.FlexColumnWidth(3),
                9: pw.FlexColumnWidth(2),
            },
            children: [
               pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('InNo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Customer', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('ItemId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Item Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Discount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('SType', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.center,)),
                  ],
                ),

              ...paymentData.map((data) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['EntryNo']?.toString() ?? '',textAlign: pw.TextAlign.center,)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['InfoDDate']?.toString() ?? '',textAlign: pw.TextAlign.center,)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['Toname']?.toString() ?? '')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['ItemID']?.toString() ?? '',textAlign: pw.TextAlign.center,)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['itemname']?.toString() ?? '')),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['TotalQty']?.toString() ?? '',textAlign: pw.TextAlign.center,)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['Rate']?.toString() ?? '',textAlign: pw.TextAlign.right,)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['Discount']?.toString() ?? '',textAlign: pw.TextAlign.right,)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['GrandTotal']?.toString() ?? '',textAlign: pw.TextAlign.right,)),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(data['SType']?.toString() ?? '',textAlign: pw.TextAlign.center,)),
                    ],
                  );
                }).toList(),
            ],
          ),
        ];
      },
    ),
  );

  final output = await getExternalStorageDirectory();
  final file = File("${output!.path}/Sale_report.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}

void _generateAndViewPDF() async {
  File pdfFile = await generatePdf(paymentData);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SalePDFscreen(pdfFile),
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
              "Sales Report",
              style: appbarFonts(screenHeight * 0.02, Colors.white),
            ),
          ),
        ),
        actions: [
           Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight * 0.02),
             child: IconButton(onPressed: (){
                     _generateAndViewPDF();
                       }, icon: Icon(Icons.download,color: Colors.white,)),
           ),
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
                0: FixedColumnWidth(80),
                1: FixedColumnWidth(100),
                2: FixedColumnWidth(120),
                3: FixedColumnWidth(60),
                4: FixedColumnWidth(120),
                5: FixedColumnWidth(40),
                6: FixedColumnWidth(80),
                7: FixedColumnWidth(70),
                 8: FixedColumnWidth(80),
                 9: FixedColumnWidth(80),
              },
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell('Invoice No'),
                    _buildHeaderCell('Date'),
                    _buildHeaderCell('Cutomer Name'),
                    _buildHeaderCell('itemId'),
                    _buildHeaderCell('Itemname'),
                    _buildHeaderCell('Qty'),
                    _buildHeaderCell('Rate'),
                    _buildHeaderCell('Dicount'),
                    _buildHeaderCell('Total'),
                    _buildHeaderCell('SType'),
                    
                  ],
                ),
                ...paymentData.map((data) {
                  return TableRow(
                    children: [
                       
                  _buildDataCell(data['EntryNo'].toString()),
                  _buildDataCell(data['InfoDDate'].toString()),
                  _buildDataCell(data['Toname'].toString()),
                  _buildDataCell(data['ItemID'].toString()),
                  _buildDataCell(data['itemname'].toString()),
                  _buildDataCell(data['TotalQty'].toString()),
                  _buildDataCell3(data['Rate'].toString()),
                  _buildDataCell3(data['Discount'].toString()),
                  _buildDataCell3(data['GrandTotal'].toString()),
                  _buildDataCell(data['SType'].toString()),
                  
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
      color: Colors.blue,
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        style: getFonts(11, Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell3(String text) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.right,
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


