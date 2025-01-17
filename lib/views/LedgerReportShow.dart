import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
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
    _fetchStockData2();
  }
List ledgerdata=[];
Future<void> _fetchStockData2() async {
  try {
    List<Map<String, dynamic>> data = await LedgerDatabaseHelper.instance.getLedgerData();
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


Future<void> _fetchLedgerData() async {
  List<Map<String, dynamic>> data = await DatabaseHelper.instance.queryAllRows();
  
  // Filter by ledger name if provided
  // if (widget.ledgerName != null && widget.ledgerName!.isNotEmpty) {
  //   data = data.where((ledger) => ledger['ledger_name'].toLowerCase().contains(widget.ledgerName!.toLowerCase())).toList();
  // }

  // // Filter by date range if both fromDate and toDate are provided
  // if (widget.fromDate != null && widget.toDate != null) {
  //   data = data.where((ledger) {
  //     // Check if ledger['date'] is not null before parsing
  //     String? dateStr = ledger['date'];
  //     if (dateStr != null) {
  //       DateTime ledgerDate = DateTime.parse(dateStr);
  //       return ledgerDate.isAfter(widget.fromDate!) && ledgerDate.isBefore(widget.toDate!);
  //     }
  //     return false; // If date is null, exclude from results
  //   }).toList();
  // }

  setState(() {
    ledgerData = data.map((ledger) {
        String? dateString = ledger['date'];
        DateTime? ledgerDate;

        if (dateString != null && dateString.isNotEmpty) {
          try {
            ledgerDate = DateFormat('dd-MM-yyyy').parse(dateString);
          } catch (e) {
            print("Error parsing date: $e");
            print("Invalid date string: $dateString");

            ledgerDate = DateTime.now();
          }
        } else {
          print("Date string is empty or null for ledger: $ledger");
          ledgerDate = DateTime.now();
        }

        return {...ledger, 'date': ledgerDate};
      }).toList();
    ledgerData = data;

    // Calculate total opening balance safely
    totalOpeningBalance = ledgerData.fold(0.0, (sum, item) {
      double openingBalance = double.tryParse(item['opening_balance']?.toString() ?? '0') ?? 0.0;
      return sum + openingBalance;
    });

    // Calculate Opening Balance safely
    OpeningBalance = ledgerData.fold(0.0, (sum, item) {
      double payAmount = double.tryParse(item['pay_amount']?.toString() ?? '0') ?? 0.0;
      return sum + payAmount;
    });
  });
}


  Future<void> _fetchLedgerData2() async {
    String? fromDateStr = widget.fromDate != null ? DateFormat('dd-MM-yyyy').format(widget.fromDate!) : null;
  String? toDateStr = widget.toDate != null ? DateFormat('dd-MM-yyyy').format(widget.toDate!) : null;

  
  List<Map<String, dynamic>> data = await DatabaseHelper.instance.queryFilteredRows2(
    fromDateStr,  
    toDateStr,    
    widget.ledgerName ?? "",  
  );

    setState(() {
      ledgerData = data;
      totalOpeningBalance = ledgerData.fold(0.0, (sum, item) {
        double openingBalance = double.tryParse(item['opening_balance']?.toString() ?? '0') ?? 0.0;
        return sum + openingBalance;
      });
      OpeningBalance = ledgerData.fold(0.0, (sum, item) {
        double openingBalance = double.tryParse(item['pay_amount']?.toString() ?? '0') ?? 0.0;
        return sum + openingBalance;
      });
    });
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
          _buildDataCell(data['received_balance']?.toString() ?? '0') ,
          _buildDataCell(data['pay_amount']?.toString() ?? '0'),
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
        _buildDataCell2(totalOpeningBalance.toStringAsFixed(2)), // Display total opening balance
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
        widget.showOpeningBalance!?
        _buildDataCell2('Opening Balance'): _buildDataCell(''),
        widget.showOpeningBalance!
          ? _buildDataCell2(OpeningBalance.toStringAsFixed(2)) 
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
