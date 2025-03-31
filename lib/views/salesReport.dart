import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/options.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_refer.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/salesDBHelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/salesreportShow.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
   int? selectedIndex;
 final TextEditingController _selectSupplierController=TextEditingController();
 final TextEditingController _selectItemcodeController=TextEditingController();
 final TextEditingController _selectItemnameController=TextEditingController();
 final TextEditingController _manufactureController=TextEditingController();
 final TextEditingController _categoryController=TextEditingController();
 final TextEditingController _groupController=TextEditingController();
 final TextEditingController _salesmanController=TextEditingController();
 final TextEditingController _dateController=TextEditingController();
 
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();
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

   bool _isChecked = false;
  String selectedValue = "Report Type";
  bool isExpanded = false; 
  

  @override
  void initState() {
    super.initState();
  _fetchCustomerItemData();
  _fetchstock();
  _fetchLedgerNames();
  _fetchSType();
  _fetchSettings();
  }
final GlobalKey _arrowKey = GlobalKey();
optionsDBHelper dbHelper=optionsDBHelper();
List salieretype=[];
Future<void> salesreporttype()async{
  salieretype=await dbHelper.getOptionsByType("sales_reporttype");
}

List settings=[];
  Future<void> _fetchSettings() async {
    try {
      List<Map<String, dynamic>> data = await SaleReferenceDatabaseHelper.instance.getAllsettings();
      print('Fetched stock data: $data');
      setState(() {
        settings = data;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }
  List stypelist=[];
Future<void> _fetchSType() async {
    try {
      List<Map<String, dynamic>> data = await SaleReferenceDatabaseHelper.instance.getAllStype();
      print('Fetched stock data: $data');
      setState(() {
        stypelist = data;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }

List<String> ItemList = [];
List<Map<String, String>> customer = [];
Future<void> _fetchCustomerItemData() async {
    List<Map<String, String>> data = await SaleDatabaseHelper.instance.getAll();
    setState(() {
      customer = data;  
    });
  }
    List<String> items = [];
List <String> Itemnames=[];
Future<void> _fetchstock() async {
  List<String> itemids = await StockDatabaseHelper.instance.getAllItemcode();
List<String> itemname = await StockDatabaseHelper.instance.getAllItemnames();
  setState(() {
    items = itemids;
    Itemnames=itemname;
  });
}

List <String>ledgerNames = [];
  Future<void> _fetchLedgerNames() async {
  List<String> names = await LedgerTransactionsDatabaseHelper.instance.getAllNames();
    setState(() {
    ledgerNames = names; 
    });
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
        physics: ScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Padding(
               padding:  EdgeInsets.symmetric(horizontal: screenHeight *0.02),
               child: Container(
                 height: 39,
                 width: screenWidth*0.9,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(5),
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
                     SizedBox(height: screenHeight * 0.0002),

        Padding(
          padding:  EdgeInsets.symmetric(horizontal: screenHeight *0.02),
          child: Container(
            child: Column(
              children: [
                 SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: EasyAutocomplete(
                      controller: _selectItemcodeController,
                      suggestions: items,
                          
                         
                      onSubmitted: (value) {

                                },
                      decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  hintText: "Select Item code",
                  hintStyle: TextStyle(fontSize: 14)
                                ),
                                suggestionBackgroundColor: Appcolors().Scfold,
                    ),
                ),
              ),
                 SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: EasyAutocomplete(
                      controller: _selectItemnameController,
                      suggestions: Itemnames,
                          
                         
                      onSubmitted: (value) {

                                },
                      decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  hintText: "Select Item Name",
                  hintStyle: TextStyle(fontSize: 14)
                                ),
                                suggestionBackgroundColor: Appcolors().Scfold,
                    ),
                ),
              ),
               SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: EasyAutocomplete(
                      controller: _selectSupplierController,
                      suggestions: ledgerNames,
                        
                           onChanged: (value) {
         
              },
                      onSubmitted: (value) {
                                },
                                    decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  hintText: "Select Customer",
                  hintStyle: TextStyle(fontSize: 14)
                                ),
                  suggestionBackgroundColor: Appcolors().Scfold,
                    ),
                ),
              ),
                //_salefield("Select Item Name", _selectSupplierController, screenWidth, screenHeight),
                _salefield("Manufacture", _manufactureController, screenWidth, screenHeight),
                _salefield("Category", _categoryController, screenWidth, screenHeight),
                                _salefield("Salesman", _salesmanController, screenWidth, screenHeight),

               
                //_salefield("Select Supplier", _selectSupplierController, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.0002),
                
                _salefield("Group", _groupController, screenWidth, screenHeight),
          
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight*0.02,),
        Container(
          height: screenHeight * 0.03,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Appcolors().maincolor)
              ),
              child: Row(
                children: [
                  SizedBox(width: screenHeight*0.03,),
        Text("Sales From",style: getFonts(12, Colors.black),),
        SizedBox(width: screenHeight*0.05,),
         InkWell(
          onTap: (){
         _showSalesTypeDialog();
          },
          child: Text("Sales",style: getFonts(12, Colors.black),)),
                ],
              ),
        ),
         SizedBox(height: screenHeight * 0.02),
        Container(
          height: screenHeight * 0.05,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Appcolors().maincolor)
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
        _buttonOB(screenHeight, screenWidth),
        SizedBox(width: screenHeight*0.01,),
        Text("Report Type",style: getFonts(12, Colors.black),),
        SizedBox(width: screenHeight*0.02,),
        Expanded(
                child: GestureDetector(
                  child: Text(
                    selectedValue,
                    style: getFonts(12, Colors.black),
                  ),
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
         SizedBox(height: screenHeight * 0.0002),
              GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ShowSalesReport(
                          customerName: _selectSupplierController.text,
                          itemcode: _selectItemcodeController.text,
                          itemName: _selectItemnameController.text,
                          fromDate: _fromDate,
                          toDate: _toDate,
                        )));
          },
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
          ],
        ),
      ),
      
    );
  }

