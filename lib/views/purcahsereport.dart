import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/options.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';

class Purcahsereport extends StatefulWidget {
  const Purcahsereport({super.key});

  @override
  State<Purcahsereport> createState() => _PurcahsereportState();
}

class _PurcahsereportState extends State<Purcahsereport> {
 String selectedValue = "Report Type";
  bool isExpanded = false; 
   optionsDBHelper dbHelper=optionsDBHelper();
List purcahse_reportType=[];
Future<void> salesreporttype()async{
  purcahse_reportType=await dbHelper.getOptionsByType("purcahse_reportType");
}
final GlobalKey _arrowKey = GlobalKey();
bool _isChecked = false;
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
              "Purchase Report",
              style: appbarFonts(screenHeight * 0.02, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight*0.02),
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
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
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
                     SizedBox(height: screenHeight * 0.00),
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
          ),
          Container(
                height: screenHeight * 0.06,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  color: Colors.white,
                  border: Border.all(color: Appcolors().searchTextcolor),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Row(
                    children: [
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: TextFormField(
                          // controller: controller,
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter $label';
                          //   }
                          //   return null;
                          // },
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: "Select Supplier",
                            hintStyle: TextStyle(fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight*0.02,),
              Container(
                height: screenHeight * 0.06,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  color: Colors.white,
                  border: Border.all(color: Appcolors().searchTextcolor),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Row(
                    children: [
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: TextFormField(
                          //controller: controller,
                          
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: "Name",
                            hintStyle: TextStyle(fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
               SizedBox(height: screenHeight*0.02,),
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
                    Text("Purchace only\nor\n(purchase,purchase return,purchase order)",style: getFonts(10, Colors.black),)
                         ],
                       ),
                 ),
              SizedBox(height: screenHeight*0.02,),
              Container(
              height: screenHeight * 0.03,
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(color: Appcolors().searchTextcolor)
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: screenHeight*0.03,),
            Text("Report Type",style: getFonts(12, Colors.black),),
            SizedBox(width: screenHeight*0.05,),
            Expanded(
                    child: Text(
                      selectedValue,
                      style: getFonts(12, Colors.black),
                    ),
                  ),
                  GestureDetector(
                    key: _arrowKey,
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                      _showPopupMenu();
                    },
                    child: Icon(
                      isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                  ),
                    ],
                  ),
            ),
            ],
          ),
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