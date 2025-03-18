import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
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
double totalDebitAmount = 0.0;
double totalCreditAmount = 0.0;
double finalClosingBalance = 0.0;



  @override
  void initState() {
    super.initState();
    // _fetchLedgerData();
    // _fetchLedgerData2();
   _fetchFilteredData();
    //_fetchStockData2();
  }

Future<void> _fetchFilteredData() async {
  String? fromDateStr = widget.fromDate != null ? DateFormat('yyyy-MM-dd').format(widget.fromDate!) : null;
  String? toDateStr = widget.toDate != null ? DateFormat('yyyy-MM-dd').format(widget.toDate!) : null;

  List<Map<String, dynamic>> data = await LedgerTransactionsDatabaseHelper.instance.fetchSimpleLedgerReport(
    ledname: widget.ledgerName!,
    fromdate: fromDateStr!,
    todate: toDateStr!,
  );

  double totalOpening = 0.0;
  double closingBalance = 0.0;
  double totalDebit = 0.0;
  double totalCredit = 0.0;

  List<Map<String, dynamic>> ledgerDataList = await Future.wait(data.map((ledger) async {
    if (ledger['Particulars'] == 'Opening Balance') {
      totalOpening = double.tryParse(ledger['Debit']?.toString() ?? '0') ?? 0.0;
    }

    double debitAmount = double.tryParse(ledger['Debit']?.toString() ?? '0') ?? 0.0;
    double creditAmount = double.tryParse(ledger['Credit']?.toString() ?? '0') ?? 0.0;

    totalDebit += debitAmount;
    totalCredit += creditAmount;

    return ledger;
  }).toList());

  closingBalance = totalDebit - totalCredit;

  setState(() {
    ledgerData = ledgerDataList;
    totalOpeningBalance = totalOpening;
    totalDebitAmount = totalDebit;
    totalCreditAmount = totalCredit;
    finalClosingBalance = closingBalance;
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
    Sheet sheet = excel['LedgerReport'];

    List<String> headers = ['Date', 'Particulars', 'Voucher', 'EntryNo', 'Debit', 'Credit', 'Balance', 'Narration'];
    sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

    for (var data in ledgerData) {
      sheet.appendRow([
        TextCellValue(data['date']?.toString() ?? 'N/A'),
        TextCellValue(data['Particulars']?.toString() ?? 'N/A'),
        TextCellValue(data['Voucher']?.toString() ?? 'N/A'),
        TextCellValue(data['EntryNo']?.toString() ?? 'N/A'),
        TextCellValue(data['Debit']?.toString() ?? '0'),
        TextCellValue(data['Credit']?.toString() ?? '0'),
        TextCellValue(data['Balance']?.toString() ?? '0'),
        TextCellValue(data['Narration']?.toString() ?? 'N/A'),
      ]);
    }

    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/ledger_report.xlsx';
    final file = File(path);
    await file.writeAsBytes(await excel.encode()!);

    Fluttertoast.showToast(msg: "Download Completed!", gravity: ToastGravity.BOTTOM);
    OpenFilex.open(path);
  }

Future<void> _shareReport() async {
  var excel = Excel.createExcel();
  Sheet sheet = excel['LedgerReport'];

  List<String> headers = ['Date', 'Particulars', 'Voucher', 'EntryNo', 'Debit', 'Credit', 'Balance', 'Narration'];
  sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

  for (var data in ledgerData) {
    sheet.appendRow([
      TextCellValue(data['date']?.toString() ?? 'N/A'),
      TextCellValue(data['Particulars']?.toString() ?? 'N/A'),
      TextCellValue(data['Voucher']?.toString() ?? 'N/A'),
      TextCellValue(data['EntryNo']?.toString() ?? 'N/A'),
      TextCellValue(data['Debit']?.toString() ?? '0'),
      TextCellValue(data['Credit']?.toString() ?? '0'),
      TextCellValue(data['Balance']?.toString() ?? '0'),
      TextCellValue(data['Narration']?.toString() ?? 'N/A'),
    ]);
  }

  if (await _requestPermission()) {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/ledger_report.xlsx';
    final file = File(path);
    List<int>? bytes = await excel.encode();
    if (bytes == null) {
      Fluttertoast.showToast(msg: "Error generating report!", gravity: ToastGravity.BOTTOM);
      return;
    }
    await file.writeAsBytes(bytes);
    try {
      await Share.shareXFiles([XFile(path)], text: 'Here is the Ledger Report.');
    } catch (e) {
      Fluttertoast.showToast(msg: "Sharing failed: $e", gravity: ToastGravity.BOTTOM);
    }
  } else {
    Fluttertoast.showToast(msg: "Storage permission denied!", gravity: ToastGravity.BOTTOM);
  }
}
Future<bool> _requestPermission() async {
  var status = await Permission.storage.request();
  return status.isGranted;
}


Future<void> _downloadExcel() async {
  if (await Permission.storage.request().isDenied) {
    Fluttertoast.showToast(msg: "Storage permission denied!");
    return;
  }

  var excel = Excel.createExcel();
  Sheet sheet = excel['LedgerReport'];

  List<String> headers = ['Date', 'Particulars', 'Voucher', 'EntryNo', 'Debit', 'Credit', 'Balance', 'Narration'];
  sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

  for (var data in ledgerData) {
    sheet.appendRow([
      TextCellValue(data['date']?.toString() ?? 'N/A'),
      TextCellValue(data['Particulars']?.toString() ?? 'N/A'),
      TextCellValue(data['Voucher']?.toString() ?? 'N/A'),
      TextCellValue(data['EntryNo']?.toString() ?? 'N/A'),
      TextCellValue(data['Debit']?.toString() ?? '0'),
      TextCellValue(data['Credit']?.toString() ?? '0'),
      TextCellValue(data['Balance']?.toString() ?? '0'),
      TextCellValue(data['Narration']?.toString() ?? 'N/A'),
    ]);
  }

  Directory? downloadsDir = Directory('/storage/emulated/0/Download/');
  if (!downloadsDir.existsSync()) {
    downloadsDir.createSync(recursive: true);
  }

  final path = '${downloadsDir.path}/ledger_report.xlsx';
  final file = File(path);
  await file.writeAsBytes(await excel.encode()!);

  //Fluttertoast.showToast(msg: "Download Completed", gravity: ToastGravity.BOTTOM);

  _showDownloadDialog(path);
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
          padding:  EdgeInsets.only(top: screenHeight * 0.02, left: screenWidth * 0.02),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_sharp,
              color: Colors.white,
              size: screenWidth * 0.04,
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
           Padding(
            padding:  EdgeInsets.only(top: screenHeight*0.02, right: screenHeight*0.02),
            child: PopupMenuButton<String>(
              onSelected: (String selectedItem) async{
                if (selectedItem == 'Share') {
                await _shareReport();
                }else if (selectedItem== "Download"){
                await _downloadExcel();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'Share',
                    child: Text('Share'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Download',
                    child: Text('Download'),
                  ),
                ];
              },
              child: Icon(Icons.more_vert,color: Colors.white,size: screenHeight*0.03,),
            ),
          ),
          // IconButton(onPressed: (){_exportToExcel();},
          //  icon: Icon(Icons.file_download,size: 19,))
        ],
      ),
      body: SingleChildScrollView( 
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding:  EdgeInsets.only(top: screenHeight*0.02,),
          child: SingleChildScrollView( 
            scrollDirection: Axis.vertical,
            
            child: Column(
              children: [
              //   Text('ACCOUNT SUMMERY',style: getFonts(16, Colors.black),),
              //  Text('${widget.ledgerName}',style: getFonts(14, Colors.black),),
                Container(
                  child: Table(
                    
                    border: TableBorder.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                    columnWidths: {
                      
                      0: FixedColumnWidth(80),
                      1: FixedColumnWidth(140), 
                      //2: FixedColumnWidth(100),
                      2: FixedColumnWidth(110),
                      3: FixedColumnWidth(110),
                      4: FixedColumnWidth(140),
                      //7: FixedColumnWidth(140),
                      // 9: FixedColumnWidth(140),
                      // 10: FixedColumnWidth(120),
                      // 11: FixedColumnWidth(120),
                      //  12: FixedColumnWidth(120),
                    },
                    children: [
                      TableRow(
                        children: [
                          
                          _buildHeaderCell('Date'),
                          _buildHeaderCell('Particulars'),
                          //_buildHeaderCell('Voucher'),
                         // _buildHeaderCell('EntryNo'),
                          _buildHeaderCell('Debit'),
                          _buildHeaderCell('Credit'),
                          _buildHeaderCell('Balance'),
                         // _buildHeaderCell('Narration'),
                          
                        ],
                      ),
                     ...ledgerData.asMap().entries.map((entry) {
                        int index = entry.key + 1; 
                        Map<String, dynamic> data = entry.value;
                        Color rowColor = (index % 2 == 0) ? Colors.white : Colors.white;
                        return TableRow(
                          children: [
                            _buildDataCell(data['Date']?.toString()  ?? 'N/A',rowColor),
                            _buildDataCellleft(data['Particulars']?.toString() ?? 'N/A',rowColor),
                            //_buildDataCell(data['Voucher'] ?.toString() ?? 'N/A',rowColor),
                           // _buildDataCell(data['EntryNo']?.toString() ??'N/A',rowColor),
                            _buildDataCellright(data['Debit'] ?.toString() ??'N/A',rowColor),
                            _buildDataCellright(data['Credit'] ?.toString() ?? 'N/A',rowColor),
                            _buildDataCellright(data['Balance'] ?.toString() ??'N/A',rowColor),
                            //_buildDataCell(data['Narration']?.toString() ?? 'N/A',rowColor),
                           
                          ],
                        );
                      }).toList(),
                     
                    ],
                  ),
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
      color: Colors.blue,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11),
      ),
    );
  }

  Widget _buildDataCell(String text,Color rowColor) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      color: rowColor,
      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCellright(String text,Color rowColor) {
    return Container(
      padding: const EdgeInsets.only(left: 6,top: 6,bottom: 6,right: 4),
      color: rowColor,
      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.right,
      ),
    );
  }
   Widget _buildDataCellleft(String text,Color rowColor) {
    return Container(
      padding: const EdgeInsets.only(left: 6,top: 6,bottom: 6,right: 4),
      color: rowColor,
      child: Text(
        text,
        style: getFonts(10, Colors.black),
        textAlign: TextAlign.left,
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

 void _showDownloadDialog(String filePath ) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          width: 250, 
          height: 160, 
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,  
            children: [
              Text(
                "Download Completed",
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Your Excel report has been saved successfully.",
                textAlign: TextAlign.center,
              ),
             
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close",style: getFonts(13, Appcolors().maincolor)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      OpenFilex.open(filePath);
                    },
                    child: Text("View",style: getFonts(13, Appcolors().maincolor),),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

}
