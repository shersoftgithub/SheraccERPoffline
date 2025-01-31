import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/payment_databsehelper.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/paymentreportShow.dart';

class Paymentreport extends StatefulWidget {
  const Paymentreport({super.key});

  @override
  State<Paymentreport> createState() => _PaymentreportState();
}

class _PaymentreportState extends State<Paymentreport> {
  final  TextEditingController ledgernamesController=TextEditingController();
  final  TextEditingController selectledgernamesController=TextEditingController();
  final  TextEditingController selectsalesmanController=TextEditingController();
  final  TextEditingController selectgroupController=TextEditingController();
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

   @override
  void initState() {
    super.initState();
   _fetchLedgerNames();
  }
  List <String>ledgerNames = [];
  Future<void> _fetchLedgerNames() async {
  List<String> names = await LedgerTransactionsDatabaseHelper.instance.getAllNames();
    setState(() {
    ledgerNames = names; 
    });
  }
  


void _showLedgerWithFilters() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ShowPaymentReport(
        fromDate: _fromDate,
        toDate: _toDate,
        ledgerName: selectledgernamesController.text,
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
              "Payment Report",
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
              Padding(
               padding:  EdgeInsets.symmetric(horizontal: screenHeight *0.03),
               child: Container(
                 height: screenHeight * 0.05,
                 width: screenWidth * 0.9,
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
            SizedBox(height: screenHeight * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Cash",style: formFonts(13, Colors.black),),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    height: screenHeight * 0.05,
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(color: Appcolors().searchTextcolor),
                    ),
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: SingleChildScrollView(
                    child: EasyAutocomplete(
                      suggestionBackgroundColor: Appcolors().Scfold,
                        controller: ledgernamesController,
                       
                           
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
            ),
        
           
             SizedBox(height: screenHeight * 0.02),
            Container(padding: EdgeInsets.symmetric(horizontal: screenHeight*0.017),
              child: Column(
                children: [
                  SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: EasyAutocomplete(
                      controller: selectledgernamesController,
                      suggestions:ledgerNames,
                      onSubmitted: (value) {
                                },
                                    decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  hintText: "Select Ledger Name",
                  hintStyle: TextStyle(fontSize: 14)
                                ),
                  suggestionBackgroundColor: Appcolors().Scfold,
                    ),
                ),
              ),
                  // _paymentfield("select Ledger Name", selectledgernamesController, screenWidth, screenHeight),
             _paymentfield("select Salesman", selectsalesmanController, screenWidth, screenHeight),
             _paymentfield("select Group", selectgroupController, screenWidth, screenHeight),
                ],
              ),
            ),
                   SizedBox(height: screenHeight * 0.02),
                  GestureDetector(
          onTap: (){
            _showLedgerWithFilters();
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
   Widget _paymentfield(String txt,TextEditingController controller,double screenWidth, double screenHeight){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Please enter $textrow';
              //   }
              //   return null;
              // },
              obscureText: false,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                hintText: "$txt",
                hintStyle: TextStyle(fontSize: 14)
              ),
            ),
          ),
        ],
      ),
    );
  }
}