import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
 final TextEditingController _selectSupplierController=TextEditingController();
 final TextEditingController _selectItemcodeController=TextEditingController();
 final TextEditingController _selectItemnameController=TextEditingController();
 final TextEditingController _manufactureController=TextEditingController();
 final TextEditingController _categoryController=TextEditingController();
 final TextEditingController _groupController=TextEditingController();
 final TextEditingController _salesmanController=TextEditingController();
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
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              "Sheracc ERP Offline",
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
                           Icon(Icons.calendar_month_outlined, color: Appcolors().maincolor),
                           SizedBox(width: 5),
                           Text(
                             _toDate != null ? _dateFormat.format(_toDate!) : "To Date",
                             style: getFonts(13, _toDate != null ? Appcolors().maincolor : Colors.grey),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
           SizedBox(height: screenHeight * 0.0002),
            GestureDetector(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.03),
          child: Container(
            height: screenHeight * 0.05,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
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
      ),
      Padding(
        padding:  EdgeInsets.symmetric(horizontal: screenHeight *0.02),
        child: Container(
          child: Column(
            children: [
              _salefield("Select Supplier", _selectSupplierController, screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.0002),
              _salefield("Select Item Code", _selectSupplierController, screenWidth, screenHeight),
              _salefield("Select Item Name", _selectSupplierController, screenWidth, screenHeight),
              _salefield("Manufacture", _selectSupplierController, screenWidth, screenHeight),
              _salefield("Category", _selectSupplierController, screenWidth, screenHeight),
              _salefield("Group", _selectSupplierController, screenWidth, screenHeight),
              _salefield("Salesman", _selectSupplierController, screenWidth, screenHeight)
        
            ],
          ),
        ),
      ),
       SizedBox(height: screenHeight * 0.0002),
      Container(
        height: screenHeight * 0.05,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              border: Border.all(color: Appcolors().maincolor)
            ),
      )
        ],
      ),
      
    );
  }
  Widget _salefield(String txt,TextEditingController controller,double screenWidth, double screenHeight){
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
                hintText: "$txt"
              ),
            ),
          ),
        ],
      ),
    );
  }
}