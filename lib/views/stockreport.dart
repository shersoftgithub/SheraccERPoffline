import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/options.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/stockreportShow.dart';

class StockReport extends StatefulWidget {
  const StockReport({super.key});

  @override
  State<StockReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<StockReport> {
 final TextEditingController _selectSupplierController=TextEditingController();
 final TextEditingController _selectItemcodeController=TextEditingController();
 final TextEditingController _selectItemnameController=TextEditingController();
 final TextEditingController _manufactureController=TextEditingController();
 final TextEditingController _categoryController=TextEditingController();
 final TextEditingController _groupController=TextEditingController();
 final TextEditingController _salesmanController=TextEditingController();
  final TextEditingController _dateController=TextEditingController();

 DateTime? _fromDate;
  DateTime? _toDate;
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
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
  String selectedValue = "Report Type";
  bool isExpanded = false; 
  optionsDBHelper dbHelper=optionsDBHelper();
List Stock_reportType=[];
Future<void> StockreportType()async{
  Stock_reportType=await dbHelper.getOptionsByType("Stock_reportType");
}

@override
  void initState() {
  _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      super.initState();
      _fetchLedgerIds();
  }
final GlobalKey _arrowKey = GlobalKey();

  List<String> items = [];
   List <String> suppliers=[];
List <String> Itemnames=[];
Future<void> _fetchLedgerIds() async {
  List<String> itemids = await StockDatabaseHelper.instance.getAllItemcode();
    List<String> cname = await StockDatabaseHelper.instance.getAllsupplier(); 
List<String> itemname = await StockDatabaseHelper.instance.getAllItemnames();
  setState(() {
    items = itemids;
    suppliers=cname;
    Itemnames=itemname;
  });
}

void _showLedgerWithFilters() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ShowStockReport(
        fromDate: _fromDate,
        toDate: _toDate,
      supplier  : _selectSupplierController.text,
      itemcode: _selectItemcodeController.text,
      itemname: _selectItemnameController.text,
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
              "Stock Report",
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
                             Icon(Icons.calendar_month_outlined, color: Appcolors().searchTextcolor),
                             SizedBox(width: 5),
                             Text(
                               _fromDate != null ? _dateFormat.format(_fromDate!) : "From Date",
                               style: getFonts(13, _fromDate != null ? Appcolors().maincolor : Colors.grey),
                             ),
                           ],
                         ),
                       ),
                       Text("-", style: TextStyle(color: Appcolors().maincolor,fontSize: 14)),
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
                  hintText: "Select Item Code",
                  hintStyle: TextStyle(fontSize: 14)
                                ),
                  suggestionBackgroundColor: Appcolors().Scfold,
                    ),
                ),
              ),
                //  _salefield("Select Item Code", _selectSupplierController, screenWidth, screenHeight),
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
               // _salefield("Select Item Name", _selectItemnameController, screenWidth, screenHeight),
                _salefield("Manufacture", _manufactureController, screenWidth, screenHeight),
                _salefield("Category", _categoryController, screenWidth, screenHeight),
                
                _salefield("Salesman", _salesmanController, screenWidth, screenHeight),
                SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: EasyAutocomplete(
                      controller: _selectSupplierController,
                      suggestions: suppliers,
                     
                      onSubmitted: (value) {
                                },
                                    decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                  hintText: "Select Supplier",
                  hintStyle: TextStyle(fontSize: 14)
                                ),
                  suggestionBackgroundColor: Appcolors().Scfold,
                    ),
                ),
              ),
               // _salefield("Select Supplier", _selectSupplierController, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.0002),
              
          _salefield("Group", _groupController, screenWidth, screenHeight),
              ],
            ),
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
          onTap: () {_showLedgerWithFilters();
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
   bool _isChecked = false;
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
                    hoverColor: Colors.white,
                    focusColor: Appcolors().maincolor,
                    checkColor: Colors.white,
                    activeColor: Appcolors().maincolor, 
                  ),
                  Text("All")
      ],
    );
  }
  void _showPopupMenu() async {
  await StockreportType();
  if (Stock_reportType.isEmpty) {
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
    items: Stock_reportType 
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