import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sheraaccerpoff/models/newLedger.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/LEDGER_DB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/MainDB.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/newLedgerDBhelper.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/options.dart';
import 'package:sheraaccerpoff/sqlfliteDataBaseHelper/sale_refer.dart';
import 'package:sheraaccerpoff/utility/colors.dart';
import 'package:sheraaccerpoff/utility/fonts.dart';
import 'package:sheraaccerpoff/views/more_home/settings.dart';

class Newledger extends StatefulWidget {
  
  const Newledger({super.key});

  @override
  State<Newledger> createState() => _NewledgerState();
}

class _NewledgerState extends State<Newledger> with SingleTickerProviderStateMixin {
  late TabController _tabController;
 final TextEditingController _adressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _taxnoController = TextEditingController();
  final TextEditingController _pricelevelController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _LedgernameController = TextEditingController();
  final TextEditingController _underController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _openingBalanceController = TextEditingController();
  final TextEditingController _reievedAmtController = TextEditingController();
  final TextEditingController _PayAmtController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetch_options();
    _fetchUnder();
    _fetchLedger();
    //_loadUnderSuggestions();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
bool _isChecked = false;

Map<String, bool> _checkboxStates = {
    "Active": false,
    "Cost Center": false,
    "Franchise": false,
    "Bill Wise": false,
  };

bool isBasicDataSaved = false;  
Ledger? tempLedger;

List <String> names=[];
Future<void> _fetchLedger() async {
    List<String> cname = await LedgerTransactionsDatabaseHelper.instance.getAllNames();

  setState(() {
    names=cname;
  });
}

List<String> underlist = [];
Future<void> _fetchUnder() async {
  try {
    List<String> data = await SaleReferenceDatabaseHelper.instance.getAllLedgerHeadNames();
    print('Fetched stock data: $data');

    setState(() {
      underlist = data; // Directly assigning List<String>
    });
  } catch (e) {
    print('Error fetching stock data: $e');
  }
}



Future<void> _saveData() async {
  try {
    final db = await LedgerTransactionsDatabaseHelper.instance.database;

    // Fetch the highest Ledcode properly
    final result = await db.rawQuery(
      'SELECT Ledcode FROM LedgerNames ORDER BY CAST(Ledcode AS INTEGER) DESC LIMIT 1'
    );

    // Ensure the correct largest Ledcode is retrieved
    int newLedCode = (result.isNotEmpty && result.first['Ledcode'] != null)
        ? (int.tryParse(result.first['Ledcode'].toString()) ?? 0) + 1
        : 1;  // Start from 1 if no records exist

    double receivedBalance = double.tryParse(_reievedAmtController.text) ?? 0.0;
    double payAmount = double.tryParse(_PayAmtController.text) ?? 0.0;

    final ledgerData = {
      'Ledcode': newLedCode.toString(),
      'LedName': _LedgernameController.text,
      'add1': _adressController.text,
      'Mobile': _contactController.text,
      'CAmount': payAmount,
      'OpeningBalance': payAmount - receivedBalance,
      'under': _underController.text,
      'Debit': _reievedAmtController.text,
      'date': _dateController.text,
      'balance': receivedBalance
    };

    await db.insert('LedgerNames', ledgerData);

    print('Inserted ledger with Ledcode: $newLedCode');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved successfully')),
    );

    _reievedAmtController.clear();
    _PayAmtController.clear();
    _LedgernameController.clear();
    _adressController.clear();
    _contactController.clear();
  } catch (e) {
    print('Error while saving data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving data: $e')),
    );
  }
}





