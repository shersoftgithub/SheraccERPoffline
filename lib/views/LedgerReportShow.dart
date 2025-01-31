import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/ledgerbackupDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class ShowLedger extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? ledgerName;
final bool? showOpeningBalance; 
  const ShowLedger({super.key, this.fromDate, this.toDate, this.ledgerName,this.showOpeningBalance});

  @override
  State<ShowLedger> createState() => _ShowSalesReportState();
}

class _ShowSalesReportState extends State<ShowLedger> {
  List<Map<String, dynamic>> ledgerData = [];
  double totalOpeningBalance = 0.0;  
double OpeningBalance = 0.0;  
  @override
  void initState() {
    super.initState();
    // _fetchLedgerData();
    // _fetchLedgerData2();
   _fetchFilteredData();
    //_fetchStockData2();
  }

Future<void> _fetchFilteredData() async {
  String? fromDateStr = widget.fromDate != null ? DateFormat('dd-MM-yyyy').format(widget.fromDate!) : null;
  String? toDateStr = widget.toDate != null ? DateFormat('dd-MM-yyyy').format(widget.toDate!) : null;

  // Fetch data filtered by ledger name, date range, and other filters
  List<Map<String, dynamic>> data = await LedgerTransactionsDatabaseHelper.instance.queryFilteredLedgerRows(
    fromDate: widget.fromDate,
    toDate: widget.toDate,
    ledgerName: widget.ledgerName ?? '',
  );

  // Using Future.wait to resolve the futures and map the results
  List<Map<String, dynamic>> ledgerDataList = await Future.wait(data.map((ledger) async {
    String? dateString = ledger['date'];
    DateTime? ledgerDate;

    if (dateString != null && dateString.isNotEmpty) {
      try {
        ledgerDate = DateFormat('dd-MM-yyyy').parse(dateString);
      } catch (e) {
        print("Error parsing date: $e");
        ledgerDate = DateTime.now();
      }
    } else {
      ledgerDate = DateTime.now();
    }

    // Fetch the debit amount for the current ledger from the Account_Transaction table
    double debitAmount = await LedgerTransactionsDatabaseHelper.instance.getDebitAmountForLedger(ledger['LedName'] ?? '');

    double openingBalance = double.tryParse(ledger['OpeningBalance']?.toString() ?? '0') ?? 0.0;
 double totalOpeningBalance2 = openingBalance + debitAmount;
 totalOpeningBalance=totalOpeningBalance2;
 OpeningBalance=openingBalance;
    // Combine debit and opening balance to get the total opening balance for the ledger
    return {
      ...ledger,
      'date': ledgerDate,
      'OpeningBalance': openingBalance , // Total Opening Balance = Opening + Debit
    };
  }).toList());

  setState(() {
    ledgerData = ledgerDataList;
   
  });
}



List ledgerdata=[];
Future<void> _fetchStockData2() async {
  try {
    List<Map<String, dynamic>> data = await LedgerTransactionsDatabaseHelper.instance.getLedgerData();
    print('Fetched stock data: $data');
        data.sort((a, b) {
      var ledcodeA = a['Ledcode']?.toString() ?? '0'; 
      var ledcodeB = b['Ledcode']?.toString() ?? '0'; 
      
      int ledcodeAInt = int.tryParse(ledcodeA) ?? 0;
      int ledcodeBInt = int.tryParse(ledcodeB) ?? 0;

      return ledcodeAInt.compareTo(ledcodeBInt); 
    });

    setState(() {
      ledgerData = data;
    });
  } catch (e) {
    print('Error fetching stock data: $e');
  }
}


Future<void> _exportToExcel() async {
  var excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1']; 

  List<String> headers = [
    'Ledger Name', 'Address', 'Contact', 'Email', 'Tax No', 'Price Level',
    'Balance', 'Opening Balance', 'Received Balance', 'Pay Amount', 'Under'
  ];

  sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

 for (var data in ledgerData) {
  List<CellValue> row = [
    TextCellValue(data['ledger_name']?.toString() ?? 'N/A'),
    TextCellValue(data['address']?.toString() ?? 'N/A'),
    TextCellValue(data['contact']?.toString() ?? 'N/A'),
    TextCellValue(data['mail']?.toString() ?? 'N/A'),
    TextCellValue(data['tax_no']?.toString() ?? 'N/A'),
    TextCellValue(data['price_level']?.toString() ?? 'N/A'),
    TextCellValue(data['balance']?.toString() ?? '0'), // Convert to string
    TextCellValue(data['opening_balance']?.toString() ?? '0'), // Convert to string
    TextCellValue(data['received_balance']?.toString() ?? '0'), // Convert to string
    TextCellValue(data['pay_amount']?.toString() ?? '0'), // Convert to string
    TextCellValue(data['under']?.toString() ?? 'N/A'),
  ];
  sheet.appendRow(row);
}


  final directory = await getExternalStorageDirectory();
  final path = '${directory?.path}/ledger_report.xlsx';

  final file = File(path);
  await file.writeAsBytes(await excel.encode()!);

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excel file saved at: $path')));
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
              "Ledger Report",
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
          IconButton(onPressed: (){_exportToExcel();},
           icon: Icon(Icons.file_download,size: 19,))
        ],
      ),
      body: SingleChildScrollView( 
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SingleChildScrollView( 
            scrollDirection: Axis.vertical,
            child: Table(
  border: TableBorder.all(
    color: Colors.black,
    width: 1.0,
  ),
  columnWidths: {
    0: FixedColumnWidth(60), 
    1: FixedColumnWidth(120),
    2: FixedColumnWidth(120), 
    3: FixedColumnWidth(120),
    4: FixedColumnWidth(190),
    5: FixedColumnWidth(120),
    6: FixedColumnWidth(120),
    7: FixedColumnWidth(140),
    8: FixedColumnWidth(140),
    9: FixedColumnWidth(140),
    10: FixedColumnWidth(120),
    11: FixedColumnWidth(120),
     12: FixedColumnWidth(120),
  },
  children: [
    TableRow(
      children: [
        _buildHeaderCell('SiNo'),
        _buildHeaderCell('Ledcode'),
        _buildHeaderCell('Ledger Name'),
        _buildHeaderCell('Address'),
        _buildHeaderCell('Contact'),
        _buildHeaderCell('Email'),
        _buildHeaderCell('Tax No'),
        _buildHeaderCell('Price Level'),
        _buildHeaderCell('Balance'),
        _buildHeaderCell('Opening Balance'),
        _buildHeaderCell('Received Balance'),
        _buildHeaderCell('Pay Amount'),
        _buildHeaderCell('Under'),
      ],
    ),
   ...ledgerData.asMap().entries.map((entry) {
                  int index = entry.key + 1; // Generate SiNo
                  Map<String, dynamic> data = entry.value;
      return TableRow(
        children: [
           _buildDataCell(index.toString()),
          _buildDataCell(data['Ledcode'] ?? 'N/A'),
          _buildDataCell(data['LedName'] ?? 'N/A'),
          _buildDataCell(data['add1'] ?? 'N/A'),
          _buildDataCell(data['Mobile'] ?? 'N/A'),
          _buildDataCell(data['Email'] ?? 'N/A'),
          _buildDataCell(data['tax_no'] ?? 'N/A'),
          _buildDataCell(data['price_level'] ?? 'N/A'),
          _buildDataCell(data['balance']?.toString() ?? 'N/A'),
          widget.showOpeningBalance! 
            ? _buildDataCell(data['OpeningBalance']?.toString() ?? '0') 
            : _buildDataCell(data['OpeningBalance']?.toString() ?? '0'), 
          _buildDataCell(data['Debit']?.toString() ?? '0') ,
          _buildDataCell(data['CAmount']?.toString() ?? '0'),
          _buildDataCell(data['under'] ?? 'N/A'),
        ],
      );
    }).toList(),
    TableRow(
      children: [
         _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell2('Closing Balance'),
        _buildDataCell2(OpeningBalance.toStringAsFixed(2)), 
        _buildDataCell(''),
        _buildDataCell(''),
        _buildDataCell(''),
      ],
    ),
    TableRow(
  children: [
    _buildDataCell(''),
    _buildDataCell(''),
    _buildDataCell(''),
    _buildDataCell(''),
    _buildDataCell(''),
    _buildDataCell(''),
    _buildDataCell(''),
    _buildDataCell(''),
    widget.showOpeningBalance == true
        ? _buildDataCell2('Opening Balance')
        : _buildDataCell(''), // Display Opening Balance based on flag
    widget.showOpeningBalance == true
        ? _buildDataCell(totalOpeningBalance.toStringAsFixed(2)) // Display Opening Balance value
        : _buildDataCell(''), 
    _buildDataCell(''),
    _buildDataCell(''),
    _buildDataCell(''),
  ],
),
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
