import 'dart:convert';

import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:mssql_connection/mssql_connection_platform_interface.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/options.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/views/LedgerReportShow.dart';

class LedgerReport extends StatefulWidget {
  const LedgerReport({super.key});

  @override
  State<LedgerReport> createState() => _LedgerReportState();
}

class _LedgerReportState extends State<LedgerReport> {
  final TextEditingController ledgernamesController=TextEditingController();
  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate ?? DateTime.now() : _toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = selectedDate;
        } else {
          _toDate = selectedDate;
        }
      });
    }
  }
   String selectedValue = "Report Type";
  bool isExpanded = false; 
  
  optionsDBHelper dbHelper=optionsDBHelper();
List purcahse_reportType=[];
Future<void> salesreporttype()async{
  purcahse_reportType=await dbHelper.getOptionsByType("purcahse_reportType");
}
final GlobalKey _arrowKey = GlobalKey();
 bool _isChecked = false;

 @override
  void initState() {
    super.initState();
   _fetchLedger();
   
  }

   List <String> names=[];

Future<void> _fetchLedger() async {
    List<String> cname = await LedgerTransactionsDatabaseHelper.instance.getAllNames();

  setState(() {
    names=cname;
  });
}

Future<void> fetchAndStoreLedgerData(
    DateTime? fromDate, DateTime? toDate, String ledgerName) async {
  try {
    
    final query = '''
      EXEC dbo.Sp_AccountReport 
      @statementType='Simple_LedgerReport',
      @fromdate=${_fromDate != null ? "'$_fromDate'" : 'NULL'},
      @todate=${_toDate != null ? "'$_toDate'" : 'NULL'},
      @ledcode='${ledgerName}'
    ''';
    print(query);
    final rawData = await MsSQLConnectionPlatform.instance.getData(query);
    print(rawData);
    if (rawData != null) {
      print(rawData);
    } else {
      print("No data received from SQL Server.");
    }
  } catch (e) {
    print("Error fetching or storing ledger data: $e");
  }
}



void _showLedgerWithFilters() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ShowLedger(
        fromDate: _fromDate,
        toDate: _toDate,
        ledgerName: ledgernamesController.text,
        showOpeningBalance: _isChecked,
      ),
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
        child: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios_new_sharp,color: Colors.white,size: 20,)),
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
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: IconButton(
              onPressed: () {},
              icon: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            
            SizedBox(height: screenHeight * 0.02),
            Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("select Ledger Name",style: formFonts(12, Colors.black),),
                 SizedBox(height: screenHeight * 0.01),
                Container(
                  height: screenHeight * 0.05,
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    border: Border.all(color: Appcolors().searchTextcolor),
                  ),
                  child:  Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: SingleChildScrollView(
                    child: EasyAutocomplete(
                        controller: ledgernamesController,
                        suggestions: names,

                        onSubmitted: (value) {
                                  },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                  ),
                ),
                ),
              ],
            ),
         SizedBox(height: screenHeight * 0.03),
             Padding(
               padding:  EdgeInsets.symmetric(horizontal: screenHeight *0.02),
               child: Container(
                 height: 39,
                 width: screenWidth*0.9,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5),
                   color: Colors.white,
                   border: Border.all(color: Appcolors().searchTextcolor)
                 ),
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        GestureDetector(
                onTap: () => _selectDate(context, true),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: Appcolors().maincolor ), // Adjust color as needed
                    SizedBox(width: 5),
                    Text(
                      _fromDate != null ? _dateFormat.format(_fromDate!) : "From Date",
                      style: getFonts(13, _fromDate != null ? Appcolors().maincolor : Colors.grey),
                    ),
                  ],
                ),
              ),
                       Text("-", style: TextStyle(color: Appcolors().maincolor)),
                      GestureDetector(
                onTap: () => _selectDate(context, false),
                child: Row(
                  children: [
                    Text(
                      _toDate != null ? _dateFormat.format(_toDate!) : "To Date",
                      style: getFonts(13, _fromDate != null ? Appcolors().maincolor : Colors.grey),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.calendar_month_outlined, color: Appcolors().maincolor ), 
                  ],
                ),
              ),
                     ],
                   ),
                 ),
               ),
             ),
            
                   SizedBox(height: screenHeight * 0.01),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 5),
                     child: Row(
                           children: [
                             Checkbox(
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                        
                        checkColor: Colors.white,
                        activeColor: _isChecked ? Appcolors().maincolor : Colors.transparent, 
                      ),
                      Text("Opening Balance",style: getFonts(14, Colors.black),)
                           ],
                         ),
                   ),
                  GestureDetector(
          onTap:() {
          _showLedgerWithFilters();
           // fetchAndStoreLedgerData(_fromDate, _toDate, ledgernamesController.text);
            },
          child: Padding(
            padding: EdgeInsets.all(screenHeight * 0.03),
            child: Container(
              height: screenHeight * 0.05,
              width: screenWidth * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFF0A1EBE),
              ),
              child: Center(
                child: Text(
                  "Show",
                  style: getFonts(screenHeight * 0.02, Colors.white),
                ),
              ),
            ),
          ),
        )
          ],
        ),
      ),
    );
  }
  void _showPopupMenu() async {
  await salesreporttype();
  if (purcahse_reportType.isEmpty) {
    return; 
  }

  final RenderBox arrowBox =
      _arrowKey.currentContext!.findRenderObject() as RenderBox;
  final Offset arrowPosition = arrowBox.localToGlobal(Offset.zero);
  final Size arrowSize = arrowBox.size;

  final selected = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      arrowPosition.dx,
      arrowPosition.dy + arrowSize.height,
      arrowPosition.dx + arrowSize.width,
      arrowPosition.dy,
    ),
    items: purcahse_reportType 
        .map(
          (type) => PopupMenuItem<String>(
            value: type,
            child: Text(type, style: getFonts(13, Colors.black)),
          ),
        )
        .toList(),
    elevation: 8.0,
  );

  if (selected != null) {
    setState(() {
      selectedValue = selected;
      isExpanded = false;
    });
  } else {
    setState(() {
      isExpanded = false;
    });
  }
}
}