// void _saveData() async {
//   try {
//     if (!isBasicDataSaved) {
//       tempLedger = Ledger(
//       ledgerName: _LedgernameController.text, 
//       under: _underController.text, 
//       address: '', 
//       contact: '',
//       mail: '',
//       taxNo: '',
//       priceLevel: '',
//       balance: 0.0,
//       openingBalance: 0.0,
//       receivedBalance: 0.0,
//       payAmount: 0.0
//     );
//       isBasicDataSaved = true;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Basic data saved temporarily')),
//       );
//     } else {
//       final ledger = Ledger(
//         ledgerName: tempLedger!.ledgerName,
//         under: tempLedger!.under,
//         address: _adressController.text,
//         contact: _contactController.text,
//         mail: _mailController.text,
//         taxNo: _taxnoController.text,
//         priceLevel: _pricelevelController.text,
//         balance: double.tryParse(_balanceController.text) ?? 0.0,
//         openingBalance: double.tryParse(_openingBalanceController.text) ?? 0.0,
//         receivedBalance: double.tryParse(_reievedAmtController.text) ?? 0.0,
//         payAmount: double.tryParse(_PayAmtController.text) ?? 0.0,
//       );
//       int id = await DatabaseHelper.instance.insert(ledger.toMap());
//       print('Inserted ledger with ID: $id'); // Debug output

//       isBasicDataSaved = false;
//       tempLedger = null;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Full data saved successfully')),
//       );
//     }
//   } catch (e) {
//     print('Error while saving data: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error saving data: $e')),
//     );
//   }
// }


optionsDBHelper dbHelper = optionsDBHelper();
    List<String> salesrate = [];
    Future<void>fetch_options()async{
      salesrate = await dbHelper.getOptionsByType('price_level');
      setState(() {
        
      });
    }
    void onSaleRateSelected(String value) {
    print('Selected Supplier: $value');
   
    _pricelevelController.text = value;
  }

  List<String> _underSuggestions = [];
  List<String> _allUnder = [];


