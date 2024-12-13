import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class Paymentreport extends StatefulWidget {
  const Paymentreport({super.key});

  @override
  State<Paymentreport> createState() => _PaymentreportState();
}

class _PaymentreportState extends State<Paymentreport> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        }, icon: Icon(Icons.arrow_back_ios_new_sharp,color: Colors.white,size: 15,)),
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
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
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
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                     // controller: controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ';
                        }
                        return null;
                      },
                      obscureText: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
 SizedBox(height: screenHeight * 0.02),
           Padding(
             padding:  EdgeInsets.symmetric(horizontal: screenHeight *0.02),
             child: Container(
               height: 39,
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(8),
                 color: Colors.white,
                 border: Border.all(color: Appcolors().maincolor)
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
                           Icon(Icons.calendar_month_outlined, color: Appcolors().maincolor),
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
                             style: getFonts(13, _toDate != null ? Appcolors().maincolor : Colors.grey),
                           ),
                           SizedBox(width: 5),
                           Icon(Icons.calendar_month_outlined, color: Appcolors().maincolor),
                           
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
                 SizedBox(height: screenHeight * 0.02),
                GestureDetector(
        onTap: () {},
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
    );
  }
}