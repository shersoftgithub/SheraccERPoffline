import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sheraaccerpoff/models/salescredit_modal.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/salesDBHelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/stockDB.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/sales.dart';

class Addpaymant extends StatefulWidget {
  final SalesCredit? salesCredit;
  final SalesCredit? salesdebit;
  const Addpaymant({super.key,this.salesCredit,this.salesdebit});

  @override
  State<Addpaymant> createState() => _AddpaymantState();
}

class _AddpaymantState extends State<Addpaymant> {
  final TextEditingController _itemnameController=TextEditingController();
  final TextEditingController _qtyController=TextEditingController();
  final TextEditingController _unitController=TextEditingController();
  final TextEditingController _rateController=TextEditingController();
  final TextEditingController _taxController=TextEditingController();
  List<String> _itemSuggestions = [];
    bool isCashSave = false;

  void _fetchItemNames() async {
    //List<String> items = await SaleDatabaseHelper.instance.getAllUniqueItemname();
    List<String> items = await SaleDatabaseHelper.instance.getAllUniqueItemname();
    setState(() {
      _itemSuggestions = items;
    });
  }
   List<String> productNames = [];
    Future<void> _fetchProductNames() async {
    List<String> products = await StockDatabaseHelper.instance.getAllItemNames();
        setState(() {
      productNames = products;
    });
  }
 void _saveData() {
  final itemName = _itemnameController.text.trim();
  final unit = _unitController.text.trim();
  final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
  final rate = double.tryParse(_selectedRate.toString()) ?? 0.0;
  final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  final totalAmt = (rate * qty) + (tax * qty);

  final creditsale = SalesCredit(
    invoiceId: 0,
    date: "", 
    salesRate: 0.0,
    customer: "",
    phoneNo: "",
    itemName: itemName,
    qty: qty,
    unit: unit,
    rate: rate,
    tax: tax,
    totalAmt: totalAmt,
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>SalesOrder(salesCredit: creditsale,),
    ),
  );
}

void _saveDataCash() {
  final itemName = _itemnameController.text.trim();
  final unit = _unitController.text.trim();
  final qty = double.tryParse(_qtyController.text.trim()) ?? 0.0;
  final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
  final tax = double.tryParse(_taxController.text.trim()) ?? 0.0;
  final totalAmt = (rate * qty) + tax;

  final Cashcreditsale = SalesCredit(
    invoiceId: 0,
    date: "", 
    salesRate: 0.0,
    customer: "",
    phoneNo: "",
    itemName: itemName,
    qty: qty,
    unit: unit,
    rate: rate,
    tax: tax,
    totalAmt: totalAmt,
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>SalesOrder(salesDebit: Cashcreditsale,),
    ),
  );
}

