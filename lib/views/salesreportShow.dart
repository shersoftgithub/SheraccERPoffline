import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/pdf_report/sale_pdf.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_info2.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_information.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_refer.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/salesDBHelper.dart'; // Adjust with your actual import
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

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
      if (ledger['DDate'] != null && ledger['DDate'].toString().isNotEmpty) {
        try {
          DateTime parsedDate = DateTime.parse(ledger['DDate'].toString());
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



Future<File> generatePdf(List<Map<String, dynamic>> paymentData) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Sales Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                'Invoice No', 'Date', 'Customer','ItemId','Item Name', 'Qty','Rate', 'Discount', 'Total', ''
              ],
              data: paymentData.map((data) {
                return [
                  data['RealEntryNo'].toString(),
                  data['InfoDDate'].toString(),
                  data['Toname'].toString(),
                  data['ItemID'].toString(),
                  data['itemname'].toString(),
                  data['Qty'].toString(),
                  data['Rate'].toString(),
                  data['Discount'].toString(),
                   data['GrandTotal'].toString(),
                    data['SType'].toString(),
                    
                ];
              }).toList(),
            ),
          ],
        );
      },
    ),
  );

  final output = await getExternalStorageDirectory();
  final file = File("${output!.path}/sales_report.pdf");
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
                0: FixedColumnWidth(100),
                1: FixedColumnWidth(100),
                2: FixedColumnWidth(200),
                3: FixedColumnWidth(100),
                4: FixedColumnWidth(150),
                5: FixedColumnWidth(100),
                6: FixedColumnWidth(150),
                7: FixedColumnWidth(100),
                 8: FixedColumnWidth(100),
                 9: FixedColumnWidth(100),
                // 10: FixedColumnWidth(100),
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
                       
                      _buildDataCell(data['RealEntryNo'].toString()),
                  _buildDataCell(data['InfoDDate'].toString()),
                  _buildDataCell(data['Toname'].toString()),
                  _buildDataCell(data['ItemID'].toString()),
                  _buildDataCell(data['itemname'].toString()),
                  _buildDataCell(data['TotalQty'].toString()),
                  _buildDataCell(data['Rate'].toString()),
                  _buildDataCell(data['Discount'].toString()),
                  _buildDataCell(data['GrandTotal'].toString()),
                  _buildDataCell(data['SType'].toString()),
                  
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