void _showSalesTypeDialog() {
  List<Map<String, dynamic>> tempSalesType = List<Map<String, dynamic>>.from(stypelist);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Sales Forms', style: drewerFonts()),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(tempSalesType.length, (index) {
                    bool isChecked = (tempSalesType[index]['isChecked'] ?? 0) == 1;
                    return Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: isChecked ? Appcolors().maincolor : Colors.grey, 
                            checkColor: Colors.white,
                            onChanged: (bool? value) async {
                              if (value == null) return;
                      
                              setState(() { 
                                tempSalesType[index] = {
                                  ...tempSalesType[index], 
                                  'isChecked': value ? 1 : 0, 
                                };
                              });
                            
                            },
                          ),
                          Expanded(
                            child: Text(
                              tempSalesType[index]['Type'] ?? "",
                              style: getFonts(14, isChecked ? Appcolors().maincolor : Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  stypelist = List<Map<String, dynamic>>.from(tempSalesType);
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    },
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
                hintText: "$txt",
                hintStyle: TextStyle(fontSize: 14)
              ),
            ),
          ),
        ],
      ),
    );
  }
   Widget _buttonOB(double screenHeight,double screenWidth){
    
    return Row(
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
                  Text("All")
      ],
    );
  }
void _showPopupMenu() async {
  await salesreporttype();
  if (salieretype.isEmpty) {
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
    items: salieretype 
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
  void showRectangularDialog(BuildContext context, double screenHeight, double screenWidth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), 
          ),
          child: Container(
            width: screenWidth * 0.5,
            height: screenHeight * 0.5, 
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCheckboxRow(0, "Sales ES", screenHeight),
                buildCheckboxRow(1, "Sales B2B", screenHeight),
                buildCheckboxRow(2, "Sales B2C", screenHeight),
                buildCheckboxRow(3, "Sales of Supply", screenHeight),
                buildCheckboxRow(4, "Sales IS", screenHeight),
                buildCheckboxRow(5, "Sales Order", screenHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text("OK", style: getFonts(14, Colors.black)),
                    ),
                    SizedBox(width: screenHeight * 0.01),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel", style: getFonts(14, Colors.black)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCheckboxRow(int index, String text, double screenHeight) {
    return Row(
      children: [
        SizedBox(height: screenHeight * 0.02),
        Checkbox(
          value: selectedIndex == index, 
          onChanged: (bool? value) {
            setState(() {
              selectedIndex = value! ? index : null;
            });
          },
          checkColor: Colors.white,
          activeColor: selectedIndex == index ? Colors.blue : Colors.transparent, // You can replace 'Colors.blue' with your desired color.
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(text, style: getFonts(14, Colors.black)),
      ],
    );
    
  }
  
}