//  _loadUnderSuggestions() async {
//     List<String> uniqueUnder = await DatabaseHelper.instance.getAllUniqueUnder();
//     setState(() {
//       _allUnder = uniqueUnder;
//       _underSuggestions = uniqueUnder;  
//     });
//   }
  void _onUnderTextChanged(String query) {
    setState(() {
      _underSuggestions = _allUnder
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

   Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
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
              "Ledger",
              style: appbarFonts(screenHeight * 0.02, Colors.white),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight*0.02),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context )=>Settings()));
              },
              child: SizedBox(
                width: 20,
                height: 20,
                child: Image.asset("assets/images/setting (2).png"),
              ),
            ),
          ),
          //  Padding(
          //   padding: EdgeInsets.only(top: screenHeight * 0.02, right: screenHeight*0.02),
          //   child: GestureDetector(
          //     onTap: () {
          //       _saveData();
          //     },
          //     child: SizedBox(
          //       width: 20,
          //       height: 20,
          //       child: Image.asset("assets/images/save-instagram.png"),
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Column(
        children: [
          // Top Buttons Row
          Container(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02,horizontal: screenHeight*0.07),
            child: Row(
             
              children: [
                GestureDetector(
                  onTap: () {
                    _saveData();
                  },
                  child: _TopButtons("Save", screenWidth, screenHeight),
                ),
                SizedBox(width: screenHeight*0.02,),
                GestureDetector(
                  onTap: () {
                     _reievedAmtController.clear();
    _PayAmtController.clear();
    _underController.clear();
    _LedgernameController.clear();
    _adressController.clear();
    _contactController.clear();
    _mailController.clear();
    _taxnoController.clear();
    _pricelevelController.clear();
    _balanceController.clear();
    _reievedAmtController.clear();
                  },
                  child: _TopButtons("Clear", screenWidth, screenHeight),
                ),
                SizedBox(width: screenHeight*0.02,),
                GestureDetector(
                  onTap: () {},
                  child: _TopButtons("Delete", screenWidth, screenHeight),
                ),
              ],
            ),
          ),
          // Tabs below buttons
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: screenHeight*0.02),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                color: Appcolors().maincolor,
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Appcolors().maincolor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                labelStyle: getFonts(12, Colors.white),
                tabs: const [
                  Tab(text: "Account",),
                  Tab(text: "Address"),
                  Tab(text: "Opening Balance",),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AccountTab(screenHeight,screenWidth), // Account Tab
                _AddressTab(screenHeight,screenWidth), // Address Tab
                _OpeningBalanceTab(screenHeight,screenWidth), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _TopButtons(String text, double screenWidth, double screenHeight) {
    return Container(
      height: 33,
      width: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color(0xFF0A1EBE),
      ),
      child: Center(
        child: Text(
          text,
          style: getFonts(16, Colors.white),
        ),
      ),
    );
  }

  // Account Tab Content
  Widget _AccountTab(double screenHeight,double screenWidth) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenHeight * .02),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
               Container(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
                  
                  'Ledger Name',
                  style: formFonts(14, Colors.black),
                ),
            SizedBox(height: screenHeight * 0.01),
            Container(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02,vertical: screenWidth * 0.02),
               height: screenHeight * 0.06,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(color: Appcolors().searchTextcolor),
              ),
             child: SingleChildScrollView(
               child: EasyAutocomplete(
                   controller: _LedgernameController,
                   suggestions: names,
                     inputTextStyle: getFontsinput(14, Colors.black), 
                   onSubmitted: (value) {
                     _onUnderTextChanged(value);  
                   },
                   decoration: InputDecoration(
                     border: InputBorder.none,
                     contentPadding: EdgeInsets.only(bottom: 20)
                   ),
                   suggestionBackgroundColor: Appcolors().Scfold,
                 ),
             ),
            ),
          ],
                ),
              ),
               
                SizedBox(height: screenHeight * 0.03),
                Container(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
                  
                  'Under',
                  style: formFonts(14, Colors.black),
                ),
            SizedBox(height: screenHeight * 0.01),
            Container(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02,vertical: screenWidth * 0.02),
               height: screenHeight * 0.06,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                border: Border.all(color: Appcolors().searchTextcolor),
              ),
             child: SingleChildScrollView(
               child: EasyAutocomplete(
                   controller: _underController,
                   suggestions: underlist,
                     inputTextStyle: getFontsinput(14, Colors.black), 
                   onSubmitted: (value) {
                     _onUnderTextChanged(value);  
                   },
                   decoration: InputDecoration(
                     border: InputBorder.none,
                     contentPadding: EdgeInsets.only(bottom: 20)
                   ),
                   suggestionBackgroundColor: Appcolors().Scfold,
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
    );
  }

  Widget _accfield22(double screenHeight, double screenWidth, String label,
      TextEditingController controller,
      {Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }
  
Widget _accfield(double screenHeight,double screenWidth,String label,TextEditingController controller ){
  return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: formFonts(14, Colors.black),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(padding: EdgeInsets.symmetric(vertical: screenHeight*0.025),
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
                      style: getFontsinput(14, Colors.black),
                      controller: controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter $label';
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
        ],
      ),
    );
}
  // Address Tab Content
  Widget _AddressTab(double screenHeight,double screenWidth) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: screenHeight*0.05,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenHeight*0.03),
          child: Column(
            children: [
             
                _paymentField("Address", _adressController, screenWidth, screenHeight),
                    SizedBox(height: screenHeight * 0.02),
                     Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Contact NO',
                style: formFonts(14, Colors.black),
              ),
              
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(padding: EdgeInsets.symmetric(vertical: screenHeight*0.024),
            height: screenHeight * 0.06,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: Row(
              children: [
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    style: getFontsinput(14, Colors.black),
                    controller: _contactController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Contact NO';
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
        ],
      ),
    ),
                    SizedBox(height: screenHeight * 0.02),
                    _paymentField("Mail", _mailController, screenWidth, screenHeight),
                    SizedBox(height: screenHeight * 0.02),
                    _paymentField("Tax NO", _taxnoController, screenWidth, screenHeight),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Price Level",
                style: formFonts(14, Colors.black),
              ),
              
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(padding: EdgeInsets.symmetric(horizontal: screenHeight*0.01,vertical: screenHeight*0.01),
            height: screenHeight * 0.06,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: 
                    SingleChildScrollView(
             child: EasyAutocomplete(
                 controller: _pricelevelController,
                 suggestions: salesrate,
                 inputTextStyle: getFontsinput(14, Colors.black),    
                 onSubmitted: (value) {
                 },
                 decoration: InputDecoration(
                   border: InputBorder.none,
                   contentPadding: EdgeInsets.only(bottom: 20)
                 ),
                 suggestionBackgroundColor: Appcolors().Scfold,
               ),
           ),
          ),
        ],
      ),
    ),
                    SizedBox(height: screenHeight * 0.02),
                    _paymentField("Balance", _balanceController, screenWidth, screenHeight),
                    SizedBox(height: screenHeight * 0.02),
            ],
          ),
        )
        ],
      ),
    );
  }

  Widget _OpeningBalanceTab(double screenHeight,double screenWidth) {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: [
           SizedBox(height: screenHeight * 0.03),
      
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenHeight*0.02),
        height: screenHeight * 0.04,
        width: screenWidth * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade600)
        ),
        child: TextField(
          style: getFontsinput(14, Colors.black),
           readOnly: true,
          controller: _dateController,
           decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              ),
        ),
      ),
          ),
          SizedBox(height: screenHeight * 0.04),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: screenHeight*0.03),
            child: Container(
              
              child: Column(
                children: [
                  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _field("Recieve Amount(Dr)", screenWidth, screenHeight,_reievedAmtController),
                _field("Pay Amount(Cr)", screenWidth, screenHeight,_PayAmtController)
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
                     Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
           Container(
  height: 35,
  width: 170,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Color(0xFF0A1EBE),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          "Active", 
          style: getFonts(14, Colors.white),
        ),
      ),
     Checkbox(
                  side: BorderSide(color: Colors.white),
                value: true,
                onChanged: (bool? value) {
                  setState(() {
                    _checkboxStates['Active'] = value!;
                  });
                },
                
                checkColor: Appcolors().maincolor,
                activeColor: Colors.white, 
              ),
    ],
  ),
),


                     _buttonOB(screenHeight, screenWidth, "Cost Center"),
            ],
                     ),
                     SizedBox(height: screenHeight * 0.02),
                     Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buttonOB(screenHeight, screenWidth, "Franchise"),
                     _buttonOB(screenHeight, screenWidth, "Bill Wise")
            ],
                     )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

   Widget _paymentField(String label, TextEditingController controller, double screenWidth, double screenHeight) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: formFonts(14, Colors.black),
              ),
              
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(padding: EdgeInsets.symmetric(vertical: screenHeight*0.024),
            height: screenHeight * 0.06,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: Row(
              children: [
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: TextFormField(
                    style: getFontsinput(14, Colors.black),
                    controller: controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter $label';
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
        ],
      ),
    );
  }
  Widget _field (String label,double screenWidth,double screenHeight ,TextEditingController controller){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: formFonts(14, Colors.black),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            height: 35,
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              color: Colors.white,
              border: Border.all(color: Appcolors().searchTextcolor),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01,vertical: screenHeight*0.014),
              child: Row(
                children: [
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: TextFormField(
                      style: getFontsinput(14, Colors.black),
                      controller: controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter $label';
                        }
                        return null;
                      },
                      textAlign: TextAlign.right,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: screenHeight * 0.01),
                      ),
                    keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buttonOB(double screenHeight,double screenWidth,String txt){
     
    return Container(
            height: 35,
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xFF0A1EBE),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    "$txt",
                    style: getFonts(14, Colors.white),
                  ),
                ),
                Checkbox(
                  side: BorderSide(color: Colors.white),
                value: _checkboxStates[txt] ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    _checkboxStates[txt] = value!;
                  });
                },
                
                checkColor: Appcolors().maincolor,
                activeColor: Colors.white, 
              ),
              ],
            ),
          );
  }
}