@override
  void initState() {
    super.initState();
    _fetchItemNames(); 
     _fetchProductNames();
    
  }
  void _onItemnameChanged(String value) async {
  List<String> items = await SaleDatabaseHelper.instance.getAllUniqueItemname();
  setState(() {
    _itemSuggestions = items.where((item) => item.contains(value)).toList();
  });
}
 void _onItemnamecreateChanged(String value) async {
    if (!_itemSuggestions.contains(value)) {
      _showCreateItemDialog(value, _unitController.text.trim(), double.tryParse(_qtyController.text.trim()) ?? 0.0,
          double.tryParse(_rateController.text.trim()) ?? 0.0, double.tryParse(_taxController.text.trim()) ?? 0.0,
          (double.tryParse(_rateController.text.trim()) ?? 0.0) * (double.tryParse(_qtyController.text.trim()) ?? 0.0));
    }
  }
  String? _selectedRate;
  List<Map<String, String>> itemDetails = [];
 Future<void> _onItemnameChanged2(String value) async {
  if (value.isEmpty) {
    setState(() {
      itemDetails = [];
    });
    return;
  }

  // Fetch item details including tax
  List<Map<String, String>> details = await StockDatabaseHelper.instance.getItemDetailsByName(value);

  setState(() {
    itemDetails = details.isNotEmpty ? details : [];
    _selectedRate = null; // Reset selected rate when a new item is selected
  });

  // Update the tax field in the controller
  if (details.isNotEmpty) {
    _taxController.text = details[0]["tax"] ?? "N/A"; // Set tax value into controller
  }

  // Handle no data case
  if (details.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No data found for "$value".')),
    );
  }
}




  void _onRateSelected(String? selectedRate) {
  setState(() {
    _selectedRate = selectedRate;
    _rateController.text = selectedRate ?? '';
  });
}
 bool _isDropdownVisible = false;

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
              "Add Item To Sale",
              style: appbarFonts(screenHeight * 0.02, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: 10),
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
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
                  "Item Name",
                  style: formFonts(14, Colors.black),
                ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              height: screenHeight * 0.05,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(color: Appcolors().searchTextcolor),
              ),
              child: SingleChildScrollView(
                child: EasyAutocomplete(
                  suggestionBackgroundColor: Appcolors().Scfold,
                    controller: _itemnameController,
                    suggestions: productNames,
                    onChanged: (value) {
    _onItemnameChanged2(value); 
  },
  onSubmitted: (value) {
    _onItemnameChanged2(value); 
  },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 5)
                    ),
                  ),
              ),
            ),
           
          ],
        ),
            ),
            SizedBox(height: screenHeight*0.02,),
          Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
                  
                  'Quantity',
                  style: formFonts(14, Colors.black),
                ),
            SizedBox(height: screenHeight * 0.01),
            Container(
               height: 35, 
              width: 173,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(color: Appcolors().searchTextcolor),
              ),
               child: TextFormField(
                       controller: _qtyController,
                        keyboardType: TextInputType.number,
                        obscureText: false,
                       // onChanged: _onRateChanged,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 5),
                        ),
                      ),
            ),
          ],
        ),
            ),
             Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
                  
                  'Unit',
                  style: formFonts(14, Colors.black),
                ),
            SizedBox(height: screenHeight * 0.01),
            GestureDetector(
              child: Container(
                 height: 35, 
                width: 173,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  border: Border.all(color: Appcolors().searchTextcolor),
                ),
                child: TextFormField(
                         controller: _unitController,
                          
                          obscureText: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 5),
                          ),
                        ),
              ),
            ),
          ],
        ),
            )
              ],
            ),
          ),
        
          SizedBox(height: screenHeight*0.02,),
          Container(
            child: SingleChildScrollView(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                    
                    'Rate(Price/unit)',
                    style: formFonts(14, Colors.black),
                  ),
              SizedBox(height: screenHeight * 0.01),
                      GestureDetector(
                        onTap: () => setState(() => _isDropdownVisible = !_isDropdownVisible),
                        child: Container(
              height: 35,
              width: 173,
              decoration: BoxDecoration(
                border: Border.all(color: Appcolors().searchTextcolor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  _selectedRate ?? "Select Rate",
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
                        ),
                      ),
              
                      // If dropdown is visible, show the item details
                      if (_isDropdownVisible)
                        Container(
              width: 170,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: itemDetails.isNotEmpty
                  ? Table(
                      border: TableBorder.all(color: Colors.grey),
                      children: [
                        _buildTableRow("MRP", itemDetails[0]["mrp"]),
                        _buildTableRow("Retail", itemDetails[0]["retail"]),
                        _buildTableRow("WS Rate", itemDetails[0]["wsrate"]),
                        _buildTableRow("SP Rate", itemDetails[0]["sprate"]),
                        _buildTableRow("Branch", itemDetails[0]["branch"]),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No data found for the selected item.',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                        ),
              
              
                        ],
                      ),
              ),
               Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                    
                    'Tax',
                    style: formFonts(14, Colors.black),
                  ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                 height: 35, 
                width: 173,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  border: Border.all(color: Appcolors().searchTextcolor),
                ),
                child: TextFormField(
                         controller: _taxController,
                          
                          obscureText: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 5),
                          ),
                        ),
              ),
                        ],
                      ),
              )
                ],
              ),
            ),
          ),
          ],
        ),
      ),
       bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: screenHeight*0.03,vertical:screenHeight*0.03 ),
        child: Row(children: [
          GestureDetector(
            onTap: (){},
            child: Container(
              width: 175,height: 53,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5),bottomLeft: Radius.circular(5)),
                color: Appcolors().Scfold
                
              ),
              child: Center(child: Text("Save & New",style: getFonts(15, Colors.black),)),
            ),
          ),
          GestureDetector(
            onTap: (){
               if (isCashSave) {
              _saveDataCash();
            } else {
              _saveData(); // Call the normal save function
            }
            setState(() {
              isCashSave = !isCashSave; // Toggle between cash and normal save actions
            });
            },
            child: Container(
              width: 175,height: 53,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(5),bottomRight: Radius.circular(5)),
                color: Appcolors().maincolor
              ),
              child: Center(child: Text("Save ",style: getFonts(15, Colors.white),)),
            ),
          )
        ],),
      ),  
    );
  }

  void _showCreateItemDialog(String itemName, String unit, double qty, double rate, double tax, double totalAmt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(backgroundColor: Appcolors().Scfold,
          title: Text('Create a new item'),
          content: Text('Item "$itemName" does not exist. Would you like to create it?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',style: TextStyle(color: Appcolors().maincolor),),
            ),
            TextButton(
              onPressed: () async {
                final creditsale = SalesCredit(
                  invoiceId: 0,
                  date: "",
                  salesRate: 0.0,
                  customer: "",
                  phoneNo: "",
                  itemName: itemName,
                  qty: qty,
                  unit: unit,
                  rate: rate,
                  tax: tax,
                  totalAmt: totalAmt,
                );
                await SaleDatabaseHelper.instance.insert(creditsale.toMap());
                Navigator.of(context).pop();  
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item created and saved')));
                _fetchItemNames();
              },
              child: Text('Create',style: TextStyle(color: Appcolors().maincolor),),
            ),
          ],
        );
      },
    );
  }
TableRow _buildTableRow(String label, String? value) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      GestureDetector(
        onTap: () {
          setState(() {
            // Update the selected value based on the clicked row
            _selectedRate = value ?? "N/A"; // Update the selected rate
            _isDropdownVisible = false; // Close the dropdown after selection
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(value ?? "N/A"),
        ),
      ),
    ],
  );
}

}